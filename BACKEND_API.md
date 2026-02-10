# Backend - API Reference

## 📦 Servicios Disponibles

### 1. DatabaseHelper
Inicialización y gestión centralizada de la base de datos local.

```dart
// Inicializar Hive y providers (llamar al inicio de la app)
await DatabaseHelper.initializeProviders();

// Sincronización inicial (descargar datos del servidor)
await DatabaseHelper.initialSync();

// Acceder a providers
final patientProvider = DatabaseHelper.patientProvider;
final surveyProvider = DatabaseHelper.surveyProvider;
final syncService = DatabaseHelper.syncService;

// Verificar datos pendientes
bool hasPending = DatabaseHelper.hasPendingSync;

// Obtener estadísticas
SyncStats? stats = DatabaseHelper.syncStats;
print(stats); // Pacientes: 5 (2 pendientes) | Encuestas: 10 (3 pendientes)

// Cerrar al finalizar app
await DatabaseHelper.dispose();
```

### 2. PatientProvider
Gestión de pacientes con almacenamiento offline.

```dart
final provider = DatabaseHelper.patientProvider;

// Agregar paciente
final patient = PatientModel(
  patientId: DateTime.now().millisecondsSinceEpoch,
  name: 'Juan Pérez',
  gender: 'M',
  birthDate: DateTime(1990, 5, 15),
);
await provider.addPatient(patient); // Intenta sincronizar automáticamente

// Obtener todos los pacientes
List<PatientModel> patients = provider.getAllPatientsAsList();
Map<dynamic, dynamic> patientsMap = provider.getAllPatients();

// Buscar por ID
PatientModel? patient = provider.getPatientById(12345);

// Buscar por índice
PatientModel? patient = provider.getPatientByIndex(0);

// Actualizar
await provider.updatePatient(index, patientModificado);

// Eliminar
await provider.deletePatient(index);

// Sincronizar pendientes → Supabase
await provider.syncPendingPatients();

// Descargar Supabase → Local
await provider.syncFromSupabase();

// Cerrar
await provider.dispose();
```

### 3. SurveyProvider
Gestión de encuestas con almacenamiento offline.

```dart
final provider = DatabaseHelper.surveyProvider;

// Agregar encuesta
final survey = SurveyModel(
  surveyId: DateTime.now().millisecondsSinceEpoch,
  responses: [
    ResponseModel(questionId: 1, answerValue: 2),
    ResponseModel(questionId: 2, answerValue: 3),
  ],
);
await provider.addSurvey(survey); // Intenta sincronizar automáticamente

// Obtener todas las encuestas
List<SurveyModel> surveys = provider.getAllSurveysAsList();
Map<dynamic, dynamic> surveysMap = provider.getAllSurveys();

// Obtener por índice
SurveyModel? survey = provider.getSurveyByIndex(0);

// Actualizar
await provider.updateSurvey(index, surveyModificado);

// Eliminar
await provider.deleteSurvey(index);

// Sincronizar pendientes → Supabase
await provider.syncPendingSurveys();

// Descargar Supabase → Local
await provider.syncFromSupabase();

// Cerrar
await provider.dispose();
```

### 4. SyncService
Sincronización centralizada de todos los datos.

```dart
final syncService = DatabaseHelper.syncService;

// Sincronización completa (bidireccional)
SyncResult result = await syncService.syncAll();
print(result.message); // "Sincronización completada: 2 pacientes, 3 encuestas"

// Solo enviar datos locales pendientes
SyncResult result = await syncService.syncPendingOnly();

// Solo descargar del servidor
SyncResult result = await syncService.downloadFromServer();

// Verificar si hay pendientes
bool hasPending = syncService.hasPendingSync();

// Obtener estadísticas
SyncStats stats = syncService.getStats();
print('Total pacientes: ${stats.totalPatients}');
print('Pacientes pendientes: ${stats.unsyncedPatients}');
print('Total encuestas: ${stats.totalSurveys}');
print('Encuestas pendientes: ${stats.unsyncedSurveys}');
print('Total pendientes: ${stats.totalPending}');
```

### 5. ConnectivityService
Verificación de conexión a internet.

```dart
final connectivity = ConnectivityService();

// Verificar conexión
bool hasInternet = await connectivity.hasConnection();

// Verificar tipo específico
bool hasWifi = await connectivity.hasConnectionType(ConnectivityResult.wifi);

// Escuchar cambios de conectividad
connectivity.onConnectivityChanged.listen((results) {
  if (results.contains(ConnectivityResult.wifi)) {
    print('Conectado a WiFi');
    // Sincronizar automáticamente
  } else if (results.contains(ConnectivityResult.none)) {
    print('Sin conexión');
  }
});
```

### 6. PatientService
Comunicación directa con Supabase (usado internamente por PatientProvider).

```dart
final service = PatientService();

// Sincronizar un paciente
bool success = await service.syncPatientToSupabase(patient);

// Obtener todos
List<PatientModel> patients = await service.getAllPatientsFromSupabase();

// Obtener por ID
PatientModel? patient = await service.getPatientById(12345);

// Buscar por nombre
List<PatientModel> results = await service.searchPatientsByName('Juan');

// Actualizar
bool success = await service.updatePatient(patient);

// Eliminar
bool success = await service.deletePatient(12345);
```

### 7. SurveyService
Comunicación directa con Supabase (usado internamente por SurveyProvider).

