# Documentación de la modularización de encuestas

## Objetivo

Esta documentación describe la separación actual de responsabilidades en el subsistema de encuestas de SSApp. El objetivo de la modularización fue reducir acoplamiento, eliminar duplicación de reglas y dejar cada capa con una responsabilidad clara.

## Estructura actual

La lógica de encuestas quedó dividida en estos módulos principales:

- `lib/Services/surveys/survey_catalog.dart`
- `lib/Services/surveys/survey_rules.dart`
- `lib/Services/surveys/survey_type_handler.dart`
- `lib/Services/surveys/survey_repository.dart`
- `lib/Services/surveys/save_survey_use_case.dart`
- `lib/Services/survey_service.dart`
- `lib/controllers/survey_controller.dart`
- `lib/provider/survey_provider.dart`
- Pantallas que consumen los controladores y el servicio compartido

## Estructura por encuesta (feature-first)

La logica de encuestas ahora usa carpetas por tipo:

- `lib/features/surveys/core/domain/`
	- `survey_type_handler.dart`
	- `survey_type_handler_registry.dart`
- `lib/features/surveys/types/bdi/domain/`
- `lib/features/surveys/types/bai/domain/`
- `lib/features/surveys/types/gds/domain/`
- `lib/features/surveys/types/lawton/domain/`
- `lib/features/surveys/types/katz/domain/`
- `lib/features/surveys/types/iciq_sf/domain/`
- `lib/features/surveys/types/osteoporosis/domain/`
- `lib/features/surveys/types/moca/domain/`
- `lib/features/surveys/types/sf36/domain/`
- `lib/features/surveys/types/whoqol/domain/`
- `lib/features/surveys/types/assist/domain/`

Cada carpeta de tipo contiene su definicion de preguntas y, cuando aplica, su handler de score/interpretacion.

Se mantienen archivos puente en `lib/models/*_questions.dart` para compatibilidad hacia atras mientras se migra UI de forma gradual.

## Responsabilidad de cada módulo

### SurveyCatalog

Archivo: `lib/Services/surveys/survey_catalog.dart`

Centraliza la información estática de las encuestas:

- IDs de tipo de encuesta.
- Nombres visibles para UI.
- Colores asociados.
- Mapeo entre `surveyType` y preguntas.

Este archivo evita repetir constantes y listas de preguntas en pantallas, controladores o servicios.

### SurveyRules

Archivo: `lib/Services/surveys/survey_rules.dart`

Contiene reglas de negocio puras:

- Cálculo de score total.
- Cálculo de score promedio.
- Estadísticas generales.
- Interpretación de resultados.
- Nivel de severidad.

`SurveyRules` ahora actua como orquestador y delega la logica especifica de cada encuesta en handlers por tipo.

### SurveyTypeHandler

Archivo: `lib/Services/surveys/survey_type_handler.dart`

Define la estrategia por tipo de encuesta con una interfaz comun y un registry:

- `SurveyTypeHandler` como contrato de comportamiento.
- Handlers concretos por tipo (`BaiSurveyHandler`, `GdsSurveyHandler`, etc.).
- `SurveyTypeHandlerRegistry` para resolver el handler segun `surveyType`.

Este enfoque evita condicionales extensos por tipo dentro de `SurveyRules` o controllers.

La idea es que aquí no exista acceso a Hive, Supabase ni UI. Solo transformaciones y lógica de dominio.

### SurveyRepository

Archivo: `lib/Services/surveys/survey_repository.dart`

Se encarga de persistencia y sincronización:

- Implementación concreta de `SurveyRepositoryContract`.
- Lectura de encuestas desde Hive.
- Guardado local de encuestas.
- Consulta de encuestas desde Supabase.
- Inserción de encuestas y respuestas en Supabase.
- Sincronización de encuestas pendientes.
- Manejo de errores de clave foránea cuando el paciente aún no está sincronizado.

Esta capa concentra el acceso a datos y evita que la lógica de red o almacenamiento se mezcle con la UI.

### SaveSurveyUseCase

Archivo: `lib/Services/surveys/save_survey_use_case.dart`

Caso de uso para persistencia + sincronización con timeout:

- Guarda primero en local mediante `SurveyRepositoryContract`.
- Intenta sincronizar con Supabase con timeout controlado.
- Marca la encuesta como sincronizada solo si la sync fue exitosa.

Este módulo evita duplicación del flujo de guardado en múltiples controladores.

### SurveyService

Archivo: `lib/Services/survey_service.dart`

Actúa como fachada sobre contrato de repositorio, casos de uso y reglas compartidas.

Responsabilidades actuales:

- Cargar encuestas combinando fuente local y remota.
- Exponer estadísticas y cálculos a otras capas.
- Orquestar guardado + sync vía `SaveSurveyUseCase`.
- Delegar sincronización al repositorio.
- Mantener compatibilidad con controladores y providers existentes.

La intención es que `SurveyService` siga siendo simple y estable para no romper el resto de la app.

### SurveyController

Archivo: `lib/controllers/survey_controller.dart`

