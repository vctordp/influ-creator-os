-- SQL Fix for Profiles RLS Error 42501
-- Run this in your Supabase SQL Editor if the error persists.

-- 1. Create table if not exists (safety)
create table if not exists public.profiles (
  id uuid references auth.users not null primary key,
  updated_at timestamp with time zone,
  handle text unique,
  niche text,
  audience_size bigint,
  potential_revenue double precision default 0
);

-- 2. Enable RLS
alter table public.profiles enable row level security;

-- 3. Create Policies

-- Allow users to SEE their own profile
create policy "Users can view own profile" 
on public.profiles for select 
using ( auth.uid() = id );

-- Allow users to INSERT their own profile
create policy "Users can insert own profile" 
on public.profiles for insert 
with check ( auth.uid() = id );

-- Allow users to UPDATE their own profile
create policy "Users can update own profile" 
on public.profiles for update 
using ( auth.uid() = id );
