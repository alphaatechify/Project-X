-- ==============================================================================
-- PROJECT X: FIX RLS INFINITE RECURSION
-- Uses SECURITY DEFINER helper functions to decouple cross-table policies
-- ==============================================================================

-- 1. Helper functions with SECURITY DEFINER to bypass RLS recursion
create or replace function public.is_provider_assigned_to_booking(p_booking_id uuid, p_user_id uuid)
returns boolean language sql stable security definer set search_path = public
as $$
  select exists (
    select 1
    from public.booking_assignments ba
    join public.provider_profiles pp on pp.id = ba.provider_id
    where ba.booking_id = p_booking_id
      and pp.user_id = p_user_id
  );
$$;

create or replace function public.is_customer_of_booking(p_booking_id uuid, p_user_id uuid)
returns boolean language sql stable security definer set search_path = public
as $$
  select exists (
    select 1
    from public.bookings
    where id = p_booking_id
      and customer_id = p_user_id
  );
$$;

grant execute on function public.is_provider_assigned_to_booking(uuid, uuid) to authenticated, anon;
grant execute on function public.is_customer_of_booking(uuid, uuid) to authenticated, anon;

-- 2. Profiles policy (Public profiles viewable by all, eliminates recursion)
drop policy if exists "Profiles select policy" on public.profiles;
create policy "Profiles select policy" on public.profiles for select using (true);

-- 3. Addresses policy
drop policy if exists "Addresses select policy" on public.addresses;
create policy "Addresses select policy" on public.addresses
  for select using (
    user_id = auth.uid()
    or public.is_admin(auth.uid())
    or exists (
      select 1 from public.bookings b
      where b.address_id = addresses.id
        and public.is_provider_assigned_to_booking(b.id, auth.uid())
    )
  );

-- 4. Bookings policies
drop policy if exists "Bookings select policy" on public.bookings;
create policy "Bookings select policy" on public.bookings
  for select using (
    customer_id = auth.uid()
    or public.is_provider_assigned_to_booking(id, auth.uid())
    or public.is_admin(auth.uid())
  );

drop policy if exists "Bookings update policy" on public.bookings;
create policy "Bookings update policy" on public.bookings
  for update using (
    customer_id = auth.uid()
    or public.is_provider_assigned_to_booking(id, auth.uid())
    or public.is_admin(auth.uid())
  );

-- 5. Booking items policies
drop policy if exists "Booking items select policy" on public.booking_items;
create policy "Booking items select policy" on public.booking_items
  for select using (
    public.is_customer_of_booking(booking_id, auth.uid())
    or public.is_provider_assigned_to_booking(booking_id, auth.uid())
    or public.is_admin(auth.uid())
  );

drop policy if exists "Booking items insert policy" on public.booking_items;
create policy "Booking items insert policy" on public.booking_items
  for insert with check (
    public.is_customer_of_booking(booking_id, auth.uid())
    or public.is_admin(auth.uid())
  );

-- 6. Booking assignments policies
drop policy if exists "Assignments select policy" on public.booking_assignments;
create policy "Assignments select policy" on public.booking_assignments
  for select using (
    exists (select 1 from public.provider_profiles pp where pp.id = booking_assignments.provider_id and pp.user_id = auth.uid())
    or public.is_customer_of_booking(booking_id, auth.uid())
    or public.is_admin(auth.uid())
  );

-- 7. Booking status events policies
drop policy if exists "Status events select policy" on public.booking_status_events;
create policy "Status events select policy" on public.booking_status_events
  for select using (
    public.is_customer_of_booking(booking_id, auth.uid())
    or public.is_provider_assigned_to_booking(booking_id, auth.uid())
    or public.is_admin(auth.uid())
  );
