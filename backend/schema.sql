-- MY MANAGER.AI - CREATOR OS SCHEMA v1.0
-- Stack: Supabase (PostgreSQL)
-- Security: RLS Enabled on ALL tables

-- 1. USERS & PROFILES (Extension of Auth)
create table public.profiles (
  id uuid references auth.users not null primary key,
  handle text unique,
  niche text,
  audience_size int,
  potential_revenue numeric default 0,
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.profiles enable row level security;

create policy "Users can view own profile" on profiles
  for select using (auth.uid() = id);

create policy "Users can update own profile" on profiles
  for update using (auth.uid() = id);

-- 2. BRAND DEALS (CRM Core)
create type deal_status as enum ('prospecting', 'negotiation', 'contract_sent', 'active', 'completed', 'lost');

create table public.brand_deals (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) not null,
  brand_name text not null,
  contact_email text,
  status deal_status default 'prospecting',
  value numeric default 0,
  deliverables jsonb default '[]'::jsonb, -- e.g. [{"type": "reel", "price": 500}]
  expected_close_date date,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.brand_deals enable row level security;

create policy "Users can manage own deals" on brand_deals
  for all using (auth.uid() = user_id);

-- 3. FINANCIAL RECORDS (Cashflow)
create type transaction_type as enum ('income', 'expense');
create table public.financial_records (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) not null,
  deal_id uuid references public.brand_deals(id), -- Optional link to deal
  amount numeric not null,
  type transaction_type not null,
  description text,
  due_date date,
  is_paid boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.financial_records enable row level security;

create policy "Users can manage own financials" on financial_records
  for all using (auth.uid() = user_id);

-- 4. OUTREACH ENGINE (Token 2 - Email Queue)
create type email_status as enum ('pending', 'sent', 'failed', 'replied');

create table public.email_queue (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) not null,
  deal_id uuid references public.brand_deals(id) not null,
  recipient_email text not null,
  subject text not null,
  body_html text not null,
  scheduled_for timestamp with time zone default now(),
  status email_status default 'pending',
  thread_id text, -- Gmail Thread ID for continuity
  attempts int default 0,
  last_error text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.email_queue enable row level security;

create policy "Users can view own queue" on email_queue
  for select using (auth.uid() = user_id);

-- 5. LEGAL ENGINE (Token 3 - Contract Templates)
create table public.contract_templates (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id), -- Null means System Template (Global)
  name text not null,
  gdrive_file_id text not null, -- Google Doc Template ID
  clauses_mapping jsonb default '{}'::jsonb, -- dynamic insertion rules
  is_public boolean default false
);

alter table public.contract_templates enable row level security;

create policy "Users manage own templates" on contract_templates
  for all using (auth.uid() = user_id);

create policy "Users view public templates" on contract_templates
  for select using (is_public = true);

-- 6. GENERATED CONTENT (Vault / Viral Hub)
create table public.generated_content (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) not null,
  content_type text not null, -- 'script', 'pitch', 'audit_report'
  content_body text,
  meta_data jsonb default '{}'::jsonb,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.generated_content enable row level security;

create policy "Users manage own content" on generated_content
  for all using (auth.uid() = user_id);

-- TRIGGER: Auto-create profile on signup
create or replace function public.handle_new_user() 
returns trigger as \$\$
begin
  insert into public.profiles (id, handle)
  values (new.id, new.email);
  return new;
end;
\$\$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
