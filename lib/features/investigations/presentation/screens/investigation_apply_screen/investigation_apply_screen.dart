import 'package:flutter/material.dart' as material;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/data/investigation_repository.dart';
import 'package:ssapp/features/investigations/domain/investigation_model.dart';
import 'package:ssapp/features/investigations/presentation/screens/investigation_apply_screen/components/apply_consent_card/view.dart';
import 'package:ssapp/features/investigations/presentation/screens/investigation_apply_screen/components/apply_header/view.dart';
import 'package:ssapp/features/investigations/presentation/screens/investigation_apply_screen/components/apply_patient_picker/view.dart';
import 'package:ssapp/features/investigations/presentation/screens/investigation_apply_screen/components/survey_launch_card/view.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/features/surveys/domain/survey_type_config.dart';
import 'package:ssapp/features/surveys/presentation/consent_form_screen.dart';

class InvestigationApplyScreen extends StatefulWidget {
  final int investigationId;

  const InvestigationApplyScreen({
    super.key,
    required this.investigationId,
  });

  @override
  State<InvestigationApplyScreen> createState() => _InvestigationApplyScreenState();
}

class _InvestigationApplyScreenState extends State<InvestigationApplyScreen> {
  static final Map<String, Set<String>> _sessionCompletedSurveysByContext = <String, Set<String>>{};

  bool _isLoading = true;
  bool _isRunningInitialConsent = false;
  int? _selectedPatientId;
  // Mantener qué pacientes ya dieron consentimiento en esta sesión para evitar mostrar el formulario otra vez.
  final Set<int> _consentedPatientIds = {};
  // Mantener que encuestas fueron completadas para el paciente actual (por codigo de tipo: 'bdi','phq9',...).
  final Set<String> _completedSurveyTypes = {};
  String? _lastProcessedCompletionToken;

  String _contextKey(int patientId) => '${widget.investigationId}:$patientId';

  Set<String> _sessionCompletedForPatient(int patientId) {
    return _sessionCompletedSurveysByContext[_contextKey(patientId)] ?? <String>{};
  }

  void _markCompletedInSession(int patientId, String surveyType) {
    final key = _contextKey(patientId);
    final set = _sessionCompletedSurveysByContext.putIfAbsent(key, () => <String>{});
    set.add(surveyType);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _consumeCompletionFromRoute();
  }

