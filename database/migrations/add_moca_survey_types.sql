-- Reuses the existing id 4 (left over from an earlier abandoned MoCA attempt)
-- as MoCA 8.1, and adds a new row for MoCA Blind.
update public.survey_type
set survey_name = 'MoCA 8.1'
where id = 4;

insert into public.survey_type (id, survey_name) overriding system value
values
  (19, 'MoCA Blind')
on conflict (id) do update
set survey_name = excluded.survey_name;

select setval(
  pg_get_serial_sequence('public.survey_type', 'id'),
  greatest((select max(id) from public.survey_type), 100)
);
