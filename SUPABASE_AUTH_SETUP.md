# Supabase Auth setup

## 1. Variables de entorno

Create or update `.env` in the project root:

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-public-anon-key
```

The anon key is safe to ship in a web client only when Row Level Security is enabled and policies are correct. Never put the `service_role` key in Flutter, Vercel frontend variables, or browser code.

## 2. Dashboard settings

In Supabase Dashboard:

1. Go to **Authentication > Sign In / Providers** and enable **Email**.
2. In production, keep email confirmation enabled and configure **Authentication > SMTP Settings** with your own SMTP provider.
3. Go to **Authentication > Rate Limits** and keep conservative limits for password login, signup, password recovery, and OTP/email flows.
4. Go to **Authentication > Security > Password Security** and enable strong password rules plus leaked password protection when available for your plan.
5. Add your deployed URL and local development URL in **Authentication > URL Configuration**.

Recommended web URLs:

```text
Site URL: https://your-domain.com
Redirect URLs:
http://localhost:*
https://your-domain.com/**
```

## 3. Database security

Run this migration in the Supabase SQL editor:

```text
database/migrations/20260715_auth_profiles_rls.sql
```

For every table that the web app reads or writes from Supabase:

1. Enable RLS.
2. Use policies with `auth.uid()` or trusted claims from `auth.jwt()`.
3. Do not expose writes to `anon`.
4. Keep the `service_role` key only on trusted backend jobs.

Template for user-owned rows:

```sql
alter table public.your_table enable row level security;
alter table public.your_table force row level security;

create policy "select_own_rows"
on public.your_table
for select
to authenticated
using (owner_id = auth.uid());

create policy "insert_own_rows"
on public.your_table
for insert
to authenticated
with check (owner_id = auth.uid());
```

## 4. SQL injection posture

The Flutter app authenticates with `supabase_flutter` and does not concatenate SQL. Keep that rule for new data access:

- Prefer Supabase query builders like `.from('table').select().eq(...)`.
- If you add Postgres functions/RPC, validate inputs and use parameters.
- Avoid dynamic SQL in PL/pgSQL; if unavoidable, use `format('%I', identifier)` for identifiers and `USING` for values.

## 5. Create users

Create users from **Authentication > Users** or your secure admin backend. To make a user an admin, set app metadata with a trusted server/service-role context:

```json
{
  "role": "admin"
}
```

The app reads `app_metadata.role`; do not use `user_metadata.role` for authorization because users can modify their own user metadata.
