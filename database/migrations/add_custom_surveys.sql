-- Add support for custom surveys created by the doctor in-app.

create table if not exists public.custom_surveys (
  id bigint primary key,
  title text not null,
  description text,
  color_hex text,
  definition jsonb not null,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

alter table if exists public.surveys
  add column if not exists custom_survey_id bigint references public.custom_surveys(id);

create index if not exists idx_surveys_custom_survey_id on public.surveys(custom_survey_id);

-- Register survey_type 100 ("custom") in the survey_type lookup table so
-- inserts into surveys with survey_type = 100 satisfy fk_survey_type.
insert into public.survey_type (id, survey_name) overriding system value
values (100, 'Encuesta personalizada')
on conflict (id) do nothing;

-- Advance the identity sequence past 100 so future auto-generated
-- survey_type ids never collide with the reserved "custom" id.
select setval(
  pg_get_serial_sequence('public.survey_type', 'id'),
  greatest((select max(id) from public.survey_type), 100)
);
