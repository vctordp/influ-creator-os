-- Notifications Table Schema
-- Run this in Supabase SQL Editor

-- 1. Create table
create table if not exists public.notifications (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  title text not null,
  message text,
  type text check (type in ('info', 'success', 'warning', 'reward')) default 'info',
  is_read boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Enable RLS
alter table public.notifications enable row level security;

-- 3. Policies
create policy "Users can view own notifications" 
on public.notifications for select 
using ( auth.uid() = user_id );

-- Allow server-side or triggers to insert (Users usually don't insert their own notifications directly, but for now we allow it for testing/gamification triggers)
create policy "Users can insert own notifications" 
on public.notifications for insert 
with check ( auth.uid() = user_id );

create policy "Users can update own notifications" 
on public.notifications for update 
using ( auth.uid() = user_id );

-- 4. Enable Realtime
alter publication supabase_realtime add table public.notifications;
