# Almacenamiento Offline (Estado Actual)

La app trabaja en modo offline-first usando Hive como almacenamiento local y Supabase como backend remoto.

## Componentes activos

### Modelos Hive
- `lib/shared/models/patient_model.dart`
- `lib/shared/models/survey_model.dart`
- `lib/shared/models/response_model.dart`

### Repositorios/servicios
- `lib/features/surveys/data/survey_repository.dart`
- `lib/features/surveys/domain/survey_service.dart`
- `lib/features/patients/data/patient_repository.dart`
- `lib/shared/services/sync_service.dart`

## Comportamiento

### Guardado de encuestas
1. Se persiste localmente en Hive.
2. Se intenta sincronizacion con Supabase.
3. Si falla la red, queda pendiente y se conserva en local.

### Carga de encuestas
1. Se intenta obtener remoto.
2. Se consolida con local para evitar perdida de datos.
3. Se ordena por fecha de creacion.

### Sincronizacion pendiente
- `syncPendingToServer()` envia pendientes locales.
- `downloadFromServer()` trae cambios remotos para consolidar.

## Estado de sincronizacion
Cada entidad mantiene bandera de sincronizacion:
- `synced: true` -> ya consolidado en servidor.
- `synced: false` -> pendiente de envio.

## Inicializacion
En `main.dart`:
1. Inicializar Supabase.
2. Inicializar Hive.
3. Registrar adapters de `PatientModel`, `SurveyModel`, `ResponseModel`.

## Limpieza de arquitectura
Las capas legacy de offline/storage fueron retiradas:
- `lib/provider/**`
- `lib/Services/**`

Toda la operacion actual de offline y sync vive en `features/*`, `shared/*` y `core/*`.
