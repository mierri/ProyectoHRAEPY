# Refactorizacion Abril 2026

## Objetivo
Consolidar separacion de responsabilidades por capas sin romper contratos publicos consumidos por widgets, manteniendo `ChangeNotifier` y navegacion con `GoRouter`.

## Resumen ejecutivo
- `SurveyService` quedo como coordinador de alto nivel con API minima.
- Se elimino duplicacion en controllers con `BaseSurveyController`.
- `ConsentFormScreen` delega logica de negocio en `ConsentFormController`.
- Sincronizacion centralizada en `SyncService` mediante contrato `ISyncable`.
- `PatientModel` delega mapeo de genero a `GenderMapper`.

## Cambios por fase

### Fase 1 - Servicios (Survey)
Archivos clave:
- `lib/Services/survey_service.dart`
- `lib/Services/surveys/survey_rules.dart`
- `lib/Services/surveys/survey_catalog.dart`

Resultado:
- `SurveyService` mantiene solo 5 metodos publicos:
  - `loadSurveys()`
  - `saveSurvey()`
  - `getCompletedSurveys()`
  - `getStatistics()`
  - `getSurveysByType()`
- Catalogo y reglas estadisticas quedan en `SurveyCatalog`/`SurveyRules`.
- Operaciones de sincronizacion quedaron fuera de `SurveyService`.

### Fase 2 - Controllers (eliminar duplicacion)
Archivos clave:
- `lib/controllers/base_survey_controller.dart`
- `lib/controllers/survey_controller.dart`
- `lib/controllers/sf36_controller.dart`
- `lib/controllers/whoqol_controller.dart`

Resultado:
- Se centralizo estado de guardado, construccion de respuestas y manejo de errores.
- `SurveyController`, `SF36Controller` y `WhoqolController` extienden `BaseSurveyController`.
- `SurveyController` delega calculo de riesgo a `OsteoporosisRiskService.calculateRisk(...)`.

### Fase 3 - UI (Consentimiento)
Archivos clave:
- `lib/controllers/consent_form_controller.dart`
- `lib/config/survey_type_config.dart`
- `lib/screens/consent_form_screen.dart`

Resultado:
- `ConsentFormScreen` queda enfocada en render y navegacion.
- Estado del formulario, validaciones y submit movidos a `ConsentFormController`.
- Colores, descripciones e instrucciones por tipo centralizados en `SurveyTypeConfig`.

### Fase 4 - Sincronizacion centralizada
Archivos clave:
- `lib/Services/contracts/syncable.dart`
- `lib/Services/sync_service.dart`
- `lib/Services/patient_service.dart`
- `lib/Services/surveys/survey_repository.dart`
- `lib/screens/dashboard_screen.dart`
- `lib/screens/settings_screen.dart`

Resultado:
- `ISyncable` define `syncPendingToServer()` y `downloadFromServer()`.
- `PatientService` y `SurveyRepository` implementan `ISyncable`.
- `SyncService` es el punto unico para:
  - `downloadFromServer()`
  - `syncPendingOnly()`
  - `syncAll()`
- Dashboard/Settings ya no orquestan sincronizacion por separado.

### Fase 5 - Modelo de paciente
Archivos clave:
- `lib/models/patient_model.dart`
- `lib/utils/gender_mapper.dart`

Resultado:
- Mapeo de genero extraido a `GenderMapper`.
- `PatientModel.toJson()/fromJson()` usan `GenderMapper`.
- Getter `age` permanece en el modelo, documentado como calculo derivado sin side effects.

## Compatibilidad y restricciones cumplidas
- Se mantuvo `Provider` + `ChangeNotifier`.
- No se cambio `GoRouter` ni rutas existentes.
- No se tocaron archivos `.g.dart`.
- No se introdujeron dependencias externas nuevas.

## Riesgos y notas
- Existen providers legacy (`lib/provider/*`) para flujos antiguos; no son el camino principal en la nueva orquestacion.
- Para nuevas funcionalidades de sincronizacion, usar solo `SyncService`.

## Validacion
- Tests ejecutados despues del refactor: suite en verde tras ajustar `test/widget_test.dart` al estado real de la app.
