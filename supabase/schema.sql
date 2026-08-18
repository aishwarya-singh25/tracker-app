-- Habit Tracker schema
-- Run this in the Supabase SQL Editor (Project → SQL Editor → New query)

-- ─── habits ──────────────────────────────────────────────────────────────
create table if not exists public.habits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  emoji text not null,
  color text not null,                 -- hex string, e.g. '#4C6FFF'
  time_block text not null check (time_block in ('morning', 'afternoon', 'evening', 'night')),
  sort_order integer not null default 0,
  archived_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.habits enable row level security;

create policy "Users can view their own habits"
  on public.habits for select
  using (auth.uid() = user_id);

create policy "Users can insert their own habits"
  on public.habits for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own habits"
  on public.habits for update
  using (auth.uid() = user_id);

create policy "Users can delete their own habits"
  on public.habits for delete
  using (auth.uid() = user_id);

-- ─── habit_logs ──────────────────────────────────────────────────────────
create table if not exists public.habit_logs (
  id uuid primary key default gen_random_uuid(),
  habit_id uuid not null references public.habits(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  log_date date not null,
  completed_at timestamptz not null default now(),
  unique (habit_id, log_date)          -- one completion row per habit per day
);

alter table public.habit_logs enable row level security;

create policy "Users can view their own habit logs"
  on public.habit_logs for select
  using (auth.uid() = user_id);

create policy "Users can insert their own habit logs"
  on public.habit_logs for insert
  with check (auth.uid() = user_id);

create policy "Users can delete their own habit logs"
  on public.habit_logs for delete
  using (auth.uid() = user_id);

-- helpful index for streak calculation (fetching a habit's recent logs)
create index if not exists habit_logs_habit_date_idx
  on public.habit_logs (habit_id, log_date desc);

-- ─── grants ──────────────────────────────────────────────────────────────
-- RLS policies above control *which rows* a user can touch, but Postgres
-- also requires baseline table-level grants before RLS is even evaluated.
grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on public.habits to anon, authenticated;
grant select, insert, update, delete on public.habit_logs to anon, authenticated;
