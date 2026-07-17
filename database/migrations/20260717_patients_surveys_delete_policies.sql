-- Faltaban políticas de DELETE en patients, surveys y responses: existían
-- SELECT/INSERT/UPDATE pero ningún DELETE, por lo que las peticiones de
-- borrado desde la app respondían "éxito" pero afectaban 0 filas (Postgrest/
-- Supabase no lanza error cuando RLS simplemente no matchea ninguna fila).
-- Ejecutar en el SQL editor de Supabase.

drop policy if exists "Permitir eliminar respuestas" on public.responses;
create policy "Permitir eliminar respuestas"
on public.responses
for delete
to anon, authenticated
using (true);

drop policy if exists "Permitir eliminar encuestas" on public.surveys;
create policy "Permitir eliminar encuestas"
on public.surveys
for delete
to anon, authenticated
using (true);

drop policy if exists "Permitir eliminar pacientes" on public.patients;
create policy "Permitir eliminar pacientes"
on public.patients
for delete
to anon, authenticated
using (true);