Maneja el flujo de la encuesta en la UI:

- Estado de la pregunta actual.
- Respuestas seleccionadas.
- Navegación entre preguntas.
- Validación de completitud.
- Construcción de `SurveyModel`.
- Guardado y sincronización delegados a `SurveyService`.

Este controlador depende del catálogo y las reglas, pero no debería contener lógica de dominio duplicada.

### SurveyProvider

Archivo: `lib/provider/survey_provider.dart`

Es una capa auxiliar para operaciones directas sobre el box local:

- Alta, edición y borrado de encuestas.
- Sincronización manual pendiente.
- Importación desde Supabase.

Si se sigue usando, conviene mantenerlo enfocado en acceso local y sincronización, sin sumar reglas de negocio nuevas.

## Flujo de datos

El flujo normal queda así:

1. La pantalla captura la interacción del usuario.
2. `SurveyController` administra navegación y respuestas.
3. Al guardar, el controlador arma el `SurveyModel`.
4. `SurveyService` delega persistencia en `SaveSurveyUseCase`.
5. `SaveSurveyUseCase` usa `SurveyRepositoryContract`.
6. `SurveyRepository` (implementación concreta) guarda en Hive y sincroniza con Supabase.
7. `SurveyRules` delega score e interpretacion al `SurveyTypeHandler` correspondiente.
8. `SurveyCatalog` resuelve nombres, colores y preguntas según el tipo.

## Beneficios de la modularización

- Menor acoplamiento entre UI, negocio y persistencia.
- Dependencia sobre contratos (`SurveyRepositoryContract`) en lugar de implementaciones concretas.
- Reglas reutilizables desde controladores, reportes y pantallas.
- Menos duplicación de constantes y lógica de score.
- Menos duplicación del flujo guardar+sincronizar entre controladores.
- Más facilidad para probar cálculo e interpretación de forma aislada.
- Más simple agregar nuevas encuestas sin tocar demasiados archivos.

## Reglas de uso

### Cuando usar SurveyCatalog

Usar este módulo cuando necesites:

- Identificar una encuesta por ID o tipo.
- Mostrar nombre o color en UI.
- Obtener el conjunto de preguntas de una encuesta.

### Cuando usar SurveyRules

Usar este módulo cuando necesites:

- Calcular score.
- Obtener promedios o estadísticas.
- Interpretar resultados.
- Determinar severidad.

### Cuando usar SurveyTypeHandler

Usar este módulo cuando necesites:

- Implementar lógica especifica de un tipo de encuesta.
- Cambiar interpretacion/severidad sin afectar otros tipos.
- Agregar un nuevo tipo sin crecer un `if/switch` global.

### Cuando usar SurveyRepository

Usar este módulo cuando necesites:

- Cargar datos locales o remotos.
- Guardar en Supabase.
- Sincronizar pendientes.
- Resolver problemas de integridad entre encuesta y paciente.

### Cuando usar SaveSurveyUseCase

Usar este módulo cuando necesites:

- Guardar una encuesta de forma consistente (local + intento de sync).
- Reutilizar timeout y política de marcado `synced`.
- Evitar repetir la misma orquestación en cada controller.

### Cuando usar SurveyService

Usar este módulo cuando necesites una fachada estable desde UI o controllers.

## Extensión recomendada

Si se agrega una nueva encuesta, el orden recomendado es:

1. Agregar preguntas al modelo correspondiente.
2. Registrar el tipo en `SurveyCatalog`.
3. Crear un handler que implemente `SurveyTypeHandler`.
4. Registrar el handler en `SurveyTypeHandlerRegistry`.
5. Mantener `SurveyRules` sin condicionales nuevos por tipo.
6. Verificar el guardado y sincronización en `SurveyRepository`.
7. Consumir el nuevo tipo desde `SurveyController` o la pantalla correspondiente.

## Recomendación arquitectónica

El siguiente paso de modularización, si la app sigue creciendo, sería separar casos de uso explícitos para acciones como:

- guardar encuesta,
- sincronizar pendientes,
- recalcular estadísticas,
- importar encuestas remotas.

Eso permitiría dejar `SurveyController` más enfocado en estado de UI y mover la orquestación a una capa intermedia.

## Archivos relacionados

- `lib/Services/survey_service.dart`
- `lib/Services/surveys/survey_catalog.dart`
- `lib/Services/surveys/survey_rules.dart`
- `lib/Services/surveys/survey_type_handler.dart`
- `lib/Services/surveys/survey_repository.dart`
- `lib/Services/surveys/save_survey_use_case.dart`
- `lib/controllers/survey_controller.dart`
- `lib/provider/survey_provider.dart`
- `lib/screens/survey_screen.dart`
- `lib/screens/survey_results_screen.dart`
- `lib/screens/patients_screen.dart`

## Estado actual

La modularización actual ya es suficiente para mantener el sistema ordenado. La doc nueva existe para que el equipo tenga una referencia única de cómo está dividida la lógica y dónde debe ir cada cambio futuro.
