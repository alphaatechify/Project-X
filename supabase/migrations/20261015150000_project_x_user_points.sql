-- ==============================================================================
-- PROJECT X: USER POINTS & REWARDS SYSTEM (POINTS TABLES)
-- Supports customer loyalty points, rewards on completed bookings & redemption
-- ==============================================================================

-- 1. User Points Balance & Tier
create table if not exists public.user_points (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles(id) on delete cascade,
  available_points int not null default 0 check (available_points >= 0),
  lifetime_points_earned int not null default 0 check (lifetime_points_earned >= 0),
  tier text not null default 'silver' check (tier in ('bronze','silver','gold','platinum')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists user_points_user_idx on public.user_points(user_id);

-- 2. Point Transactions Ledger
create table if not exists public.point_transactions (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  booking_id uuid references public.bookings(id) on delete set null,
  points int not null,
  type text not null check (type in ('earned','redeemed','expired','bonus','refund')),
  description text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create index if not exists point_tx_user_idx on public.point_transactions(user_id, created_at desc);

-- 3. Row Level Security
alter table public.user_points enable row level security;
alter table public.point_transactions enable row level security;

create policy "User points select" on public.user_points
  for select using (user_id = auth.uid() or public.is_admin(auth.uid()));

create policy "User points update" on public.user_points
  for update using (user_id = auth.uid() or public.is_admin(auth.uid()));

create policy "Point transactions select" on public.point_transactions
  for select using (user_id = auth.uid() or public.is_admin(auth.uid()));

create policy "Point transactions insert" on public.point_transactions
  for insert with check (user_id = auth.uid() or public.is_admin(auth.uid()));

-- 4. Automatic updated_at trigger
drop trigger if exists set_updated_at on public.user_points;
create trigger set_updated_at
  before update on public.user_points
  for each row execute function public.set_updated_at();

-- 5. RPC to credit points on booking completion
create or replace function public.award_booking_points(
  p_booking_id uuid,
  p_points_multiplier numeric default 0.05 -- 5% of amount in points
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_booking record;
  v_points_earned int;
begin
  select * into v_booking from public.bookings where id = p_booking_id;
  if v_booking.id is null then raise exception 'Booking not found'; end if;
  if v_booking.status != 'completed' then raise exception 'Booking must be completed to award points'; end if;

  -- 1 INR = 100 paise; 1 point per 20 INR spent
  v_points_earned := greatest(10, floor((v_booking.total_paise / 100) * p_points_multiplier)::int);

  -- Upsert user points
  insert into public.user_points (user_id, available_points, lifetime_points_earned)
  values (v_booking.customer_id, v_points_earned, v_points_earned)
  on conflict (user_id) do update set
    available_points = public.user_points.available_points + excluded.available_points,
    lifetime_points_earned = public.user_points.lifetime_points_earned + excluded.lifetime_points_earned,
    updated_at = now();

  -- Record transaction ledger
  insert into public.point_transactions (
    user_id,
    booking_id,
    points,
    type,
    description,
    metadata
  ) values (
    v_booking.customer_id,
    p_booking_id,
    v_points_earned,
    'earned',
    format('Reward points for completed booking #%s', v_booking.booking_number),
    jsonb_build_object('booking_id', p_booking_id, 'total_paise', v_booking.total_paise)
  );

  return jsonb_build_object(
    'success', true,
    'user_id', v_booking.customer_id,
    'points_earned', v_points_earned
  );
end;
$$;

grant execute on function public.award_booking_points(uuid, numeric) to authenticated;
