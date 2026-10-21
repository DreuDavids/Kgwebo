-- Phase 6: product catalogue, stock movement ledger, and atomic product sales.
-- Costing policy: weighted-average unit cost on the product; sale lines freeze
-- the unit cost and selling price that were current at the time of the sale.
-- Inventory value is an estimate at recorded cost. It is not cash, sales,
-- profit, or an operating expense. COGS is informational and is not posted
-- as an expense transaction.
--
-- Quantities are integer milli-units (1000 = 1 unit). Money remains integer
-- minor units. Stock balances are never trusted from the client.

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  created_by uuid not null references public.profiles (id),
  name text not null check (char_length(btrim(name)) between 1 and 120),
  sku text check (
    sku is null
    or char_length(btrim(sku)) between 1 and 40
  ),
  description text check (
    description is null
    or char_length(btrim(description)) <= 500
  ),
  selling_price_minor bigint not null check (
    selling_price_minor > 0
    and selling_price_minor <= 99999999999999
  ),
  unit_cost_minor bigint check (
    unit_cost_minor is null
    or (
      unit_cost_minor > 0
      and unit_cost_minor <= 99999999999999
    )
  ),
  stock_quantity_milli bigint not null default 0 check (
    stock_quantity_milli >= 0
    and stock_quantity_milli <= 999999999999
  ),
  low_stock_threshold_milli bigint check (
    low_stock_threshold_milli is null
    or (
      low_stock_threshold_milli >= 0
      and low_stock_threshold_milli <= 999999999999
    )
  ),
  unit_of_measure text not null check (
    unit_of_measure in ('each', 'pack', 'kilogram', 'litre', 'metre')
  ),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists products_business_sku_unique
  on public.products (business_id, sku)
  where sku is not null;

create index if not exists products_business_name_idx
  on public.products (business_id, lower(name), id);

create index if not exists products_business_active_idx
  on public.products (business_id, is_active, name);

create table if not exists public.sale_items (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  transaction_id uuid not null references public.transactions (id) on delete cascade,
  product_id uuid not null references public.products (id) on delete restrict,
  quantity_milli bigint not null check (
    quantity_milli > 0
    and quantity_milli <= 999999999999
  ),
  unit_price_minor bigint not null check (
    unit_price_minor > 0
    and unit_price_minor <= 99999999999999
  ),
  unit_cost_minor bigint check (
    unit_cost_minor is null
    or (
      unit_cost_minor > 0
      and unit_cost_minor <= 99999999999999
    )
  ),
  line_total_minor bigint not null check (
    line_total_minor > 0
    and line_total_minor <= 99999999999999
  ),
  created_at timestamptz not null default now()
);

create index if not exists sale_items_transaction_idx
  on public.sale_items (transaction_id, id);

create index if not exists sale_items_business_product_idx
  on public.sale_items (business_id, product_id);

create table if not exists public.stock_movements (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  product_id uuid not null references public.products (id) on delete restrict,
  created_by uuid not null references public.profiles (id),
  idempotency_key uuid not null,
  movement_type text not null check (
    movement_type in (
      'opening',
      'received',
      'sold',
      'customer_return',
      'return_damaged',
      'damaged',
      'adjustment_increase',
      'adjustment_decrease',
      'reversal'
    )
  ),
  quantity_milli bigint not null check (
    quantity_milli > 0
    and quantity_milli <= 999999999999
  ),
  quantity_delta_milli bigint not null check (
    quantity_delta_milli between -999999999999 and 999999999999
  ),
  resulting_quantity_milli bigint not null check (
    resulting_quantity_milli >= 0
    and resulting_quantity_milli <= 999999999999
  ),
  unit_cost_minor bigint check (
    unit_cost_minor is null
    or (
      unit_cost_minor > 0
      and unit_cost_minor <= 99999999999999
    )
  ),
  reason text check (
    reason is null
    or char_length(btrim(reason)) between 1 and 200
  ),
  notes text check (
    notes is null
    or char_length(btrim(notes)) <= 500
  ),
  reference text check (
    reference is null
    or char_length(btrim(reference)) <= 80
  ),
  transaction_id uuid references public.transactions (id) on delete set null,
  reverses_movement_id uuid references public.stock_movements (id) on delete restrict,
  created_at timestamptz not null default now(),
  constraint stock_movements_idempotency_unique unique (business_id, idempotency_key),
  constraint stock_movements_delta_matches_type check (
    (
      movement_type in (
        'opening',
        'received',
        'customer_return',
        'adjustment_increase'
      )
      and quantity_delta_milli = quantity_milli
    )
    or (
      movement_type in ('sold', 'damaged', 'adjustment_decrease')
      and quantity_delta_milli = -quantity_milli
    )
    or (
      movement_type in ('return_damaged')
      and quantity_delta_milli = 0
    )
    or movement_type = 'reversal'
  )
);

