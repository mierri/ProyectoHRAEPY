# Almacenamiento Offline con Hive

La aplicación ahora guarda **pacientes** y **encuestas** localmente usando **Hive**, permitiendo trabajar sin conexión a internet.

## 🔄 Cómo Funciona

### **Pacientes (PatientProvider)**
- Se guardan localmente en `patientBox`
- Al agregar/editar: se intenta sincronizar con Supabase inmediatamente
- Si no hay conexión: se marca como `synced: false`
- Cuando vuelva la conexión: usar `syncPendingPatients()` para enviar pendientes

### **Encuestas (SurveyProvider)**
- Se guardan localmente en `surveyBox`
- Mismo funcionamiento que pacientes
- Método `syncPendingSurveys()` para sincronizar pendientes

## 📦 Archivos Creados/Modificados

### Modelos
- [patient_model.dart](lib/models/patient_model.dart) - Ahora con campo `synced` y typeId: 2
- [patient_model.g.dart](lib/models/patient_model.g.dart) - Adaptador generado por Hive

### Providers
- [patient_provider.dart](lib/provider/patient_provider.dart) - Nuevo provider para pacientes
- [survey_provider.dart](lib/provider/survey_provider.dart) - Ya existía

### Configuración
- [main.dart](lib/main.dart) - Registra adaptadores de Hive

### Ejemplo
- [patient_list_page_example.dart](lib/pages/patient_list_page_example.dart) - Ejemplo de uso

## 🚀 Uso del PatientProvider

```dart
// Inicializar
final provider = PatientProvider();
await provider.initBox();

// Agregar paciente (intenta sincronizar automáticamente)
final patient = PatientModel(
  patientId: DateTime.now().millisecondsSinceEpoch,
  name: 'Juan Pérez',
  gender: 'M',
  birthDate: DateTime(1990, 5, 15),
);
await provider.addPatient(patient);

// Obtener todos los pacientes
List<PatientModel> patients = provider.getAllPatientsAsList();

// Buscar paciente por ID
PatientModel? patient = provider.getPatientById(12345);

// Actualizar paciente
await provider.updatePatient(index, patientModificado);

// Eliminar paciente
await provider.deletePatient(index);

// Sincronizar pacientes pendientes (cuando vuelva conexión)
await provider.syncPendingPatients();

// Descargar pacientes desde Supabase
await provider.syncFromSupabase();

// Cerrar al terminar
await provider.dispose();
```

## 🔍 Verificar Estado de Sincronización

Cada paciente y encuesta tiene un campo `synced`:
- `synced: true` ✅ = Ya está en Supabase
- `synced: false` ⚠️ = Pendiente de sincronizar

```dart
if (!patient.synced) {
  print('Este paciente aún no se ha sincronizado');
}
```

## 🌐 Sincronización Bidireccional

### De Local → Supabase
```dart
await provider.syncPendingPatients();
```
Envía todos los pacientes con `synced: false` a Supabase.

### De Supabase → Local
```dart
await provider.syncFromSupabase();
```
Descarga pacientes del servidor y actualiza/agrega localmente.

## ⚙️ TypeIDs de Hive

- **ResponseModel**: typeId 1
- **SurveyModel**: typeId 0
- **PatientModel**: typeId 2 ✅ (corregido para evitar conflictos)

## 🔧 Regenerar Adaptadores

Si modificas los modelos (agregar/quitar campos con @HiveField):

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📱 Flujo Recomendado

1. **Al iniciar la app**: Llamar `syncFromSupabase()` para descargar datos
2. **Durante uso offline**: Agregar/editar normalmente, se guarda local
3. **Al recuperar conexión**: Llamar `syncPendingPatients()` para enviar cambios
4. **Opcional**: Mostrar indicador visual (ícono) para datos no sincronizados

## ✨ Ventajas

- ✅ Trabajo offline completo
- ✅ Sincronización automática cuando hay conexión
- ✅ Datos persistentes entre sesiones
- ✅ No se pierde información
- ✅ Sincronización bidireccional
