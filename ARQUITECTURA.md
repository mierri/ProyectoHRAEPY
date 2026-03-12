# Arquitectura de la Aplicación - SSApp

## 📋 Tabla de Contenidos

- [Visión General](#visión-general)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Patrón de Arquitectura](#patrón-de-arquitectura)
- [Controladores](#controladores)
- [Pantallas](#pantallas)
- [Guía de Implementación](#guía-de-implementación)
- [Mejores Prácticas](#mejores-prácticas)
- [Ejemplos](#ejemplos)

## 🎯 Visión General

Esta aplicación utiliza una arquitectura basada en **separación de responsabilidades** para mantener el código limpio, testeable y mantenible. La lógica de negocio se separa de la UI mediante el uso de controladores que extienden `ChangeNotifier`.

### Principios Clave

1. **Separación de Responsabilidades**: La lógica de negocio está separada de la UI
2. **Reactividad**: Los controladores notifican cambios automáticamente
3. **Testabilidad**: La lógica puede ser testeada independientemente de la UI
4. **Reutilización**: Los controladores pueden ser compartidos entre múltiples widgets
5. **Mantenibilidad**: El código es más fácil de entender y modificar

## 📁 Estructura del Proyecto

```
lib/
├── controllers/          # Controladores de lógica de negocio
│   ├── whoqol_controller.dart
│   ├── survey_controller.dart
│   ├── moca_controller.dart
│   └── patients_controller.dart
├── screens/             # Pantallas de la aplicación (UI)
│   ├── whoqol_screen.dart
│   ├── survey_screen.dart
│   ├── moca_test_screen.dart
│   └── patients_screen.dart
├── models/              # Modelos de datos
│   ├── patient_model.dart
│   ├── survey_model.dart
│   └── ...
├── services/            # Servicios (API, almacenamiento, etc.)
│   └── survey_service.dart
├── widgets/             # Widgets reutilizables
├── utils/               # Utilidades y helpers
└── config/              # Configuración
```

## 🏗️ Patrón de Arquitectura

### Diagrama de Flujo

```
┌─────────────────┐
│   Screen (UI)   │
│                 │
│  • Build UI     │
│  • Handle UX    │
│  • Listen to    │
│    controller   │
└────────┬────────┘
         │ uses
         ▼
┌─────────────────┐
│   Controller    │
│                 │
│  • State mgmt   │
│  • Business     │
│    logic        │
│  • Data ops     │
└────────┬────────┘
         │ uses
         ▼
┌─────────────────┐
│   Services      │
│                 │
│  • API calls    │
│  • Storage      │
│  • External     │
│    deps         │
└─────────────────┘
```

### Responsabilidades por Capa

#### Screen (Pantalla)
- **Construir la UI**: Widgets y layout
- **Manejar interacciones**: Gestos, tap handlers
- **Mostrar información**: Usar datos del controlador
- **Navegación**: Routes y page transitions
- **Diálogos y toasts**: Feedback visual al usuario

#### Controller
- **Gestión de estado**: Mantener estado de la pantalla
- **Lógica de negocio**: Cálculos, validaciones, reglas
- **Operaciones de datos**: CRUD, transformaciones
- **Comunicación con servicios**: Llamadas a APIs, base de datos
- **Notificación de cambios**: `notifyListeners()`

#### Service
- **Operaciones de red**: HTTP requests
- **Almacenamiento**: Hive, SharedPreferences
- **APIs externas**: Integración con servicios
- **Utilidades de bajo nivel**: Logging, analytics

## 🎮 Controladores

### ¿Qué es un Controlador?

Un controlador es una clase que:
- Extiende `ChangeNotifier`
- Contiene la lógica de negocio
- Mantiene el estado de una pantalla o feature
- Notifica a los listeners cuando el estado cambia

### Estructura Base de un Controlador

```dart
import 'package:flutter/material.dart';

class MiController extends ChangeNotifier {
  // Constructor con dependencias
  MiController({
    required this.dependency1,
    required this.dependency2,
  });

  // Dependencias
  final Dependency1 dependency1;
  final Dependency2 dependency2;

  // Estado privado
  int _counter = 0;
  bool _isLoading = false;

  // Getters públicos (inmutables)
  int get counter => _counter;
  bool get isLoading => _isLoading;

  // Métodos públicos (operaciones)
  void increment() {
    _counter++;
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Lógica de carga
      final data = await dependency1.fetchData();
      // Procesar data...
    } catch (e) {
      // Manejar error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Limpiar recursos
    super.dispose();
  }
}
```

### Controladores Implementados

#### 1. WhoqolController

**Ubicación**: `lib/controllers/whoqol_controller.dart`

**Responsabilidades**:
- Gestión de respuestas del cuestionario WHOQOL-BREF
- Navegación entre preguntas
- Cálculo de puntajes por dominio
- Guardado local y sincronización con Supabase

**Uso**:
```dart
final controller = WhoqolController(
  patientId: patientId,
  surveyService: surveyService,
);

// Seleccionar opción
controller.selectOption(questionNumber, rawScore, optionIndex);

// Navegar
controller.nextQuestion();
controller.previousQuestion();

// Guardar
final result = await controller.saveSurvey();
```

#### 2. SurveyController

**Ubicación**: `lib/controllers/survey_controller.dart`

**Responsabilidades**:
- Gestión de encuestas BDI y BAI
- Navegación entre preguntas
- Cálculo de puntajes totales
- Interpretación de resultados
- Guardado y sincronización

**Uso**:
```dart
final controller = SurveyController(
  patientId: patientId,
  surveyType: 'bdi', // o 'bai'
  surveyService: surveyService,
);

// Acceder a propiedades
final question = controller.currentQuestion;
final progress = controller.progress;

// Guardar
final result = await controller.saveSurvey();
if (result.success) {
  print('Score: ${result.totalScore}');
  print('Interpretation: ${result.interpretation}');
}
```

#### 3. MocaController

**Ubicación**: `lib/controllers/moca_controller.dart`

**Responsabilidades**:
- Gestión del test MoCA
- Navegación entre secciones
- Almacenamiento de resultados por sección
- Cálculo del puntaje total
- Interpretación de resultados

**Uso**:
```dart
final controller = MocaController(patientId: patientId);

// Guardar resultado de sección
controller.setResult('visuospatial_score', 5);

// Obtener resultado
final score = controller.getResult('visuospatial_score');

// Calcular total
final totalScore = controller.calculateTotalScore();
```

#### 4. PatientsController

**Ubicación**: `lib/controllers/patients_controller.dart`

**Responsabilidades**:
- Gestión de lista de pacientes
- Búsqueda y filtrado
- Operaciones CRUD
- Carga desde Hive

**Uso**:
```dart
final controller = PatientsController();

// Cargar pacientes
await controller.loadPatients();

// Buscar
controller.searchPatients('Juan');

// Filtrar
controller.filterByStatus('activos');

// Agregar paciente
await controller.addPatient(newPatient);
```

## 📱 Pantallas

### Estructura de una Pantalla con Controller

```dart
class MiScreen extends StatefulWidget {
  final int parametro;
  
  const MiScreen({super.key, required this.parametro});

  @override
  State<MiScreen> createState() => _MiScreenState();
}

class _MiScreenState extends State<MiScreen> {
  late MiController _controller;

  @override
  void initState() {
    super.initState();
    
    // Inicializar controlador
    final service = context.read<MiService>();
    _controller = MiController(
      parametro: widget.parametro,
      service: service,
    );
    
    // Escuchar cambios
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Counter: ${_controller.counter}'),
          ElevatedButton(
            onPressed: _controller.increment,
            child: const Text('Increment'),
          ),
          if (_controller.isLoading)
            const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
```

### Pantallas Refactorizadas

#### ✅ WHOQOL Screen
- **Archivo**: `lib/screens/whoqol_screen.dart`
- **Controller**: `WhoqolController`
- **Estado**: Completamente refactorizada

#### ✅ Survey Screen (BDI/BAI)
- **Archivo**: `lib/screens/survey_screen.dart`
- **Controller**: `SurveyController`
- **Estado**: Completamente refactorizada

#### 🔄 Pendientes de Refactorización

Las siguientes pantallas aún no están refactorizadas, pero tienen controladores base creados:

- `moca_test_screen.dart` → usar `MocaController`
- `patients_screen.dart` → usar `PatientsController`
- `reports_screen.dart` → crear `ReportsController`
- `surveys_list_screen.dart` → crear `SurveysListController`

## 📝 Guía de Implementación

### Cómo Refactorizar una Pantalla

#### Paso 1: Crear el Controlador

```dart
// lib/controllers/mi_controller.dart
import 'package:flutter/material.dart';

class MiController extends ChangeNotifier {
  // ... implementación
}
```

#### Paso 2: Identificar Estado y Lógica

En la pantalla actual, identifica:
- Variables de estado privadas (`_variable`)
- Métodos con lógica de negocio
- Operaciones asíncronas
- Cálculos y transformaciones

#### Paso 3: Mover al Controlador

Mueve el estado y la lógica al controlador:

**Antes**:
```dart
class _MiScreenState extends State<MiScreen> {
  int _counter = 0;
  bool _isLoading = false;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // ...
    setState(() => _isLoading = false);
  }
}
```

**Después**:
```dart
class MiController extends ChangeNotifier {
  int _counter = 0;
  bool _isLoading = false;

  int get counter => _counter;
  bool get isLoading => _isLoading;

  void increment() {
    _counter++;
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    // ...
    _isLoading = false;
    notifyListeners();
  }
}
```

#### Paso 4: Actualizar la Pantalla

```dart
class _MiScreenState extends State<MiScreen> {
  late MiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MiController();
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('${_controller.counter}'),
          ElevatedButton(
            onPressed: _controller.increment,
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}
```

## ✨ Mejores Prácticas

### 1. Naming Conventions

```dart
// ✅ Correcto
class WhoqolController extends ChangeNotifier { }
class PatientsController extends ChangeNotifier { }

// ❌ Incorrecto
class WhoqolManager extends ChangeNotifier { }
class PatientsBloc extends ChangeNotifier { }
```

### 2. Getters Inmutables

```dart
// ✅ Correcto - Devuelve copia inmutable
Map<int, int> get responses => Map.unmodifiable(_responses);
List<Patient> get patients => List.unmodifiable(_patients);

// ❌ Incorrecto - Expone referencia mutable
Map<int, int> get responses => _responses;
List<Patient> get patients => _patients;
```

### 3. Notificación de Cambios

```dart
// ✅ Correcto
void selectOption(int value) {
  _selectedOption = value;
  notifyListeners(); // Notificar después de cambiar estado
}

// ❌ Incorrecto
void selectOption(int value) {
  notifyListeners(); // Notificar antes de cambiar estado
  _selectedOption = value;
}
```

### 4. Manejo de Errores

```dart
// ✅ Correcto
Future<SaveResult> saveSurvey() async {
  _isSaving = true;
  notifyListeners();

  try {
    // Lógica
    return SaveResult(success: true);
  } catch (e) {
    return SaveResult(success: false, error: e.toString());
  } finally {
    _isSaving = false;
    notifyListeners();
  }
}

// ❌ Incorrecto - No maneja errores
Future<void> saveSurvey() async {
  _isSaving = true;
  notifyListeners();
  
  // Lógica que puede fallar
  
  _isSaving = false;
  notifyListeners();
}
```

### 5. Cleanup en dispose()

```dart
// ✅ Correcto
@override
void dispose() {
  _timer?.cancel();
  _subscription?.cancel();
  super.dispose();
}

// ❌ Incorrecto - No limpia recursos
@override
void dispose() {
  super.dispose();
}
```

### 6. Dependencias por Constructor

```dart
// ✅ Correcto - Inyección de dependencias
class MiController extends ChangeNotifier {
  final MiService service;
  
  MiController({required this.service});
}

// ❌ Incorrecto - Crear dependencias internamente
class MiController extends ChangeNotifier {
  final service = MiService();
}
```

## 📚 Ejemplos

### Ejemplo Completo: Feature de Contador

#### Controller

```dart
// lib/controllers/counter_controller.dart
import 'package:flutter/material.dart';

class CounterController extends ChangeNotifier {
  int _count = 0;
  int _step = 1;

  int get count => _count;
  int get step => _step;

  void increment() {
    _count += _step;
    notifyListeners();
  }

  void decrement() {
    _count -= _step;
    notifyListeners();
  }

  void setStep(int newStep) {
    _step = newStep;
    notifyListeners();
  }

  void reset() {
    _count = 0;
    _step = 1;
    notifyListeners();
  }
}
```

#### Screen

```dart
// lib/screens/counter_screen.dart
import 'package:flutter/material.dart';
import 'package:ssapp/controllers/counter_controller.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  late CounterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CounterController();
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Count: ${_controller.count}',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _controller.decrement,
                  child: const Text('-'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _controller.increment,
                  child: const Text('+'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Step: ${_controller.step}'),
            Slider(
              value: _controller.step.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (value) => _controller.setStep(value.toInt()),
            ),
            ElevatedButton(
              onPressed: _controller.reset,
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🔄 Migración Progresiva

No es necesario refactorizar todas las pantallas de inmediato. Puedes:

1. **Empezar con pantallas complejas**: Las que tienen más lógica de negocio
2. **Refactorizar cuando se modifiquen**: Al agregar features o corregir bugs
3. **Mantener consistencia**: Nuevas pantallas deberían usar controladores

## 🧪 Testing

Los controladores son fáciles de testear:

```dart
// test/controllers/counter_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ssapp/controllers/counter_controller.dart';

void main() {
  group('CounterController', () {
    late CounterController controller;

    setUp(() {
      controller = CounterController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial count is 0', () {
      expect(controller.count, 0);
    });

    test('increment increases count by step', () {
      controller.increment();
      expect(controller.count, 1);
    });

    test('setStep changes step value', () {
      controller.setStep(5);
      expect(controller.step, 5);
      
      controller.increment();
      expect(controller.count, 5);
    });

    test('reset returns to initial state', () {
      controller.setStep(5);
      controller.increment();
      controller.increment();
      
      controller.reset();
      
      expect(controller.count, 0);
      expect(controller.step, 1);
    });
  });
}
```

## 📖 Recursos Adicionales

- [Flutter ChangeNotifier Documentation](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)
- [State Management in Flutter](https://docs.flutter.dev/development/data-and-backend/state-mgmt)
- [Clean Architecture in Flutter](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## 🤝 Contribuir

Al agregar nuevas pantallas o features:

1. Crea primero el controlador con la lógica de negocio
2. Mantén la pantalla enfocada solo en UI
3. Documenta métodos públicos importantes
4. Agrega tests para el controlador
5. Actualiza este README si es necesario

---

**Última actualización**: Marzo 2026  
**Mantenido por**: Equipo SSApp