create unique index if not exists stock_movements_opening_once
  on public.stock_movements (product_id)
  where movement_type = 'opening';

create unique index if not exists stock_movements_reversal_once
  on public.stock_movements (reverses_movement_id)
  where reverses_movement_id is not null;

create index if not exists stock_movements_product_created_idx
  on public.stock_movements (product_id, created_at desc, id desc);

create index if not exists stock_movements_business_created_idx
  on public.stock_movements (business_id, created_at desc, id desc);

create or replace function private.set_product_defaults()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  if not private.owns_business(new.business_id) then
    raise exception 'Business not found or not owned by the signed-in user';
  end if;

  if tg_op = 'INSERT' then
    new.created_by := (select auth.uid());
    if current_setting('kgwebo.allow_stock_update', true) is distinct from '1' then
      new.stock_quantity_milli := 0;
    end if;
  elsif tg_op = 'UPDATE' then
    new.business_id := old.business_id;
    new.created_by := old.created_by;
    if current_setting('kgwebo.allow_stock_update', true) is distinct from '1' then
      new.stock_quantity_milli := old.stock_quantity_milli;
    end if;
  end if;

  new.name := btrim(new.name);
  if new.sku is not null then
    new.sku := nullif(btrim(new.sku), '');
  end if;
  if new.description is not null then
    new.description := nullif(btrim(new.description), '');
  end if;
  new.updated_at := now();
  return new;
end;
$$;

create or replace function private.prevent_product_history_delete()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
  if exists (
    select 1 from public.stock_movements m where m.product_id = old.id
  ) or exists (
    select 1 from public.sale_items s where s.product_id = old.id
  ) then
    raise exception 'Archive this product instead of deleting it. It has stock or sale history.';
  end if;
  return old;
end;
$$;

create or replace function private.whole_unit_required(p_unit text)
returns boolean
language sql
immutable
set search_path = public
as $$
  select p_unit in ('each', 'pack');
$$;

create or replace function private.line_amount_minor(
  p_quantity_milli bigint,
  p_unit_minor bigint
)
returns bigint
language sql
immutable
set search_path = public
as $$
  select (p_quantity_milli * p_unit_minor) / 1000;
$$;

