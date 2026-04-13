import 'package:hive/hive.dart';
import 'package:ssapp/core/supabase/supabase_config.dart';
import 'package:ssapp/features/surveys/data/survey_repository.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/features/surveys/types/osteoporosis/domain/osteoporosis_risk_model.dart';
import 'package:ssapp/features/surveys/types/osteoporosis/domain/osteoporosis_risk_service.dart';
import 'package:ssapp/shared/models/patient_model.dart';
import 'package:ssapp/shared/utils/gender_mapper.dart';

class SaveOsteoporosisSurveyUseCase {
  Future<OsteoporosisSaveResult> execute({
    required int patientId,
    required double weightKg,
    required double heightMeters,
    required List<bool> answers,
    required SurveyService surveyService,
  }) async {
    try {
      final patient = await _loadPatient(patientId);
      if (patient == null) {
        return const OsteoporosisSaveResult(
          success: false,
          wasSynced: false,
          error: 'Paciente no encontrado',
        );
      }

      patient.weight = weightKg;
      patient.height = heightMeters;
      if (heightMeters > 0) {
        patient.imc = OsteoporosisRiskService.calculateBMI(weightKg, heightMeters);
      }
      // Si el paciente viene de Supabase (no desde Hive), no está en una box local.
      // Guardamos en Hive solo cuando aplica; luego sincronizamos hacia Supabase.
      if (patient.isInBox) {
        await patient.save();
      }

      final sex = _mapSex(patient.gender);
      final patientData = PatientData(
        age: _calculateAge(patient.birthDate),
        weightKg: weightKg,
        heightMeters: heightMeters,
        sex: sex,
        answers: answers,
      );

      final riskResult = OsteoporosisRiskService.calculateRisk(patientData);

      final wasSynced = await SurveyRepository().syncPatientToSupabase(patient);

      return OsteoporosisSaveResult(
        success: true,
        wasSynced: wasSynced,
        riskResult: riskResult,
      );
    } catch (error) {
      return OsteoporosisSaveResult(
        success: false,
        wasSynced: false,
        error: error.toString(),
      );
    }
  }

  Future<PatientModel?> _loadPatient(int patientId) async {
    try {
      final patientsBox = await Hive.openBox<PatientModel>('patients');
      final local = patientsBox.values.where((p) => p.patientId == patientId).toList();
      if (local.isNotEmpty) {
        return local.first;
      }
    } catch (_) {}

    final response = await SupabaseConfig.client
        .from('patients')
        .select()
        .eq('patient_id', patientId)
        .maybeSingle();

    if (response == null) return null;
    return PatientModel.fromJson(response);
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Sex _mapSex(String genderCode) {
    final normalized = GenderMapper.fromDb(genderCode).toUpperCase();
    return normalized == 'M' ? Sex.male : Sex.female;
  }
}

class OsteoporosisSaveResult {
  final bool success;
  final bool wasSynced;
  final RiskResult? riskResult;
  final String? error;

  const OsteoporosisSaveResult({
    required this.success,
    required this.wasSynced,
    this.riskResult,
    this.error,
  });
}
