-- Add optional investigation linkage to surveys records.
alter table if exists public.surveys
  add column if not exists investigation_id integer references public.investigations(id);

create index if not exists idx_surveys_investigation_id on public.surveys(investigation_id);
create index if not exists idx_surveys_patient_investigation on public.surveys(patient_id, investigation_id);