create or replace function private.apply_stock_movement(
  p_business_id uuid,
  p_product_id uuid,
  p_movement_type text,
  p_quantity_milli bigint,
  p_idempotency_key uuid,
  p_unit_cost_minor bigint default null,
  p_reason text default null,
  p_notes text default null,
  p_reference text default null,
  p_transaction_id uuid default null,
  p_reverses_movement_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor uuid := (select auth.uid());
  v_product public.products%rowtype;
  v_existing public.stock_movements%rowtype;
  v_original public.stock_movements%rowtype;
  v_delta bigint;
  v_resulting bigint;
  v_reason text := nullif(btrim(coalesce(p_reason, '')), '');
  v_notes text := nullif(btrim(coalesce(p_notes, '')), '');
  v_reference text := nullif(btrim(coalesce(p_reference, '')), '');
  v_new_cost bigint;
  v_movement public.stock_movements%rowtype;
begin
  if v_actor is null then
    raise exception 'Not authenticated';
  end if;
  if not private.owns_business(p_business_id) then
    raise exception 'Business not found or not owned by the signed-in user';
  end if;
  if p_quantity_milli is null or p_quantity_milli <= 0 then
    raise exception 'Quantity must be greater than zero';
  end if;

  select *
    into v_existing
  from public.stock_movements
  where business_id = p_business_id
    and idempotency_key = p_idempotency_key;

  if found then
    select * into v_product from public.products where id = v_existing.product_id;
    return jsonb_build_object(
      'movement', to_jsonb(v_existing),
      'product', to_jsonb(v_product)
    );
  end if;

  select *
    into v_product
  from public.products
  where id = p_product_id
    and business_id = p_business_id
  for update;

  if not found then
    raise exception 'Product not found or not owned by the signed-in user';
  end if;

  if private.whole_unit_required(v_product.unit_of_measure)
     and (p_quantity_milli % 1000) <> 0 then
    raise exception 'This product is counted in whole units';
  end if;

  if p_movement_type in (
    'damaged',
    'return_damaged',
    'adjustment_increase',
    'adjustment_decrease'
  ) and v_reason is null then
    raise exception 'A reason is required for this stock correction';
  end if;

  if p_movement_type = 'reversal' then
    if p_reverses_movement_id is null then
      raise exception 'A reversal must reference the original movement';
    end if;
    select *
      into v_original
    from public.stock_movements
    where id = p_reverses_movement_id
      and business_id = p_business_id
      and product_id = p_product_id
    for update;
    if not found then
      raise exception 'Original stock movement was not found';
    end if;
    if exists (
      select 1
      from public.stock_movements r
      where r.reverses_movement_id = v_original.id
    ) then
      raise exception 'This stock movement has already been reversed';
    end if;
    v_delta := -v_original.quantity_delta_milli;
    if p_quantity_milli <> v_original.quantity_milli then
      raise exception 'Reversal quantity must match the original movement';
    end if;
  else
    v_delta := case p_movement_type
      when 'opening' then p_quantity_milli
      when 'received' then p_quantity_milli
      when 'customer_return' then p_quantity_milli
      when 'adjustment_increase' then p_quantity_milli
      when 'sold' then -p_quantity_milli
      when 'damaged' then -p_quantity_milli
      when 'adjustment_decrease' then -p_quantity_milli
      when 'return_damaged' then 0
      else null
    end;
    if v_delta is null then
      raise exception 'Unknown stock movement type';
    end if;
  end if;

  v_resulting := v_product.stock_quantity_milli + v_delta;
  if v_resulting < 0 then
    raise exception 'There is not enough stock for this movement';
  end if;

  insert into public.stock_movements (
    business_id,
    product_id,
    created_by,
    idempotency_key,
    movement_type,
    quantity_milli,
    quantity_delta_milli,
    resulting_quantity_milli,
    unit_cost_minor,
    reason,
    notes,
    reference,
    transaction_id,
    reverses_movement_id
  ) values (
    p_business_id,
    p_product_id,
    v_actor,
    p_idempotency_key,
    p_movement_type,
    p_quantity_milli,
    v_delta,
    v_resulting,
    p_unit_cost_minor,
    v_reason,
    v_notes,
    v_reference,
    p_transaction_id,
    p_reverses_movement_id
  )
  returning * into v_movement;

  v_new_cost := v_product.unit_cost_minor;
  if p_movement_type in ('opening', 'received', 'adjustment_increase')
     and p_unit_cost_minor is not null then
    if v_product.stock_quantity_milli <= 0 or v_product.unit_cost_minor is null then
      v_new_cost := p_unit_cost_minor;
    else
      v_new_cost := (
        (v_product.stock_quantity_milli * v_product.unit_cost_minor)
        + (p_quantity_milli * p_unit_cost_minor)
      ) / (v_product.stock_quantity_milli + p_quantity_milli);
    end if;
  end if;

  perform set_config('kgwebo.allow_stock_update', '1', true);
  update public.products
     set stock_quantity_milli = v_resulting,
         unit_cost_minor = v_new_cost
   where id = v_product.id;

  select * into v_product from public.products where id = v_product.id;

  return jsonb_build_object(
    'movement', to_jsonb(v_movement),
    'product', to_jsonb(v_product)
  );
end;
$$;

create or replace function public.record_stock_movement(
  p_business_id uuid,
  p_product_id uuid,
  p_movement_type text,
  p_quantity_milli bigint,
  p_idempotency_key uuid,
  p_unit_cost_minor bigint default null,
  p_reason text default null,
  p_notes text default null,
  p_reference text default null,
  p_reverses_movement_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_movement_type = 'sold' then
    raise exception 'Product sales must use record_product_sale';
  end if;
  return private.apply_stock_movement(
    p_business_id,
    p_product_id,
    p_movement_type,
    p_quantity_milli,
    p_idempotency_key,
    p_unit_cost_minor,
    p_reason,
    p_notes,
    p_reference,
    null,
    p_reverses_movement_id
  );
end;
$$;

create or replace function public.create_catalog_product(
  p_business_id uuid,
  p_name text,
  p_selling_price_minor bigint,
  p_unit_of_measure text,
  p_sku text default null,
  p_description text default null,
  p_unit_cost_minor bigint default null,
  p_low_stock_threshold_milli bigint default null,
  p_opening_quantity_milli bigint default null,
  p_opening_unit_cost_minor bigint default null,
  p_opening_idempotency_key uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_product public.products%rowtype;
  v_result jsonb;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;
  if not private.owns_business(p_business_id) then
    raise exception 'Business not found or not owned by the signed-in user';
  end if;

  insert into public.products (
    business_id,
    name,
    sku,
    description,
    selling_price_minor,
    unit_cost_minor,
    low_stock_threshold_milli,
    unit_of_measure
  ) values (
    p_business_id,
    p_name,
    p_sku,
    p_description,
    p_selling_price_minor,
    p_unit_cost_minor,
    p_low_stock_threshold_milli,
    p_unit_of_measure
  )
  returning * into v_product;

  if p_opening_quantity_milli is not null then
    if p_opening_idempotency_key is null then
      raise exception 'Opening stock needs an idempotency key';
    end if;
    v_result := private.apply_stock_movement(
      p_business_id,
      v_product.id,
      'opening',
      p_opening_quantity_milli,
      p_opening_idempotency_key,
      coalesce(p_opening_unit_cost_minor, p_unit_cost_minor),
      null,
      null,
      'Opening stock',
      null,
      null
    );
    return v_result || jsonb_build_object('product', v_result->'product');
  end if;

  return jsonb_build_object('product', to_jsonb(v_product), 'movement', null);
end;
$$;

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

    v_line_key := (
      ('x' || substr(
        md5(p_idempotency_key::text || ':' || v_ordinal::text || ':' || v_product.id::text),
        1,
        32
      ))::bit(128)::uuid
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
    v_key := (
      ('x' || substr(md5(old.id::text || v_sold.id::text || 'reverse'), 1, 32))::bit(128)::uuid
    );
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

create or replace function private.guard_product_sale_amount()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_sum bigint;
begin
  if tg_op = 'UPDATE' and new.type = 'sale' then
    select coalesce(sum(line_total_minor), 0)
      into v_sum
    from public.sale_items
    where transaction_id = new.id;
    if v_sum > 0 and new.amount_minor is distinct from v_sum then
      raise exception 'A product sale amount must match its line items';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists products_set_defaults on public.products;
create trigger products_set_defaults
  before insert or update on public.products
  for each row execute function private.set_product_defaults();

drop trigger if exists products_prevent_history_delete on public.products;
create trigger products_prevent_history_delete
  before delete on public.products
  for each row execute function private.prevent_product_history_delete();

drop trigger if exists transactions_reverse_sale_inventory on public.transactions;
create trigger transactions_reverse_sale_inventory
  before delete on public.transactions
  for each row execute function private.reverse_sale_inventory();

drop trigger if exists transactions_guard_product_sale_amount on public.transactions;
create trigger transactions_guard_product_sale_amount
  before update on public.transactions
  for each row execute function private.guard_product_sale_amount();

alter table public.products enable row level security;
alter table public.products force row level security;
alter table public.sale_items enable row level security;
alter table public.sale_items force row level security;
alter table public.stock_movements enable row level security;
alter table public.stock_movements force row level security;

revoke all on table public.products from public, anon, authenticated;
grant select, insert, update, delete on table public.products to authenticated;

revoke all on table public.sale_items from public, anon, authenticated;
grant select on table public.sale_items to authenticated;

revoke all on table public.stock_movements from public, anon, authenticated;
grant select on table public.stock_movements to authenticated;

drop policy if exists products_select_own on public.products;
create policy products_select_own
  on public.products
  for select
  to authenticated
  using (private.owns_business(business_id));

drop policy if exists products_insert_own on public.products;
create policy products_insert_own
  on public.products
  for insert
  to authenticated
  with check (private.owns_business(business_id));

drop policy if exists products_update_own on public.products;
create policy products_update_own
  on public.products
  for update
  to authenticated
  using (private.owns_business(business_id))
  with check (private.owns_business(business_id));

drop policy if exists products_delete_own on public.products;
create policy products_delete_own
  on public.products
  for delete
  to authenticated
  using (private.owns_business(business_id));

drop policy if exists sale_items_select_own on public.sale_items;
create policy sale_items_select_own
  on public.sale_items
  for select
  to authenticated
  using (private.owns_business(business_id));

drop policy if exists stock_movements_select_own on public.stock_movements;
create policy stock_movements_select_own
  on public.stock_movements
  for select
  to authenticated
  using (private.owns_business(business_id));

revoke all on function private.set_product_defaults() from public, anon;
revoke all on function private.prevent_product_history_delete() from public, anon;
revoke all on function private.whole_unit_required(text) from public, anon;
revoke all on function private.line_amount_minor(bigint, bigint) from public, anon;
revoke all on function private.apply_stock_movement(uuid, uuid, text, bigint, uuid, bigint, text, text, text, uuid, uuid) from public, anon;
revoke all on function private.reverse_sale_inventory() from public, anon;
revoke all on function private.guard_product_sale_amount() from public, anon;
revoke all on function public.record_stock_movement(uuid, uuid, text, bigint, uuid, bigint, text, text, text, uuid) from public, anon;
revoke all on function public.create_catalog_product(uuid, text, bigint, text, text, text, bigint, bigint, bigint, bigint, uuid) from public, anon;
revoke all on function public.record_product_sale(uuid, uuid, timestamptz, text, text, text, text, jsonb) from public, anon;

grant execute on function private.set_product_defaults() to authenticated;
grant execute on function private.prevent_product_history_delete() to authenticated;
grant execute on function public.record_stock_movement(uuid, uuid, text, bigint, uuid, bigint, text, text, text, uuid) to authenticated;
grant execute on function public.create_catalog_product(uuid, text, bigint, text, text, text, bigint, bigint, bigint, bigint, uuid) to authenticated;
grant execute on function public.record_product_sale(uuid, uuid, timestamptz, text, text, text, text, jsonb) to authenticated;
grant execute on function private.reverse_sale_inventory() to authenticated;
grant execute on function private.guard_product_sale_amount() to authenticated;
