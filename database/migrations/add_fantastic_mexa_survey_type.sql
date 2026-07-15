insert into public.survey_type (id, survey_name) overriding system value
values
  (20, 'FANTASTIC MEX-A')
on conflict (id) do update
set survey_name = excluded.survey_name;

select setval(
  pg_get_serial_sequence('public.survey_type', 'id'),
  greatest((select max(id) from public.survey_type), 100)
);
