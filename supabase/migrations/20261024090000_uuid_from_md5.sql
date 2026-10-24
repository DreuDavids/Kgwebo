-- Postgres 17 rejects bit → uuid casts. Product sales used that pattern to
-- derive deterministic movement idempotency keys and could not complete.

create or replace function private.uuid_from_md5(p_text text)
returns uuid
language plpgsql
immutable
set search_path = public
as $$
declare
  h text := md5(p_text);
begin
  return (
    substr(h, 1, 8) || '-' ||
    substr(h, 9, 4) || '-' ||
    substr(h, 13, 4) || '-' ||
    substr(h, 17, 4) || '-' ||
    substr(h, 21, 12)
  )::uuid;
end;
$$;

revoke all on function private.uuid_from_md5(text) from public, anon, authenticated;

create or replace function public.record_product_sale(
  p_business_id uuid,
  p_idempotency_key uuid,
  p_occurred_at timestamptz,
  p_category text,
  p_description text,
  p_payment_method text,
  p_payment_status text,
  p_lines jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor uuid := (select auth.uid());
  v_currency text;
  v_existing public.transactions%rowtype;
  v_transaction public.transactions%rowtype;
  v_line jsonb;
  v_ordinal int;
  v_product_ids uuid[];
  v_product public.products%rowtype;
  v_product_id uuid;
  v_needed bigint;
  v_quantity bigint;
  v_price bigint;
  v_total bigint;
  v_sum bigint := 0;
  v_item public.sale_items%rowtype;
  v_items jsonb := '[]'::jsonb;
  v_movements jsonb := '[]'::jsonb;
  v_products jsonb := '[]'::jsonb;
  v_applied jsonb;
  v_line_key uuid;
begin
  if v_actor is null then
    raise exception 'Not authenticated';
  end if;
  if not private.owns_business(p_business_id) then
    raise exception 'Business not found or not owned by the signed-in user';
  end if;
  if p_lines is null or jsonb_typeof(p_lines) <> 'array' or jsonb_array_length(p_lines) < 1 then
    raise exception 'A product sale needs at least one line';
  end if;

  select *
    into v_existing
  from public.transactions
  where business_id = p_business_id
    and idempotency_key = p_idempotency_key;
  if found then
    select coalesce(jsonb_agg(to_jsonb(s) order by s.id), '[]'::jsonb)
      into v_items
    from public.sale_items s
    where s.transaction_id = v_existing.id;
    select coalesce(jsonb_agg(to_jsonb(m) order by m.created_at, m.id), '[]'::jsonb)
      into v_movements
    from public.stock_movements m
    where m.transaction_id = v_existing.id;
    return jsonb_build_object(
      'transaction', to_jsonb(v_existing),
      'items', v_items,
      'movements', v_movements,
      'products', '[]'::jsonb
    );
  end if;

  select b.currency_code
    into v_currency
  from public.businesses b
  where b.id = p_business_id
    and b.owner_id = v_actor;
  if v_currency is null then
    raise exception 'Business not found or not owned by the signed-in user';
  end if;

  select array_agg(distinct (line->>'product_id')::uuid order by (line->>'product_id')::uuid)
    into v_product_ids
  from jsonb_array_elements(p_lines) as line;
  if v_product_ids is null then
    raise exception 'Each sale line needs a product';
  end if;

  perform 1
  from public.products
  where id = any (v_product_ids)
  order by id
  for update;

  for v_product_id, v_needed in
    select (line->>'product_id')::uuid, sum((line->>'quantity_milli')::bigint)
    from jsonb_array_elements(p_lines) as line
    group by 1
    order by 1
  loop
    select *
      into v_product
    from public.products
    where id = v_product_id
      and business_id = p_business_id;
    if not found then
      raise exception 'Product not found or not owned by the signed-in user';
    end if;
    if not v_product.is_active then
      raise exception 'Archived products cannot be sold';
    end if;
    if v_product.stock_quantity_milli < v_needed then
      raise exception 'There is not enough stock for this sale';
    end if;
  end loop;

  for v_line in select value from jsonb_array_elements(p_lines)
  loop
    v_quantity := (v_line->>'quantity_milli')::bigint;
    if v_quantity is null or v_quantity <= 0 then
      raise exception 'Each sale line needs a positive quantity';
    end if;
    select *
      into v_product
    from public.products
    where id = (v_line->>'product_id')::uuid
      and business_id = p_business_id;
    if private.whole_unit_required(v_product.unit_of_measure)
       and (v_quantity % 1000) <> 0 then
      raise exception 'This product is counted in whole units';
    end if;
    v_price := coalesce(
      nullif(v_line->>'unit_price_minor', '')::bigint,
      v_product.selling_price_minor
    );
    v_total := private.line_amount_minor(v_quantity, v_price);
    if v_total is null or v_total <= 0 then
      raise exception 'A sale line must total at least 0.01 in the business currency';
    end if;
    v_sum := v_sum + v_total;
  end loop;

  if v_sum <= 0 or v_sum > 99999999999999 then
    raise exception 'Sale total is outside the supported range';
  end if;

  insert into public.transactions (
    business_id,
    idempotency_key,
    type,
    amount_minor,
    currency_code,
    category,
    description,
    occurred_at,
    payment_method,
    payment_status
  ) values (
    p_business_id,
    p_idempotency_key,
    'sale',
    v_sum,
    v_currency,
    p_category,
    p_description,
    p_occurred_at,
    p_payment_method,
    p_payment_status
  )
  returning * into v_transaction;

  for v_line, v_ordinal in
    select value, ordinality
    from jsonb_array_elements(p_lines) with ordinality
  loop
    select *
      into v_product
    from public.products
    where id = (v_line->>'product_id')::uuid;
    v_quantity := (v_line->>'quantity_milli')::bigint;
    v_price := coalesce(
      nullif(v_line->>'unit_price_minor', '')::bigint,
      v_product.selling_price_minor
    );
    v_total := private.line_amount_minor(v_quantity, v_price);

    insert into public.sale_items (
      business_id,
      transaction_id,
      product_id,
      quantity_milli,
      unit_price_minor,
      unit_cost_minor,
      line_total_minor
    ) values (
      p_business_id,
      v_transaction.id,
      v_product.id,
      v_quantity,
      v_price,
      v_product.unit_cost_minor,
      v_total
    )
    returning * into v_item;
    v_items := v_items || to_jsonb(v_item);

    v_line_key := private.uuid_from_md5(
      p_idempotency_key::text || ':' || v_ordinal::text || ':' || v_product.id::text
    );
    v_applied := private.apply_stock_movement(
      p_business_id,
      v_product.id,
      'sold',
      v_quantity,
      v_line_key,
      v_product.unit_cost_minor,
      null,
      null,
      null,
      v_transaction.id,
      null
    );
    v_movements := v_movements || (v_applied -> 'movement');
    v_products := v_products || (v_applied -> 'product');
  end loop;

  return jsonb_build_object(
    'transaction', to_jsonb(v_transaction),
    'items', v_items,
    'movements', v_movements,
    'products', v_products
  );
end;
$$;

create or replace function private.reverse_sale_inventory()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_item public.sale_items%rowtype;
  v_sold public.stock_movements%rowtype;
  v_key uuid;
begin
  if old.type <> 'sale' then
    return old;
  end if;
  if not exists (
    select 1 from public.sale_items s where s.transaction_id = old.id
  ) then
    return old;
  end if;

  for v_sold in
    select *
    from public.stock_movements
    where transaction_id = old.id
      and movement_type = 'sold'
    order by product_id
    for update
  loop
    if exists (
      select 1
      from public.stock_movements r
      where r.reverses_movement_id = v_sold.id
    ) then
      continue;
    end if;
    v_key := private.uuid_from_md5(old.id::text || v_sold.id::text || 'reverse');
    perform private.apply_stock_movement(
      v_sold.business_id,
      v_sold.product_id,
      'reversal',
      v_sold.quantity_milli,
      v_key,
      v_sold.unit_cost_minor,
      'Sale deleted',
      null,
      null,
      null,
      v_sold.id
    );
  end loop;

  return old;
end;
$$;