```dart
final service = SurveyService();

// Sincronizar encuesta
bool success = await service.syncSurveyToSupabase(survey);

// Obtener todas
List<Map<String, dynamic>> surveys = await service.getAllSurveysFromSupabase();
```

## 🔄 Flujo de Trabajo Recomendado

### Inicialización de la App

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase
  await SupabaseConfig.initialize();
  
  // Inicializar base de datos local y providers
  await DatabaseHelper.initializeProviders();
  
  // Sincronizar datos iniciales (no crítico si falla)
  await DatabaseHelper.initialSync();
  
  runApp(const MyApp());
}
```

### Durante Uso Offline

```dart
// Los datos se guardan localmente automáticamente
await patientProvider.addPatient(newPatient);
await surveyProvider.addSurvey(newSurvey);

// El campo 'synced' será false si no hay conexión
```

### Al Recuperar Conexión

```dart
// Opción 1: Sincronizar todo
final result = await DatabaseHelper.syncService.syncAll();

// Opción 2: Sincronizar automáticamente cuando detectes conexión
connectivity.onConnectivityChanged.listen((results) async {
  if (results.any((r) => r != ConnectivityResult.none)) {
    await DatabaseHelper.syncService.syncPendingOnly();
  }
});
```

### Verificar Estado de Sincronización

```dart
// En un widget
if (DatabaseHelper.hasPendingSync) {
  // Mostrar indicador visual
  Badge(label: Text('Pendiente'));
}

// Verificar paciente individual
if (!patient.synced) {
  Icon(Icons.cloud_off, color: Colors.orange);
} else {
  Icon(Icons.cloud_done, color: Colors.green);
}
```

## 📊 Modelos de Datos

### PatientModel
```dart
class PatientModel {
  int patientId;
  String name;
  String gender; // 'M', 'F', 'O'
  DateTime birthDate;
  bool synced; // true si está en Supabase
  
  int get age; // Calculado automáticamente
  
  Map<String, dynamic> toJson();
  factory PatientModel.fromJson(Map<String, dynamic> json);
}
```

### SurveyModel
```dart
class SurveyModel {
  int surveyId;
  bool synced;
  List<ResponseModel> responses;
}
```

### ResponseModel
```dart
class ResponseModel {
  int questionId;
  int answerValue;
}
```

### SyncResult
```dart
class SyncResult {
  bool success;
  String message;
  int patientsSynced;
  int surveysSynced;
}
```

### SyncStats
```dart
class SyncStats {
  int totalPatients;
  int unsyncedPatients;
  int totalSurveys;
  int unsyncedSurveys;
  
  bool get hasPending;
  int get totalPending;
}
```

## ⚙️ Configuración

### Hive TypeIDs
- **PatientModel**: typeId 2
- **SurveyModel**: typeId 0
- **ResponseModel**: typeId 1

### Cajas de Hive
- **patientBox**: Almacena PatientModel
- **surveyBox**: Almacena SurveyModel

### Regenerar Adaptadores
Si modificas los modelos:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🎯 Ventajas del Backend

✅ **Trabajo Offline Completo**: Funciona sin internet
✅ **Sincronización Automática**: Se intenta sincronizar al agregar/editar
✅ **Sincronización Manual**: Control total con SyncService
✅ **Persistencia**: Datos guardados entre sesiones
✅ **Detección de Conectividad**: Sabe cuándo hay internet
✅ **Estado de Sincronización**: Campo `synced` en cada registro
✅ **Sincronización Bidireccional**: Local ↔ Supabase
✅ **Centralizado**: DatabaseHelper gestiona todo
✅ **Estadísticas**: Tracking de datos pendientes

## 🚨 Manejo de Errores

Todos los métodos usan try-catch y devuelven valores seguros:
- Métodos `sync*`: devuelven `bool` (false en error)
- Métodos `get*`: devuelven listas vacías o null en error
- SyncService: devuelve `SyncResult` con información del error

## 📱 Ejemplo Completo de Uso

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  await DatabaseHelper.initializeProviders();
  await DatabaseHelper.initialSync();
  runApp(const MyApp());
}

class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  void initState() {
    super.initState();
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    ConnectivityService().onConnectivityChanged.listen((results) async {
      if (results.any((r) => r != ConnectivityResult.none)) {
        final result = await DatabaseHelper.syncService.syncAll();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
      }
    });
  }

  Future<void> _addPatient() async {
    final patient = PatientModel(
      patientId: DateTime.now().millisecondsSinceEpoch,
      name: 'Juan Pérez',
      gender: 'M',
      birthDate: DateTime(1990, 1, 1),
    );
    
    await DatabaseHelper.patientProvider.addPatient(patient);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final patients = DatabaseHelper.patientProvider.getAllPatientsAsList();
    final hasPending = DatabaseHelper.hasPendingSync;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Pacientes'),
        actions: [
          if (hasPending)
            IconButton(
              icon: Icon(Icons.sync),
              onPressed: () async {
                final result = await DatabaseHelper.syncService.syncAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.message)),
                );
                setState(() {});
              },
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return ListTile(
            leading: Icon(
              patient.synced ? Icons.cloud_done : Icons.cloud_off,
              color: patient.synced ? Colors.green : Colors.orange,
            ),
            title: Text(patient.name),
            subtitle: Text('${patient.age} años'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPatient,
        child: Icon(Icons.add),
      ),
    );
  }
}
```
