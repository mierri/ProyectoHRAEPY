// EJEMPLO DE USO DEL PATIENTPROVIDER
// Este archivo muestra cómo usar el PatientProvider para gestionar pacientes con almacenamiento offline

import 'package:flutter/material.dart';
import 'package:ssapp/models/patient_model.dart';
import 'package:ssapp/provider/patient_provider.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  final PatientProvider _provider = PatientProvider();
  bool _isLoading = true;
  List<PatientModel> _patients = [];

  @override
  void initState() {
    super.initState();
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await _provider.initBox();
    await _syncPatients();
    _loadPatients();
  }

  Future<void> _syncPatients() async {
    try {
      // Sincronizar pacientes pendientes locales a Supabase
      await _provider.syncPendingPatients();
      
      // Descargar pacientes desde Supabase
      await _provider.syncFromSupabase();
      
      _loadPatients();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pacientes sincronizados')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al sincronizar: $e')),
        );
      }
    }
  }

  void _loadPatients() {
    setState(() {
      _patients = _provider.getAllPatientsAsList();
      _isLoading = false;
    });
  }

  Future<void> _addPatient() async {
    // Ejemplo: agregar un nuevo paciente
    final newPatient = PatientModel(
      patientId: DateTime.now().millisecondsSinceEpoch,
      name: 'Nuevo Paciente',
      gender: 'M',
      birthDate: DateTime(1990, 1, 1),
    );

    await _provider.addPatient(newPatient);
    _loadPatients();
  }

  Future<void> _deletePatient(int index) async {
    await _provider.deletePatient(index);
    _loadPatients();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _syncPatients,
            tooltip: 'Sincronizar con servidor',
          ),
        ],
      ),
      body: _patients.isEmpty
          ? const Center(child: Text('No hay pacientes registrados'))
          : ListView.builder(
              itemCount: _patients.length,
              itemBuilder: (context, index) {
                final patient = _patients[index];
                return ListTile(
                  leading: Icon(
                    patient.synced ? Icons.cloud_done : Icons.cloud_off,
                    color: patient.synced ? Colors.green : Colors.orange,
                  ),
                  title: Text(patient.name),
                  subtitle: Text(
                    '${patient.gender} - ${patient.age} años',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deletePatient(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPatient,
        child: const Icon(Icons.add),
      ),
    );
  }
}
