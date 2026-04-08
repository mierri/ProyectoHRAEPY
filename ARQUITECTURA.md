# Arquitectura SSApp (estado actual)

## 1. Objetivo
Este documento describe la arquitectura vigente del proyecto tras la migración a estructura feature-first.

Objetivos:
- Mantener separación clara entre UI, dominio y persistencia.
- Reducir acoplamiento y duplicación.
- Facilitar evolución por feature sin romper flujos existentes.

## 2. Estructura real del proyecto

```text
lib/
  app/
    app.dart
    router.dart
  core/
    logger/
    network/
    supabase/
  features/
    auth/
    dashboard/
    investigations/
    patients/
      data/
      presentation/
    reports/
      domain/
      infrastructure/
      presentation/
    settings/
    surveys/
      core/domain/
      data/
      domain/
      presentation/
      types/
  models/
    osteoporosis_risk_model.dart
    osteoporosis_report_model.dart
  shared/
    models/
    services/
    utils/
    widgets/
  widgets/
```

## 3. Capas y responsabilidades

### app/
- Configuración global de app y rutas.
- `router.dart` es la única fuente de navegación.

### core/
- Infraestructura transversal técnica (logger, red, configuración de Supabase).
- Sin lógica de negocio de una feature específica.

### features/
- Cada feature encapsula su dominio, acceso a datos y presentación.
- Regla: una feature puede usar `core/` y `shared/`, pero no debe depender de detalles internos de otra feature.

### shared/
- Elementos reutilizables entre features.
- `shared/models/`: modelos Hive/Sync comunes (`PatientModel`, `SurveyModel`, `ResponseModel`).
- `shared/services/`: contratos/servicios transversales (`ISyncable`, sync coordinado).
- `shared/utils/` y `shared/widgets/`: utilidades y componentes compartidos.

### models/
- Modelos transversales de osteoporosis que aún no viven en `shared/models`.

## 4. Estado de migración y limpieza

Se eliminaron las capas legacy ya fuera de uso:
- `lib/Services/`
- `lib/controllers/`
- `lib/screens/`
- `lib/provider/`

La app operativa usa rutas y pantallas en `lib/features/**/presentation/`.

## 5. Dependencias permitidas

Dirección recomendada:

```text
features/*/presentation -> features/*/domain + features/*/data + shared + core
features/*/domain       -> shared + core
features/*/data         -> shared + core
```

Reglas:
1. No usar `BuildContext` en dominio o data.
2. No duplicar reglas de scoring fuera de handlers/rules de encuestas.
3. No editar manualmente `*.g.dart`.

## 6. Flujos clave

### 6.1 Encuestas
1. Pantalla de presentación en `features/surveys/presentation/`.
2. Controller/ViewModel de feature gestiona estado UI.
3. `SurveyService` (feature domain) orquesta guardado.
4. `SaveSurveyUseCase` persiste local + intenta sincronización.
5. `SurveyRepository` maneja Hive/Supabase.

### 6.2 Reportes
1. `ReportsScreen` (orquestador) en `features/reports/presentation/`.
2. Cálculo estadístico en `features/reports/domain/stats_calculator.dart`.
3. Exportadores en `features/reports/infrastructure/`:
   - CSV por tipo.
   - PDF por tipo (`BDI/BAI`, `WHOQOL`, `SF-36`, `Osteoporosis`).

### 6.3 Pacientes y sync
1. Gestión de pacientes en `features/patients/`.
2. Sync coordinado por servicios compartidos y contratos `ISyncable`.

## 7. Checklist para cambios futuros

- [ ] Nueva feature entra en `features/<nombre>/...`.
- [ ] Lógica de negocio no queda en widgets.
- [ ] Persistencia/sync se concentra en repositorios/use cases.
- [ ] Imports no referencian rutas legacy eliminadas.
- [ ] `flutter analyze` y pruebas relevantes ejecutadas.

## 8. Referencias
- `DOCUMENTACION_ENCUESTAS.md`
- `REFACTORING_2026_04.md`
