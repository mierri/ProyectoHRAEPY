import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/Services/patient_service.dart';
import 'package:ssapp/Services/survey_service.dart';
import 'package:ssapp/models/patient_model.dart';
import 'package:ssapp/utils/theme.dart';
import 'package:ssapp/utils/toast_helper.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final patientService = context.read<PatientService>();
    final surveyService = context.read<SurveyService>();

    await Future.wait([
      patientService.loadPatients(),
      surveyService.loadSurveys(),
    ]);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<PatientModel> _getFilteredPatients(List<PatientModel> patients) {
    if (_searchQuery.isEmpty) return patients;

    return patients.where((patient) {
      return patient.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final patientService = context.watch<PatientService>();
    final allPatients = patientService.patients;
    final patients = _getFilteredPatients(allPatients);

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Pacientes'),
          leading: [
            IconButton(
              icon: const Icon(material.Icons.arrow_back),
              onPressed: () => context.pop(),
              variance: ButtonVariance.ghost,
            ),
          ],
          trailing: [
            IconButton(
              icon: const Icon(material.Icons.refresh),
              onPressed: _isLoading ? null : _loadData,
              variance: ButtonVariance.ghost,
            ),
            const Gap(8),
            PrimaryButton(
              density: ButtonDensity.icon,
              onPressed: () => _showAddPatientDialog(context),
              child: const Icon(material.Icons.add),
            ),
          ],
        ),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    placeholder: const Text('Buscar paciente por nombre...'),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),
                if (_searchQuery.isNotEmpty) ...[
                  const Gap(8),
                  IconButton(
                    icon: const Icon(material.Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    variance: ButtonVariance.ghost,
                  ),
                ],
              ],
            ),
          ),

          // Lista de pacientes
          Expanded(
            child: patients.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    material.Icons.people_outline,
                    size: 80,
                    color: Theme.of(context).colorScheme.mutedForeground,
                  ),
                  const Gap(16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No hay pacientes registrados'
                        : 'No se encontraron resultados',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.mutedForeground,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    _searchQuery.isEmpty
                        ? 'Agrega un nuevo paciente para comenzar'
                        : 'Intenta con otro término de búsqueda',
                  ).muted().small(),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              itemCount: patients.length,
              separatorBuilder: (context, index) => const Gap(12),
              itemBuilder: (context, index) {
                final patient = patients[index];
                return _PatientCard(patient: patient);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPatientDialog(BuildContext context) {
    final nameController = TextEditingController();
    DateTime? selectedBirthDate;
    String selectedGender = 'M';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nuevo Paciente'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nombre completo').semiBold(),
                const Gap(8),
                TextField(
                  controller: nameController,
                  placeholder: const Text('Ingrese el nombre del paciente'),
                ),
                const Gap(16),

                const Text('Sexo').semiBold(),
                const Gap(8),
                Row(
                  children: [
                    Expanded(
                      child: selectedGender == 'M'
                          ? PrimaryButton(
                        onPressed: () {
                          setDialogState(() => selectedGender = 'M');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(material.Icons.male, size: 18),
                            const Gap(8),
                            const Text('Masculino'),
                          ],
                        ),
                      )
                          : OutlineButton(
                        onPressed: () {
                          setDialogState(() => selectedGender = 'M');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(material.Icons.male, size: 18),
                            const Gap(8),
                            const Text('Masculino'),
                          ],
                        ),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: selectedGender == 'F'
                          ? PrimaryButton(
                        onPressed: () {
                          setDialogState(() => selectedGender = 'F');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(material.Icons.female, size: 18),
                            const Gap(8),
                            const Text('Femenino'),
                          ],
                        ),
                      )
                          : OutlineButton(
                        onPressed: () {
                          setDialogState(() => selectedGender = 'F');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(material.Icons.female, size: 18),
                            const Gap(8),
                            const Text('Femenino'),
                          ],
                        ),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: selectedGender == 'O'
                          ? PrimaryButton(
                        onPressed: () {
                          setDialogState(() => selectedGender = 'O');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(material.Icons.transgender, size: 18),
                            const Gap(8),
                            const Text('Otro'),
                          ],
                        ),
                      )
                          : OutlineButton(
                        onPressed: () {
                          setDialogState(() => selectedGender = 'O');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(material.Icons.transgender, size: 18),
                            const Gap(8),
                            const Text('Otro'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(16),

                const Text('Fecha de nacimiento').semiBold(),
                const Gap(8),
                DatePicker(
                  value: selectedBirthDate,
                  mode: PromptMode.dialog,
                  placeholder: const Text('Seleccionar fecha'),
                  stateBuilder: (date) {
                    if (date.isAfter(DateTime.now())) {
                      return DateState.disabled;
                    }
                    return DateState.enabled;
                  },
                  onChanged: (date) {
                    setDialogState(() => selectedBirthDate = date);
                  },
                ),
              ],
            ),
          ),
          actions: [
            OutlineButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            PrimaryButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  showCenteredToast(
                    context,
                    title: 'Campo requerido',
                    subtitle: 'Por favor ingrese el nombre del paciente',
                    icon: material.Icons.warning,
                    iconColor: LightModeColors.lightError,
                    location: ToastLocation.topCenter,
                  );
                  return;
                }

                if (selectedBirthDate == null) {
                  showCenteredToast(
                    context,
                    title: 'Campo requerido',
                    subtitle: 'Por favor seleccione la fecha de nacimiento',
                    icon: material.Icons.warning,
                    iconColor: LightModeColors.lightError,
                    location: ToastLocation.topCenter,
                  );
                  return;
                }

                // Crear paciente
                final patientService = context.read<PatientService>();
                final patient = await patientService.createPatient(
                  name: nameController.text.trim(),
                  gender: selectedGender,
                  birthDate: selectedBirthDate!,
                );

                if (context.mounted) {
                  Navigator.of(context).pop();

                  if (patient != null) {
                    showCenteredToast(
                      context,
                      title: 'Paciente creado',
                      subtitle: '${patient.name} agregado exitosamente',
                      icon: material.Icons.check_circle,
                      iconColor: LightModeColors.lightTertiary,
                      location: ToastLocation.bottomCenter,
                    );
                  } else {
                    showCenteredToast(
                      context,
                      title: 'Error',
                      subtitle: 'No se pudo crear el paciente',
                      icon: material.Icons.error,
                      iconColor: LightModeColors.lightError,
                      location: ToastLocation.bottomCenter,
                    );
                  }
                }
              },
              child: const Text('Crear Paciente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final PatientModel patient;

  const _PatientCard({required this.patient});

  String _getGenderLabel(String gender) {
    switch (gender) {
      case 'M':
        return 'Masculino';
      case 'F':
        return 'Femenino';
      case 'O':
        return 'Otro';
      default:
        return gender;
    }
  }

  IconData _getGenderIcon(String gender) {
    switch (gender) {
      case 'M':
        return material.Icons.male;
      case 'F':
        return material.Icons.female;
      case 'O':
        return material.Icons.transgender;
      default:
        return material.Icons.person;
    }
  }

  Color _getGenderColor(String gender) {
    switch (gender) {
      case 'M':
        return LightModeColors.lightPrimary;
      case 'F':
        return const Color(0xFFEC4899); // Pink
      case 'O':
        return LightModeColors.lightSecondary;
      default:
        return LightModeColors.lightPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final surveyService = context.watch<SurveyService>();
    final patientSurveys = surveyService.surveys.where((s) {
      return s['patient_id'] == patient.patientId;
    }).toList();

    final completedSurveys = patientSurveys.where((s) {
      final responses = s['responses'] as List?;
      return responses != null && responses.isNotEmpty;
    }).length;

    return GestureDetector(
      onTap: () => _showPatientDetails(context),
      child: OutlinedContainer(
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icono de género
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getGenderColor(patient.gender).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getGenderIcon(patient.gender),
                    color: _getGenderColor(patient.gender),
                    size: 28,
                  ),
                ),
                const Gap(16),

                // Información del paciente
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              patient.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!patient.synced)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: LightModeColors.lightError.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    material.Icons.cloud_off,
                                    size: 12,
                                    color: LightModeColors.lightError,
                                  ),
                                  const Gap(4),
                                  Text(
                                    'Sin sincronizar',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: LightModeColors.lightError,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const Gap(6),
                      Wrap(
                        spacing: 0,
                        runSpacing: 2,
                        children: [
                          Text('${patient.age} años').muted().small(),
                          Text(' • ').muted().small(),
                          Text(_getGenderLabel(patient.gender)).muted().small(),
                          Text(' • ').muted().small(),
                          Text(DateFormat('dd/MM/yyyy').format(patient.birthDate)).muted().small(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Gap(16),
            const Divider(),
            const Gap(16),

            // Estadísticas del paciente
            Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    icon: material.Icons.assignment,
                    label: '$completedSurveys encuesta${completedSurveys != 1 ? 's' : ''}',
                    color: LightModeColors.lightPrimary,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: _InfoChip(
                    icon: material.Icons.calendar_today,
                    label: 'ID: ${patient.patientId}',
                    color: LightModeColors.lightSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPatientDetails(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _PatientDetailsDialog(patient: patient),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const Gap(6),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.foreground,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _PatientDetailsDialog extends StatelessWidget {
  final PatientModel patient;

  const _PatientDetailsDialog({required this.patient});

  String _getGenderLabel(String gender) {
    switch (gender) {
      case 'M':
        return 'Masculino';
      case 'F':
        return 'Femenino';
      case 'O':
        return 'Otro';
      default:
        return gender;
    }
  }

  @override
  Widget build(BuildContext context) {
    final surveyService = context.watch<SurveyService>();
    final patientSurveys = surveyService.surveys.where((s) {
      return s['patient_id'] == patient.patientId;
    }).toList();

    // Ordenar por fecha (más reciente primero)
    patientSurveys.sort((a, b) {
      final aTime = DateTime.parse(a['created_at']);
      final bTime = DateTime.parse(b['created_at']);
      return bTime.compareTo(aTime);
    });

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 450,
          maxHeight: 600,
        ),
        child: SurfaceCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  children: [
                    Icon(
                      material.Icons.person,
                      color: LightModeColors.lightPrimary,
                    ),
                    const Gap(12),
                    const Expanded(
                      child: Text(
                        'Detalles del Paciente',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Información básica
                      SurfaceCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Información Personal').semiBold().large(),
                              const Gap(16),
                              _buildInfoRow(
                                context,
                                material.Icons.person,
                                'Nombre',
                                patient.name,
                              ),
                              const Gap(12),
                              _buildInfoRow(
                                context,
                                material.Icons.cake,
                                'Edad',
                                '${patient.age} años',
                              ),
                              const Gap(12),
                              _buildInfoRow(
                                context,
                                material.Icons.calendar_today,
                                'Fecha de nacimiento',
                                DateFormat('dd/MM/yyyy').format(patient.birthDate),
                              ),
                              const Gap(12),
                              _buildInfoRow(
                                context,
                                material.Icons.wc,
                                'Sexo',
                                _getGenderLabel(patient.gender),
                              ),
                              const Gap(12),
                              _buildInfoRow(
                                context,
                                material.Icons.fingerprint,
                                'ID del Paciente',
                                patient.patientId.toString(),
                              ),
                              const Gap(12),
                              _buildInfoRow(
                                context,
                                material.Icons.cloud_sync,
                                'Estado de sincronización',
                                patient.synced ? 'Sincronizado' : 'Pendiente',
                                valueColor: patient.synced
                                    ? LightModeColors.lightTertiary
                                    : LightModeColors.lightError,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Gap(24),

                      // Historial de encuestas
                      Row(
                        children: [
                          const Text('Historial de Encuestas').semiBold().large(),
                          const Gap(8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: LightModeColors.lightPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${patientSurveys.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: LightModeColors.lightPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(16),

                      if (patientSurveys.isEmpty)
                        SurfaceCard(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    material.Icons.assignment_outlined,
                                    size: 48,
                                    color: Theme.of(context).colorScheme.mutedForeground,
                                  ),
                                  const Gap(12),
                                  const Text('No hay encuestas registradas').muted(),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        ...patientSurveys.map((survey) {
                          final responses = survey['responses'] as List?;
                          final isComplete = responses != null && responses.isNotEmpty;
                          final score = isComplete ? surveyService.calculateSurveyScore(survey) : 0;
                          final surveyType = survey['survey_type'] as int? ?? 1;
                          String getSurveyTypeName(int type) {
                            switch (type) {
                              case 1: return 'BDI-II';
                              case 2: return 'BAI';
                              case 3: return 'WHOQOL-BREF';
                              case 4: return 'MoCA';
                              case 5: return 'SF-36';
                              case 6: return 'ASSIST';
                              case 7: return 'GDS-15';
                              case 8: return 'Lawton';
                              case 9: return 'Osteoporosis';
                              case 10: return 'Katz';

                              default: return 'Encuesta';
                            }
                          }

                          final createdAt = DateTime.parse(survey['created_at']);
                          final isSynced = survey['synced'] == true;

                          final surveyTypeName = getSurveyTypeName(surveyType);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: isComplete
                                  ? () {
                                Navigator.of(context).pop();
                                context.push('/survey-result/${survey['survey_id']}');
                              }
                                  : null,
                              child: OutlinedContainer(
                                borderRadius: BorderRadius.circular(12),
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Icono de estado
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isComplete
                                            ? LightModeColors.lightTertiary.withValues(alpha: 0.1)
                                            : LightModeColors.lightError.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        isComplete ? material.Icons.check_circle : material.Icons.pending,
                                        color: isComplete
                                            ? LightModeColors.lightTertiary
                                            : LightModeColors.lightError,
                                        size: 20,
                                      ),
                                    ),
                                    const Gap(16),

                                    // Información de la encuesta
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                surveyTypeName,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const Gap(8),
                                              if (!isSynced)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: LightModeColors.lightError.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        material.Icons.cloud_off,
                                                        size: 10,
                                                        color: LightModeColors.lightError,
                                                      ),
                                                      const Gap(4),
                                                      Text(
                                                        'Sin sync',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: LightModeColors.lightError,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const Gap(4),
                                          Text(
                                            DateFormat('dd/MM/yyyy HH:mm').format(createdAt),
                                          ).muted().small(),
                                          if (isComplete) ...[
                                            const Gap(4),
                                            if (surveyType == 1 || surveyType == 2)
                                              Text(
                                                'Puntaje: $score - ${_getScoreLevel(score, surveyType)}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: _getScoreLevelColor(score, surveyType),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                            else if (surveyType == 3)
                                            // WHOQOL: calcular promedio de dominios
                                              _buildWhoqolScore(survey)
                                            else if (surveyType == 5)
                                              // SF-36: calcular promedio de dimensiones
                                                _buildSF36Score(survey)
                                              else
                                                Text(
                                                  'Encuesta completada',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: _getScoreLevelColor(0, surveyType),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    // Flecha para ver detalles
                                    if (isComplete)
                                      Icon(
                                        material.Icons.chevron_right,
                                        color: Theme.of(context).colorScheme.mutedForeground,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              // Actions
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlineButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context,
      IconData icon,
      String label,
      String value, {
        Color? valueColor,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.mutedForeground,
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label).muted().small(),
              const Gap(4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Theme.of(context).colorScheme.foreground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getScoreLevel(int score, int surveyType) {
    switch (surveyType) {
      case 1: // BDI-II
        if (score <= 13) return 'Mínima';
        if (score <= 19) return 'Leve';
        if (score <= 28) return 'Moderada';
        return 'Severa';
      case 2: // BAI
        if (score <= 7) return 'Mínima';
        if (score <= 15) return 'Leve';
        if (score <= 25) return 'Moderada';
        return 'Severa';
      case 3: // WHOQOL-BREF
        return 'WHOQOL';
      case 4: // MoCA
        return 'MoCA';
      case 5: // SF-36
        return 'SF-36';
      default:
        return '';
    }
  }

  Color _getScoreLevelColor(int score, int surveyType) {
    switch (surveyType) {
      case 1: // BDI-II
        if (score <= 13) return LightModeColors.lightTertiary;
        if (score <= 19) return const Color(0xFFFBBF24);
        if (score <= 28) return const Color(0xFFF97316);
        return LightModeColors.lightError;
      case 2: // BAI
        if (score <= 7) return LightModeColors.lightTertiary;
        if (score <= 15) return const Color(0xFFFBBF24);
        if (score <= 25) return const Color(0xFFF97316);
        return LightModeColors.lightError;
      case 3: // WHOQOL-BREF
        return const Color(0xFF7C3AED);
      case 4: // MoCA
        return const Color(0xFF0EA5E9);
      case 5: // SF-36
        return const Color(0xFF06B6D4);

      default:
        return LightModeColors.lightPrimary;
    }
  }

  Widget _buildWhoqolScore(Map<String, dynamic> survey) {
    final responses = survey['responses'] as List? ?? [];
    if (responses.isEmpty) {
      return Text(
        'Sin puntaje',
        style: TextStyle(fontSize: 12, color: LightModeColors.lightOnSurfaceVariant),
      );
    }

    // Calcular promedio de todas las respuestas como indicador de WHOQOL
    int totalScore = 0;
    for (final response in responses) {
      final value = response['answer_value'] as int? ?? 0;
      totalScore += value;
    }
    final avgScore = (totalScore / responses.length).toStringAsFixed(1);

    String getWhoqolLevel(double score) {
      if (score >= 4.0) return 'Excelente';
      if (score >= 3.5) return 'Muy bueno';
      if (score >= 3.0) return 'Bueno';
      if (score >= 2.5) return 'Regular';
      return 'Bajo';
    }

    return Text(
      'Promedio: $avgScore/5 - ${getWhoqolLevel(totalScore / responses.length)}',
      style: TextStyle(
        fontSize: 12,
        color: const Color(0xFF7C3AED),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSF36Score(Map<String, dynamic> survey) {
    final responses = survey['responses'] as List? ?? [];
    if (responses.isEmpty) {
      return Text(
        'Sin puntaje',
        style: TextStyle(fontSize: 12, color: LightModeColors.lightOnSurfaceVariant),
      );
    }

    // Calcular promedio de todas las respuestas como indicador de SF-36
    // SF-36 usa escala 0-100 transformada
    int totalScore = 0;
    for (final response in responses) {
      final value = response['answer_value'] as int? ?? 0;
      totalScore += value;
    }
    final avgScore = (totalScore / responses.length).toStringAsFixed(1);

    String getSF36Level(double score) {
      if (score >= 4.0) return 'Excelente';
      if (score >= 3.5) return 'Muy bueno';
      if (score >= 3.0) return 'Bueno';
      if (score >= 2.5) return 'Regular';
      return 'Bajo';
    }

    return Text(
      'Promedio: $avgScore/5 - ${getSF36Level(totalScore / responses.length)}',
      style: TextStyle(
        fontSize: 12,
        color: const Color(0xFF06B6D4),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
