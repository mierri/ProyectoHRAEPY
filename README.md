# ssapp

Sistema de gestion de pacientes y encuestas clinicas — Departamento de Psicología HRAEPY — con almacenamiento offline y sincronizacion con Supabase.

> 📘 ¿Buscás una explicación no técnica para el cliente/hospital? Ver **[MANUAL_USUARIO.md](MANUAL_USUARIO.md)**.

## ✨ Características

- ✅ **Autenticación**: Login seguro por usuario (Supabase Auth)
- ✅ **Almacenamiento Offline**: Funciona sin conexión a internet usando Hive
- ✅ **Sincronización Automática**: Sincroniza automáticamente cuando hay conexión
- ✅ **Base de datos en la nube**: Supabase como backend
- ✅ **Gestión de Pacientes**: CRUD completo con sincronización
- ✅ **Gestión de Encuestas Múltiples**: 19 instrumentos clínicos (BDI-II, BAI, WHOQOL-BREF, SF-36, ASSIST, GDS-15, Lawton, Katz, ICIQ-SF, Osteoporosis, GHQ-12, PHQ-9, Sociodemográfico, Determinantes Sociales, Asistencia en Consulta de Especialidad, Barreras Percibidas para la Asistencia, MoCA 8.1, MoCA Blind, FANTASTIC MEX-A)
- ✅ **Constructor de Encuestas**: Diseño de encuestas personalizadas propias, sin tocar código
- ✅ **Investigaciones**: Agrupa pacientes, consentimiento informado y encuestas dentro de un estudio de investigación
- ✅ **Detección de Conectividad**: Monitoreo de estado de red
- ✅ **Estado de Sincronización**: Indicadores visuales de datos pendientes
- ✅ **Reportes por Tipo**: Exportación Excel/PDF por instrumento, con gráficos
- ✅ **Multiplataforma**: Android, y Web (desplegado en Vercel)

## 📁 Estructura del Proyecto

```
lib/
├── app/
│   ├── app.dart                      # Configuracion principal de app
│   ├── di.dart                       # Dependency Injection (providers)
│   └── router.dart                   # Rutas GoRouter
├── core/
│   ├── logger/
│   ├── network/
│   ├── storage/
│   └── supabase/
├── features/
│   ├── auth/                         # Login y sesión (Supabase Auth)
│   ├── splash/
│   ├── dashboard/
│   ├── patients/
│   ├── investigations/               # Estudios de investigación (consentimiento, participantes, encuestas)
│   ├── reports/
│   ├── settings/
│   ├── survey_builder/               # Constructor de encuestas personalizadas
│   └── surveys/
│       └── types/                    # Un subdirectorio domain/presentation por cada instrumento clínico
├── shared/
│   ├── models/                       # Modelos Hive sincronizables
│   ├── services/
│   ├── utils/
│   └── widgets/
└── main.dart                         # Punto de entrada
```

## 🚀 Documentación

Ver documentación completa del backend en:
- **[ARQUITECTURA.md](ARQUITECTURA.md)** - Arquitectura vigente feature-first
- **[DOCUMENTACION_ENCUESTAS.md](DOCUMENTACION_ENCUESTAS.md)** - Subsistema de encuestas
- **[BACKEND_API.md](BACKEND_API.md)** - API y sincronizacion
- **[OFFLINE_STORAGE.md](OFFLINE_STORAGE.md)** - Detalles de almacenamiento offline
- **[REFACTORING_2026_04.md](REFACTORING_2026_04.md)** - Historial de refactorizacion
- **[README_FEATURE_DRIVEN_REFACTOR_2026_04.md](README_FEATURE_DRIVEN_REFACTOR_2026_04.md)** - Estructura final por feature y por tipo de encuesta

## 🛠 Tecnologías

- **Flutter / Dart**: Framework de UI multiplataforma (Android, Web)
- **Hive**: Base de datos local (offline)
- **Supabase**: Backend en la nube (PostgreSQL + Auth)
- **go_router**: Enrutamiento/navegación declarativa
- **provider**: Gestión de estado
- **shadcn_flutter / google_fonts / material_symbols_icons**: UI y estilos
- **fl_chart**: Gráficos de reportes
- **pdf / printing**: Generación e impresión de reportes en PDF
- **excel**: Exportación de reportes en Excel
- **flutter_tts / just_audio**: Lectura en voz alta de encuestas (accesibilidad)
- **connectivity_plus**: Detección de conectividad
- **build_runner**: Generación de código para Hive
- **GitHub**: Control de versiones y colaboración (ver [GITFLOW.md](GITFLOW.md))
- **Vercel**: Hosting y despliegue automático de la versión web (ver [WEB_DEPLOY.md](WEB_DEPLOY.md))

## 📦 Instalación

1. Clonar el repositorio
2. Instalar dependencias:
   ```bash
   flutter pub get
   ```
3. Generar adaptadores de Hive:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Configurar Supabase en `.env`:
   ```
   SUPABASE_URL=tu_url
   SUPABASE_ANON_KEY=tu_key
   ```
5. Ejecutar:
   ```bash
   flutter run
   ```

## 🔄 Flujo de Sincronización

1. **Al iniciar la app**: Se descargan datos del servidor
2. **Uso offline**: Datos se guardan localmente con Hive
3. **Al recuperar conexión**: Sincronización automática de datos pendientes
4. **Manual**: Botón de sincronización disponible en la UI

## 📊 Base de Datos

### Local (Hive)
- **patientBox**: Almacena pacientes (typeId: 2)
- **surveyBox**: Almacena encuestas (typeId: 0)
- **ResponseModel**: typeId: 1

### Remota (Supabase)
- **patients**: Tabla de pacientes
- **surveys**: Tabla de encuestas
- **responses**: Tabla de respuestas

## 🔧 Comandos Útiles

```bash
# Instalar dependencias
flutter pub get

# Generar adaptadores de Hive
flutter pub run build_runner build --delete-conflicting-outputs

# Limpiar build
flutter clean

# Ejecutar app
flutter run

# Build APK
flutter build apk

# Analizar código
flutter analyze
```

## 📝 Estado del Proyecto

### ✅ Completado
- [x] Arquitectura feature-first
- [x] Modulo de encuestas modularizado por tipo (19 instrumentos)
- [x] Autenticación con Supabase Auth
- [x] Constructor de encuestas personalizadas
- [x] Modulo de investigaciones (consentimiento, participantes, encuestas por estudio)
- [x] Persistencia Hive + sincronizacion Supabase
- [x] Reportes y exportacion por tipo (Excel/PDF)
- [x] UI principal de pacientes, encuestas, reportes y configuracion
- [x] Despliegue web automatico en Vercel

### 🚧 Pendiente
- [ ] Reducir warnings de `flutter analyze`
- [ ] Aumentar cobertura de pruebas unitarias e integracion
- [ ] Endurecer validaciones de paridad para exportadores de reportes

## 📄 Licencia

Este proyecto es privado.

## 👥 Autor

Desarrollado para gestión de pacientes y encuestas BDI-2.