  void _consumeCompletionFromRoute() {
    final params = GoRouterState.of(context).uri.queryParameters;
    final completedSurvey = params['completedSurvey'];
    final completedPatientId = int.tryParse(params['patientId'] ?? '');
    if (completedSurvey == null || completedPatientId == null) return;

    final token = '$completedPatientId:$completedSurvey';
    if (_lastProcessedCompletionToken == token) return;
    _lastProcessedCompletionToken = token;

    if (_selectedPatientId == null) {
      _selectedPatientId = completedPatientId;
    }
    if (_selectedPatientId == completedPatientId) {
      _completedSurveyTypes.add(completedSurvey);
    }
    _markCompletedInSession(completedPatientId, completedSurvey);
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      context.read<InvestigationService>().loadInvestigations(),
      context.read<PatientService>().loadPatients(),
      context.read<SurveyService>().loadSurveys(),
    ]);
    if (mounted) {
      // Mostrar el formulario de consentimiento inicial SOLO si el navigador indicó showConsent=1
      final params = GoRouterState.of(context).uri.queryParameters;
      final showConsent = params['showConsent'] == '1' || params['showConsent'] == 'true';
      if (showConsent && _selectedPatientId == null) {
        setState(() => _isRunningInitialConsent = true);
        await _maybeShowInitialConsent();
        if (!mounted) return;
        setState(() => _isRunningInitialConsent = false);
      }

      // Procesar si venimos de una encuesta completada y marcarla
      _consumeCompletionFromRoute();

      setState(() => _isLoading = false);
    }
  }

  Future<void> _maybeShowInitialConsent() async {
    final investigation = context.read<InvestigationService>().byId(widget.investigationId);
    if (investigation == null) return;

    // Si ya tenemos un paciente seleccionado y consentido, no mostrar.
    if (_selectedPatientId != null && _consentedPatientIds.contains(_selectedPatientId)) return;

    // Abrir pantalla de consentimiento en modo no-autonavegacion para obtener/crear paciente.
    final result = await Navigator.of(context).push(material.MaterialPageRoute(builder: (ctx) {
      return ConsentFormScreen(
        surveyType: null,
        consentText: investigation.formConsent,
        autoNavigate: false,
        showPatientSection: true,
        showConsentSection: true,
      );
    }));

    if (result == null) {
      // Si el usuario cancela el formulario inicial de consentimiento, volvemos a la pantalla
      // anterior (detalle de la investigacion) en lugar de quedarnos en la pantalla de aplicar.
      if (mounted) Navigator.of(context).pop();
      return;
    }
    final Map? map = result as Map?;
    if (map == null) return;
    final returnedPatientId = map['patientId'] as int?;
    if (returnedPatientId == null) return;

    // Guardar selección y vincular participante
    setState(() => _selectedPatientId = returnedPatientId);
    await context.read<InvestigationService>().linkParticipant(
      investigationId: widget.investigationId,
      patientId: returnedPatientId,
    );
    setState(() => _consentedPatientIds.add(returnedPatientId));
  }

  Future<void> _launchSurvey(BuildContext context, String surveyType) async {
    final patientId = _selectedPatientId;
    if (patientId == null) {
      showToast(
        context: context,
        builder: (context, overlay) => SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Selecciona un participante antes de aplicar una encuesta.').small(),
          ),
        ),
        location: ToastLocation.bottomCenter,
      );
      return;
    }

    // Special case: en investigaciones, osteoporosis siempre solicita peso/talla/IMC antes de aplicar.
    if (surveyType == 'osteoporosis') {
      final result = await Navigator.of(context).push(material.MaterialPageRoute(builder: (ctx) {
        return ConsentFormScreen(
          surveyType: 'osteoporosis',
          consentText: null,
          autoNavigate: false,
          showPatientSection: false,
          showConsentSection: false,
          initialPatientId: patientId,
        );
      }));

      if (result == null) return;
      final Map? map = result as Map?;
      if (map == null) return;
      final returnedPatientId = map['patientId'] as int?;
      final weight = map['weight'];
      final height = map['height'];
      final imc = map['imc'];
      if (returnedPatientId == null) return;

      await context.read<InvestigationService>().linkParticipant(
        investigationId: widget.investigationId,
        patientId: returnedPatientId,
      );
      setState(() => _consentedPatientIds.add(returnedPatientId));

      context.push('/survey/$returnedPatientId?surveyType=$surveyType&weight=${weight ?? ''}&height=${height ?? ''}&imc=${imc ?? ''}&fromInvestigation=${widget.investigationId}');
      return;
    }

    // Si ya dimos consentimiento previo para este paciente en la investigación, para el resto de encuestas
    // navegamos directo sin volver a pedir consentimiento.
    if (_consentedPatientIds.contains(patientId)) {
      context.push('/survey/$patientId?surveyType=$surveyType&fromInvestigation=${widget.investigationId}');
      return;
    }

    // Abrir pantalla de consentimiento usando Navigator para pasar parametros complejos
    Navigator.of(context).push(material.MaterialPageRoute(builder: (ctx) {
      return ConsentFormScreen(
        surveyType: surveyType,
        consentText: context.read<InvestigationService>().byId(widget.investigationId)?.formConsent,
        autoNavigate: false,
        initialPatientId: patientId,
      );
    })).then((result) async {
      if (result == null) return;
      final Map? map = result as Map?;
      if (map == null) return;
      final returnedPatientId = map['patientId'] as int?;
      final returnedSurveyType = map['surveyType'] as String? ?? surveyType;
      final weight = map['weight'];
      final height = map['height'];
      final imc = map['imc'];

      if (returnedPatientId == null) return;

      // Vincular participante a la investigacion
      await context.read<InvestigationService>().linkParticipant(
        investigationId: widget.investigationId,
        patientId: returnedPatientId,
      );

      // Marcar que este paciente ya otorgó consentimiento en esta sesión
      setState(() => _consentedPatientIds.add(returnedPatientId));

      // Navegar a la encuesta correspondiente
      if (returnedSurveyType == 'osteoporosis') {
        context.push(
          '/survey/$returnedPatientId?surveyType=$returnedSurveyType&weight=${weight ?? ''}&height=${height ?? ''}&imc=${imc ?? ''}&fromInvestigation=${widget.investigationId}',
        );
      } else {
        context.push('/survey/$returnedPatientId?surveyType=$returnedSurveyType&fromInvestigation=${widget.investigationId}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final investigation = context.watch<InvestigationService>().byId(widget.investigationId);
    final patients = context.watch<PatientService>().patients;
    final allSurveys = context.watch<SurveyService>().surveys;
    final routeParams = GoRouterState.of(context).uri.queryParameters;
    final completedSurveyFromRoute = routeParams['completedSurvey'];
    final completedPatientIdFromRoute = int.tryParse(routeParams['patientId'] ?? '');
    final selectedPatientId = _selectedPatientId;
    final completedFromStorage = selectedPatientId == null
        ? <String>{}
        : _completedSurveyTypesFromStorage(
            surveys: allSurveys,
            investigationId: widget.investigationId,
            patientId: selectedPatientId,
          );
    final completedFromSession = selectedPatientId == null
        ? <String>{}
        : _sessionCompletedForPatient(selectedPatientId);
    final completedSurveyTypes = {
      ..._completedSurveyTypes,
      ...completedFromStorage,
      ...completedFromSession,
      if (completedSurveyFromRoute != null && selectedPatientId != null && completedPatientIdFromRoute == selectedPatientId)
        completedSurveyFromRoute,
    };
    final investigationSurveyTypes = investigation == null
        ? <String>[]
        : _surveyItems(investigation).map((e) => e.surveyType).toList();
    final allCompleted = selectedPatientId != null &&
        investigationSurveyTypes.isNotEmpty &&
        investigationSurveyTypes.every(completedSurveyTypes.contains);

    return Scaffold(
      headers: [
        ApplyInvestigationHeader(
          investigationId: widget.investigationId,
          investigationTitle: investigation?.investigationName ?? 'Investigacion',
        ),
      ],
      child: (_isLoading || _isRunningInitialConsent)
          ? const Center(child: CircularProgressIndicator())
          : investigation == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(material.Icons.science_outlined, size: 64),
                        const Gap(12),
                        const Text('No se encontro la investigacion').semiBold(),
                        const Gap(8),
                        OutlineButton(onPressed: () => context.pop(), child: const Text('Volver')),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ApplyConsentCard(consentText: investigation.formConsent),
                      const Gap(16),
                      if (_selectedPatientId == null) ...[
                        const Text('Selecciona un participante').semiBold(),
                        const Gap(8),
                        ApplyPatientPicker(
                          patients: patients,
                          selectedPatientId: _selectedPatientId,
                          onSelected: (patientId) => setState(() => _selectedPatientId = patientId),
                        ),
                      ] else ...[
                        const Text('Participante seleccionado').semiBold(),
                        const Gap(8),
                        SurfaceCard(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(patients.firstWhere((p) => p.patientId == _selectedPatientId).name).semiBold(),
                                      const Gap(6),
                                      Text('Edad: ${patients.firstWhere((p) => p.patientId == _selectedPatientId).age} años').muted(),
                                    ],
                                  ),
                                ),
                                OutlineButton(
                                  onPressed: () {
                                    // Permitir cambiar participante si se necesita
                                    setState(() {
                                      _consentedPatientIds.remove(_selectedPatientId);
                                      _selectedPatientId = null;
                                    });
                                  },
                                  child: const Text('Cambiar'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Gap(12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlineButton(
                            onPressed: allCompleted
                                ? () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Finalizar participación'),
                                  content: const Text('¿Desea finalizar la participación del participante en esta investigación?'),
                                  actions: [
                                         OutlineButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                                               PrimaryButton(onPressed: allCompleted ? () => Navigator.of(ctx).pop(true) : null, child: const Text('Finalizar')),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                // Redirigir a la pantalla de detalle de la investigacion
                                context.go('/investigations/${widget.investigationId}');
                              }
                            }
                                : null,
                            child: const Text('Finalizar participación'),
                          ),
                        ),
                            if (!allCompleted) ...[
                              const Gap(8),
                              const Text('Completa todas las encuestas para habilitar finalizar participación.').small().muted(),
                            ],
                      ],
                      const Gap(16),
                      const Text('Encuestas de la investigacion').semiBold(),
                      const Gap(8),
                      for (final survey in _surveyItems(investigation)) ...[
                        SurveyLaunchCard(
                          title: survey.title,
                          description: survey.description,
                          itemCount: survey.itemCount,
                          enabled: _selectedPatientId != null && !completedSurveyTypes.contains(survey.surveyType),
                          onTap: () => _launchSurvey(context, survey.surveyType),
                        ),
                        const Gap(10),
                      ],
                    ],
                  ),
                ),
    );
  }

  Set<String> _completedSurveyTypesFromStorage({
    required List<Map<String, dynamic>> surveys,
    required int investigationId,
    required int patientId,
  }) {
    final completed = <String>{};
    for (final survey in surveys) {
      final invId = survey['investigation_id'] as int?;
      final pId = survey['patient_id'] as int?;
      final surveyTypeId = survey['survey_type'] as int?;
      if (invId != investigationId || pId != patientId || surveyTypeId == null) continue;
      final code = InvestigationService.surveyTypeToRouteCode[surveyTypeId];
      if (code != null) completed.add(code);
    }
    return completed;
  }

  List<_SurveyLaunchItem> _surveyItems(InvestigationModel investigation) {
    return investigation.surveyTypeIds
        .where(InvestigationService.surveyTypeToRouteCode.containsKey)
        .map((id) {
      final surveyType = InvestigationService.surveyTypeToRouteCode[id]!;
      return _SurveyLaunchItem(
        surveyType: surveyType,
        title: InvestigationService.surveyTypes[id] ?? 'Tipo $id',
        description: SurveyTypeConfig.descriptionFor(surveyType),
        itemCount: SurveyTypeConfig.itemCountFor(surveyType),
      );
    }).toList();
  }
}

class _SurveyLaunchItem {
  final String surveyType;
  final String title;
  final String description;
  final int itemCount;

  const _SurveyLaunchItem({
    required this.surveyType,
    required this.title,
    required this.description,
    required this.itemCount,
  });
}



