-- Ask rate windows are not a public table. The RPC is service-role only.

create schema if not exists private;

create table if not exists private.copilot_rate_windows (
  user_id uuid primary key,
  window_start timestamptz not null default now(),
  hit_count integer not null default 0 check (hit_count >= 0)
);

create or replace function public.kgwebo_touch_copilot_rate(
  p_user_id uuid,
  p_limit integer default 40,
  p_window_seconds integer default 600
)
returns boolean
language plpgsql
security definer
set search_path = private, public
as $$
declare
  win private.copilot_rate_windows%rowtype;
  expired boolean;
begin
  if p_user_id is null or p_limit < 1 or p_window_seconds < 1 then
    return false;
  end if;

  insert into private.copilot_rate_windows (user_id, window_start, hit_count)
  values (p_user_id, now(), 0)
  on conflict (user_id) do nothing;

  select * into win
  from private.copilot_rate_windows
  where user_id = p_user_id
  for update;

  expired := win.window_start < now() - make_interval(secs => p_window_seconds);
  if expired then
    update private.copilot_rate_windows
    set window_start = now(), hit_count = 1
    where user_id = p_user_id;
    return true;
  end if;

  if win.hit_count >= p_limit then
    return false;
  end if;

  update private.copilot_rate_windows
  set hit_count = hit_count + 1
  where user_id = p_user_id;
  return true;
end;
$$;

alter table private.copilot_rate_windows enable row level security;

revoke all on table private.copilot_rate_windows from public, anon, authenticated;

revoke all on function public.kgwebo_touch_copilot_rate(uuid, integer, integer)
from public, anon, authenticated;
grant execute on function public.kgwebo_touch_copilot_rate(uuid, integer, integer)
to service_role;
