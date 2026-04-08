# Documentación del subsistema de encuestas

## 1. Objetivo

Este documento describe la implementación actual (feature-first) del módulo de encuestas, incluyendo catálogo, reglas, persistencia, controladores de UI y sincronización.

## 2. Ubicación actual de código

### Núcleo de encuestas
- `lib/features/surveys/domain/survey_catalog.dart`
- `lib/features/surveys/domain/survey_rules.dart`
- `lib/features/surveys/domain/survey_service.dart`
- `lib/features/surveys/data/survey_repository.dart`
- `lib/features/surveys/domain/use_cases/save_survey_use_case.dart`
- `lib/features/surveys/domain/use_cases/save_osteoporosis_survey_use_case.dart`
- `lib/features/surveys/domain/survey_type_config.dart`

### Estrategia por tipo de encuesta
- `lib/features/surveys/core/domain/survey_type_handler.dart`
- `lib/features/surveys/core/domain/survey_type_handler_registry.dart`
- `lib/features/surveys/types/**/domain/*`

### Presentación (pantallas/controladores)
- `lib/features/surveys/presentation/consent_form_screen.dart`
- `lib/features/surveys/presentation/consent_form_controller.dart`
- `lib/features/surveys/presentation/survey_screen.dart`
- `lib/features/surveys/presentation/survey_controller.dart`
- `lib/features/surveys/presentation/assist_screen.dart`
- `lib/features/surveys/presentation/assist_controller.dart`
- `lib/features/surveys/presentation/whoqol_screen.dart`
- `lib/features/surveys/presentation/whoqol_controller.dart`
- `lib/features/surveys/presentation/sf36_screen.dart`
- `lib/features/surveys/presentation/sf36_controller.dart`
- `lib/features/surveys/presentation/moca_test_screen.dart`
- `lib/features/surveys/presentation/survey_results_screen.dart`
- `lib/features/surveys/presentation/surveys_list_screen.dart`

## 3. Responsabilidades por componente

### SurveyCatalog
Centraliza IDs, nombres, tipos y mapeo de preguntas por encuesta. Evita hardcode en pantallas.

### SurveyRules
Contiene reglas de dominio: score, estadísticas, interpretación y severidad. Delega por tipo al registry de handlers.

### SurveyTypeHandlerRegistry
Resuelve la implementación de reglas por tipo de encuesta y evita `switch` gigantes en lógica central.

### SurveyRepository
Persistencia y sincronización de encuestas:
- Hive local.
- Supabase remoto.
- Sync pendientes.
- Carga combinada local/remota.

### SaveSurveyUseCase
Orquesta flujo consistente de guardado:
1. guarda local,
2. intenta sincronización con timeout,
3. marca `synced` si aplica.

### SurveyService
Fachada de dominio para presentación. Expone operaciones de carga, filtrado, estadísticas y guardado.

### Controllers de presentación
Gestionan estado UI, navegación de preguntas, validaciones de completitud y disparan casos de uso.

## 4. Flujo actual de guardado

1. Pantalla registra respuestas.
2. Controller construye `SurveyModel`.
3. Controller llama `SurveyService.saveSurvey()`.
4. Service ejecuta `SaveSurveyUseCase`.
5. Use case delega en `SurveyRepository` para local + sync.

## 5. Extensión recomendada (nuevo tipo)

1. Definir preguntas en `features/surveys/types/<tipo>/domain/`.
2. Registrar tipo en `SurveyCatalog`.
3. Implementar `SurveyTypeHandler` del tipo.
4. Registrar handler en `SurveyTypeHandlerRegistry`.
5. Ajustar pantalla/controlador si requiere UX distinta.
6. Verificar persistencia y resultado en reportes.

## 6. Limpieza realizada

La implementación legacy fue removida para evitar rutas duplicadas:
- `lib/Services/**`
- `lib/controllers/**`
- `lib/screens/**`
- `lib/provider/**`

Todos los flujos activos de encuesta ahora viven en `lib/features/surveys/**`.
