-- OPTIONAL LIVE MODE: Supabase dashboard > SQL Editor > run this migration.
-- IMPORTANT: This migration sets up Google-authenticated membership READS only.
-- Do not give staff award permissions to the browser. Production award/redeem
-- endpoints and atomic idempotency functions must be designed, tested, and deployed separately.
create extension if not exists pgcrypto;
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default 'Coffee Club Member',
  created_at timestamptz not null default now()
);
create table if not exists public.memberships (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null unique references public.profiles(id) on delete cascade,
  member_number text not null unique,
  qr_token uuid not null unique default gen_random_uuid(),
  points_balance int not null default 0 check (points_balance >= 0),
  status text not null default 'active' check (status in ('active','suspended')),
  created_at timestamptz not null default now()
);
create table if not exists public.point_transactions (
  id uuid primary key default gen_random_uuid(),
  membership_id uuid not null references public.memberships(id),
  type text not null check (type in ('earn','redeem','adjustment','reversal')),
  points_delta int not null check (points_delta <> 0),
  purchase_amount_sen bigint not null default 0 check (purchase_amount_sen >= 0),
  description text,
  reference_code text unique,
  created_at timestamptz not null default now()
);
create index if not exists point_transactions_membership_created_idx on public.point_transactions(membership_id,created_at desc);

alter table public.profiles enable row level security;
alter table public.memberships enable row level security;
alter table public.point_transactions enable row level security;

revoke all on public.profiles,public.memberships,public.point_transactions from anon,authenticated;
grant select on public.profiles,public.memberships,public.point_transactions to authenticated;

create policy "own profile" on public.profiles for select to authenticated using (id=(select auth.uid()));
create policy "own membership" on public.memberships for select to authenticated using (profile_id=(select auth.uid()));
create policy "own transactions" on public.point_transactions for select to authenticated using (
  exists (select 1 from public.memberships m where m.id=membership_id and m.profile_id=(select auth.uid()))
);

-- SECURITY DEFINER trigger only runs inside Supabase auth insert transaction.
-- No public insert grant or direct client write access is provided.
create or replace function public.create_member_on_signup()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  new_number text;
begin
  insert into public.profiles(id,full_name)
  values(new.id,coalesce(nullif(new.raw_user_meta_data->>'full_name',''),new.email,'Coffee Club Member'))
  on conflict(id) do nothing;
  -- UUID-based membership number avoids sequence lookup/guessable member IDs.
  new_number:='RR-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
  insert into public.memberships(profile_id,member_number)
  values(new.id,new_number)
  on conflict(profile_id) do nothing;
  return new;
end $$;
revoke all on function public.create_member_on_signup() from public,anon,authenticated;
drop trigger if exists on_coffee_auth_user_created on auth.users;
create trigger on_coffee_auth_user_created after insert on auth.users
for each row execute function public.create_member_on_signup();

-- Backfill authenticated users created before running migration.
insert into public.profiles(id,full_name)
select id,coalesce(nullif(raw_user_meta_data->>'full_name',''),email,'Coffee Club Member') from auth.users on conflict(id) do nothing;
insert into public.memberships(profile_id,member_number)
select u.id,'RR-'||upper(substr(replace(u.id::text,'-',''),1,12))
from auth.users u on conflict(profile_id) do nothing;
