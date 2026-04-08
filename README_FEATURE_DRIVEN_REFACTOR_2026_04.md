# README Refactor Feature-Driven (Abril 2026)

Este documento resume la refactorizacion para dejar SSApp con arquitectura **100% feature-driven**, incluyendo organizacion por instrumento en encuestas.

## 1. Objetivo del refactor

- Encapsular cada dominio funcional dentro de `features/`.
- Evitar carpetas globales por tipo tecnico (controllers/services/screens fuera de feature).
- Reducir acoplamiento cruzado entre modulos.
- Facilitar agregar un nuevo instrumento sin tocar el resto de la app.

## 2. Estructura global resultante

```text
lib/
  app/
    app.dart
    di.dart
    router.dart
  core/
    logger/
      app_logger.dart
    network/
      connectivity_service.dart
      network_executor.dart
    storage/
      database_helper.dart
      hive_adapters.dart
    supabase/
      supabase_config.dart
  shared/
    models/
    services/
    utils/
    widgets/
      components/
      charts/
  features/
    auth/
    dashboard/
    investigations/
    patients/
    reports/
    settings/
    surveys/
```

## 3. Carpeta por carpeta (relevante)

### app/
- `app.dart`: inicializa la app.
- `di.dart`: registro central de providers y dependencias.
- `router.dart`: resolucion de rutas y dispatch por tipo de encuesta.

### core/
- `logger/app_logger.dart`: logging estructurado.
- `network/*`: conectividad y ejecucion con reintentos.
- `storage/database_helper.dart`: acceso local base.
- `storage/hive_adapters.dart`: registro unificado de adapters Hive.
- `supabase/supabase_config.dart`: cliente y configuracion remota.

### shared/
- `models/`: entidades transversales (`PatientModel`, `SurveyModel`, `ResponseModel`).
- `services/`: sincronizacion y contratos comunes.
- `utils/`: tema, helpers de UI y utilidades.
- `widgets/components/`: UI reusable general.
- `widgets/charts/`: exports compartidos de graficas para consumo cross-feature.

### features/patients/
- `data/patient_repository.dart`: acceso y persistencia de pacientes.
- `domain/use_cases/*`: casos de uso (`create`, `sync`).
- `presentation/*`: pantallas y viewmodels de pacientes.

### features/reports/
- `data/report_repository.dart`: fuente de encuestas filtradas para reportes.
- `domain/report_models.dart`: modelos estadisticos base.
- `domain/stats_calculator.dart`: calculos puros.
- `domain/use_cases/generate_report_use_case.dart`: carga de data por tipo.
- `domain/use_cases/export_data_use_case.dart`: exportacion CSV.
- `infrastructure/pdf/*`: generadores PDF por instrumento + base comun.
- `infrastructure/csv/survey_csv_exporter.dart`: exportador CSV por tipo.
- `presentation/reports_screen.dart`: UI principal.
- `presentation/reports_viewmodel.dart`: estado y acciones de reportes.
- `reports_feature.dart`: barrel/entry point.

### features/surveys/
- `core/domain/*`: handlers y registro por tipo.
- `data/survey_repository.dart`: persistencia/sync de encuestas.
- `domain/survey_catalog.dart`: metadata de tipos.
- `domain/survey_rules.dart`: reglas de score e interpretacion.
- `domain/use_cases/save_survey_use_case.dart`: guardado generico.
- `presentation/`: piezas transversales (consentimiento, survey base, listado/resultados).
- `types/`: estructura por instrumento (detalle abajo).

## 4. Encuestas por instrumento (types)

```text
features/surveys/types/
  bdi/
    domain/
      bdi_questions.dart
      bdi_survey_handler.dart
    presentation/
      bdi_screen.dart
    bdi_feature.dart

  bai/
    domain/
      bai_questions.dart
      bai_survey_handler.dart
    presentation/
      bai_screen.dart
    bai_feature.dart

  gds/
    domain/
      gds_questions.dart
      gds_survey_handler.dart
    presentation/
      gds_screen.dart
    gds_feature.dart

  lawton/
    domain/
      lawton_questions.dart
      lawton_survey_handler.dart
    presentation/
      lawton_screen.dart
    lawton_feature.dart

  katz/
    domain/
      katz_questions.dart
      katz_survey_handler.dart
    presentation/
      katz_screen.dart
    katz_feature.dart

  iciq_sf/
    domain/
      iciq_sf_questions.dart
      iciq_sf_survey_handler.dart
    presentation/
      iciq_sf_screen.dart
    iciq_sf_feature.dart

  osteoporosis/
    domain/
      osteoporosis_questions.dart
      osteoporosis_survey_handler.dart
      osteoporosis_risk_model.dart
      osteoporosis_risk_service.dart
      save_osteoporosis_survey_use_case.dart
    presentation/
      osteoporosis_screen.dart
      osteoporosis_survey_controller.dart
    osteoporosis_feature.dart

  whoqol/
    domain/
      whoqol_questions.dart
    presentation/
      whoqol_screen.dart
      whoqol_controller.dart
    whoqol_feature.dart

  sf36/
    domain/
      sf36_questions.dart
    presentation/
      sf36_screen.dart
      sf36_controller.dart
    sf36_feature.dart

  assist/
    domain/
      assist_questions.dart
    presentation/
      assist_screen.dart
      assist_controller.dart
    assist_feature.dart

  moca/
    domain/
      moca_questions.dart
    presentation/
      moca_test_screen.dart
      moca_controller.dart
    moca_feature.dart
```

## 5. Archivos clave del refactor

- `lib/app/router.dart`: ahora resuelve pantalla por tipo desde `types/*/presentation`.
- `lib/features/surveys/presentation/survey_screen.dart`: base reutilizable para instrumentos genericos.
- `lib/features/surveys/types/osteoporosis/presentation/osteoporosis_survey_controller.dart`: flujo especializado osteoporosis.
- `lib/features/surveys/types/osteoporosis/domain/save_osteoporosis_survey_use_case.dart`: persistencia especializada por tipo.
- `lib/features/reports/presentation/viewmodels/survey_report_viewmodels.dart`: viewmodels por tipo de reporte.

## 6. Regla de evolucion

Para agregar un nuevo instrumento:
1. Crear `features/surveys/types/nuevo_tipo/domain/` con preguntas y handler.
2. Crear `features/surveys/types/nuevo_tipo/presentation/` con pantalla/controlador si aplica.
3. Agregar `nuevo_tipo_feature.dart`.
4. Registrar tipo en `survey_catalog.dart` y `survey_type_handler_registry.dart`.
5. En caso de reporte, agregar viewmodel/exportadores en `features/reports/`.

## 7. Estado final

- Arquitectura orientada a features consolidada.
- Encuestas organizadas por instrumento con carpetas propias.
- Reportes desacoplados por tipo y capa.
- Documentacion actualizada para mantenimiento y escalabilidad.
