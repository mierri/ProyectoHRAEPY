# Backend API Reference (Actualizada)

## Alcance
Documento de referencia para componentes backend activos tras la migracion feature-first.

## Servicios y repositorios vigentes

### Encuestas
Archivo: `lib/features/surveys/domain/survey_service.dart`

Metodos principales:
- `loadSurveys()`
- `saveSurvey(SurveyModel survey)`
- `getCompletedSurveys()`
- `getStatistics()`
- `getSurveysByType(int surveyType)`

### Repositorio de encuestas
Archivo: `lib/features/surveys/data/survey_repository.dart`

Contrato principal (`SurveyRepositoryContract`):
- `loadSurveys()`
- `saveSurveyLocally(SurveyModel survey)`
- `syncSurveyToSupabase(SurveyModel survey)`
- `getAllSurveysFromSupabase()`
- `syncPendingSurveys()`
- `syncPatientToSupabase(PatientModel patient)`

### Pacientes
Archivo: `lib/features/patients/data/patient_repository.dart`

Servicio/Repositorio de pacientes con CRUD local + sincronizacion remota.

### Sincronizacion transversal
Archivo: `lib/shared/services/sync_service.dart`

Metodos:
- `syncAll()`
- `syncPendingOnly()`
- `downloadFromServer()`
- `getStats()`
- `hasPendingSync()`

## Modelos de datos
- `lib/shared/models/patient_model.dart`
- `lib/shared/models/survey_model.dart`
- `lib/shared/models/response_model.dart`

## Flujo recomendado
1. Cargar datos con servicios de feature.
2. Guardar local + intentar sync en use case/repositorio.
3. Usar `SyncService` para sincronizacion global.

## Cambios importantes
Se eliminaron APIs legacy basadas en `DatabaseHelper`, `provider/*` y `Services/*`.
Este documento reemplaza esas referencias.
