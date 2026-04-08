# Backend Completado - Estado Actual

## Estado
Backend funcional en arquitectura feature-first con persistencia local (Hive) y sincronizacion con Supabase.

## Modulos vigentes

### Core
- `lib/core/supabase/supabase_config.dart`
- `lib/core/network/connectivity_service.dart`
- `lib/core/network/network_executor.dart`
- `lib/core/logger/app_logger.dart`

### Shared
- `lib/shared/models/patient_model.dart`
- `lib/shared/models/survey_model.dart`
- `lib/shared/models/response_model.dart`
- `lib/shared/services/syncable.dart`
- `lib/shared/services/sync_service.dart`

### Feature Surveys
- `lib/features/surveys/data/survey_repository.dart`
- `lib/features/surveys/domain/survey_service.dart`
- `lib/features/surveys/domain/use_cases/save_survey_use_case.dart`
- `lib/features/surveys/domain/use_cases/save_osteoporosis_survey_use_case.dart`

### Feature Patients
- `lib/features/patients/data/patient_repository.dart`

## Capacidades implementadas
- Almacenamiento offline en Hive.
- Carga combinada local/remota de encuestas.
- Guardado local con intento de sincronizacion remota.
- Manejo de reintentos de red en operaciones criticas.
- Sincronizacion de pacientes y encuestas pendientes.
- Descarga remota para consolidar datos locales.

## Flujo backend principal
1. App inicializa Supabase y Hive en `main.dart`.
2. UI llama servicios de feature (`SurveyService`, `PatientService`).
3. Servicios delegan en repositorios para persistencia/sync.
4. Sync transversal se coordina mediante `ISyncable` + `SyncService`.

## Limpieza aplicada
Se eliminaron artefactos legacy que duplicaban backend:
- `lib/Services/**`
- `lib/provider/**`

## Notas
- Este documento refleja solo rutas y componentes activos.
- Para contratos y comportamiento del modulo de encuestas: ver `DOCUMENTACION_ENCUESTAS.md`.
