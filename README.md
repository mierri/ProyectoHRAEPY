# ssapp

Sistema de gestión de pacientes y encuestas BDI-2 con almacenamiento offline completo.

## ✨ Características

- ✅ **Almacenamiento Offline**: Funciona sin conexión a internet usando Hive
- ✅ **Sincronización Automática**: Sincroniza automáticamente cuando hay conexión
- ✅ **Base de datos en la nube**: Supabase como backend
- ✅ **Gestión de Pacientes**: CRUD completo con sincronización
- ✅ **Gestión de Encuestas BDI-2**: Almacenamiento y sincronización de respuestas
- ✅ **Detección de Conectividad**: Monitoreo de estado de red
- ✅ **Estado de Sincronización**: Indicadores visuales de datos pendientes

## 📁 Estructura del Proyecto

```
lib/
├── config/
│   └── supabase_config.dart          # Configuración de Supabase
├── models/
│   ├── patient_model.dart            # Modelo de paciente con Hive
│   ├── survey_model.dart             # Modelo de encuesta con Hive
│   └── response_model.dart           # Modelo de respuesta con Hive
├── provider/
│   ├── patient_provider.dart         # Provider de pacientes (Offline)
│   └── survey_provider.dart          # Provider de encuestas (Offline)
├── Services/
│   ├── patient_service.dart          # Servicio de Supabase (pacientes)
│   ├── survey_service.dart           # Servicio de Supabase (encuestas)
│   ├── connectivity_service.dart     # Detección de red
│   ├── sync_service.dart             # Sincronización centralizada
│   └── database_helper.dart          # Inicialización y gestión BD
└── main.dart                          # Punto de entrada
```

## 🚀 Documentación

Ver documentación completa del backend en:
- **[BACKEND_API.md](BACKEND_API.md)** - API completa y ejemplos de uso
- **[OFFLINE_STORAGE.md](OFFLINE_STORAGE.md)** - Detalles de almacenamiento offline

## 🛠 Tecnologías

- **Flutter**: Framework de UI
- **Hive**: Base de datos local (offline)
- **Supabase**: Backend en la nube (PostgreSQL)
- **connectivity_plus**: Detección de conectividad
- **build_runner**: Generación de código para Hive

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

## 💻 Uso del Backend

```dart
// Inicialización (en main.dart)
await DatabaseHelper.initializeProviders();
await DatabaseHelper.initialSync();

// Agregar paciente
final patient = PatientModel(
  patientId: DateTime.now().millisecondsSinceEpoch,
  name: 'Juan Pérez',
  gender: 'M',
  birthDate: DateTime(1990, 1, 1),
);
await DatabaseHelper.patientProvider.addPatient(patient);

// Agregar encuesta
final survey = SurveyModel(
  surveyId: DateTime.now().millisecondsSinceEpoch,
  responses: [
    ResponseModel(questionId: 1, answerValue: 2),
  ],
);
await DatabaseHelper.surveyProvider.addSurvey(survey);

// Sincronizar todos los datos
final result = await DatabaseHelper.syncService.syncAll();
print(result.message);

// Verificar datos pendientes
bool hasPending = DatabaseHelper.hasPendingSync;
SyncStats stats = DatabaseHelper.syncStats!;
```

Ver más ejemplos en [BACKEND_API.md](BACKEND_API.md).

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
- [x] Configuración de Supabase
- [x] Modelos de datos con Hive
- [x] PatientProvider con almacenamiento offline
- [x] SurveyProvider con almacenamiento offline
- [x] Servicios de sincronización con Supabase
- [x] Detección de conectividad
- [x] SyncService centralizado
- [x] DatabaseHelper para inicialización
- [x] Sincronización bidireccional
- [x] Manejo de errores
- [x] Documentación completa del backend

### 🚧 Pendiente (Frontend)
- [ ] Páginas de UI para pacientes
- [ ] Páginas de UI para encuestas
- [ ] Navegación entre páginas
- [ ] Formularios de entrada
- [ ] Indicadores visuales de sincronización

## 📄 Licencia

Este proyecto es privado.

## 👥 Autor

Desarrollado para gestión de pacientes y encuestas BDI-2.


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
