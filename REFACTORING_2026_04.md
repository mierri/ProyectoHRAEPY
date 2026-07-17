# Refactorizacion Abril 2026

## Objetivo
Consolidar una arquitectura 100% feature-driven, con responsabilidades separadas por dominio funcional y por tipo de instrumento en encuestas.

## Resumen ejecutivo
- Se eliminaron capas legacy (`lib/Services`, `lib/controllers`, `lib/screens`, `lib/provider`, `lib/models`).
- `surveys/types/` ahora organiza cada instrumento con `domain/` y `presentation/` propios.
- Se movio `save_osteoporosis_survey_use_case.dart` al dominio de `types/osteoporosis/`.
- `reports/` quedo desacoplado con use cases concretos y viewmodels por tipo.
- Se centralizo DI en `lib/app/di.dart` y registro Hive en `lib/core/storage/hive_adapters.dart`.

## Cambios por fase

### Fase 1 - Limpieza inmediata
Resultado:
- Logging estructurado unificado con `core/logger/app_logger.dart`.
- Consentimiento separado en `features/surveys/presentation/consent_form_controller.dart`.
- Eliminacion de residuos legacy vacios.

### Fase 2 - Reportes (alto impacto)
Resultado:
- Feature `reports/` con estructura por capas (`data`, `domain`, `infrastructure`, `presentation`).
- `GenerateReportUseCase` y `ExportDataUseCase` implementados.
- PDF por tipo (`bdi_bai`, `whoqol`, `sf36`, `osteoporosis`) sobre `PdfReportBase`.
- `SurveyExcelExporter` como exportador Excel por tipo.
- `ReportsViewModel` delega render/export a viewmodels por tipo.

### Fase 3 - Survey Controller
Resultado:
- `SurveyController` queda generico.
- `OsteoporosisSurveyController` encapsula flujo especializado de osteoporosis.
- `SaveOsteoporosisSurveyUseCase` vive en `features/surveys/types/osteoporosis/domain/`.

### Fase 4 - Feature-driven completo
Resultado:
- Pantallas/controladores especificos movidos a `features/surveys/types/<instrumento>/presentation/`:
  - `assist`, `whoqol`, `sf36`, `moca`, `osteoporosis`.
- Se crearon pantallas por tipo para `bdi`, `bai`, `gds`, `lawton`, `katz`, `iciq_sf`.
- Se agregaron barrels por tipo (`<tipo>_feature.dart`).
- Router actualizado para resolver pantalla por instrumento desde `types/*/presentation/`.

## Estado de estructura resultante (encuestas)

```text
lib/features/surveys/types/
  assist/
    domain/
    presentation/
    assist_feature.dart
  bai/
    domain/
    presentation/
    bai_feature.dart
  bdi/
    domain/
    presentation/
    bdi_feature.dart
  gds/
    domain/
    presentation/
    gds_feature.dart
  iciq_sf/
    domain/
    presentation/
    iciq_sf_feature.dart
  katz/
    domain/
    presentation/
    katz_feature.dart
  lawton/
    domain/
    presentation/
    lawton_feature.dart
  moca/
    domain/
    presentation/
    moca_feature.dart
  osteoporosis/
    domain/
    presentation/
    osteoporosis_feature.dart
  sf36/
    domain/
    presentation/
    sf36_feature.dart
  whoqol/
    domain/
    presentation/
    whoqol_feature.dart
```

## Validacion
- Compilacion sin errores en archivos migrados por tipo.
- Tests de osteoporosis en verde despues de mover modelos/rutas de import.
- Diagnostico Android residual de Gradle/SDK permanece fuera de este refactor.
