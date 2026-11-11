-- Run in Supabase SQL editor. All access to these tables is via ac-api Edge Function.
create extension if not exists pgcrypto;
create table if not exists public.ac_members (
 employee_id text primary key check (employee_id ~ '^[0-9]{3,12}$'),
 display_name text not null default '',
 role text not null check (role in ('admin','member')) default 'member',
 active boolean not null default true,
 created_at timestamptz not null default now()
);
create table if not exists public.ac_sessions (
 token_hash text primary key,
 employee_id text not null references public.ac_members(employee_id),
 expires_at timestamptz not null,
 created_at timestamptz not null default now()
);
create table if not exists public.ac_records (
 collection text not null check (collection in ('units','dailyChecks','pmHistory','costs')),
 record_id text not null,
 data jsonb not null,
 updated_by text not null,
 updated_at timestamptz not null default now(),
 primary key(collection,record_id)
);
create index if not exists ac_records_collection_idx on public.ac_records(collection);
create table if not exists public.ac_audit (
 id bigint generated always as identity primary key,
 employee_id text not null,
 action text not null,
 collection text,
 record_id text,
 created_at timestamptz not null default now()
);
alter table public.ac_members enable row level security;
alter table public.ac_sessions enable row level security;
alter table public.ac_records enable row level security;
alter table public.ac_audit enable row level security;
-- Do not create anon/authenticated policies. Service role in Edge Function only.
-- Bootstrap FIRST admin manually in SQL editor, replacing 00000 with real employee ID:
-- insert into public.ac_members(employee_id,display_name,role) values ('00000','Initial Admin','admin');
