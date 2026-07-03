import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:ssapp/core/logger/app_logger.dart';
import 'package:ssapp/core/supabase/supabase_config.dart';
import 'package:ssapp/features/investigations/domain/investigation_model.dart';

class InvestigationService extends ChangeNotifier {
  static const Map<int, String> surveyTypes = {
    1: 'BDI-II',
    2: 'BAI',
    3: 'WHOQOL-BREF',
    5: 'SF-36',
    6: 'ASSIST V3.0',
    7: 'GDS-15',
    8: 'Lawton AIVD',
    9: 'Osteoporosis',
    10: 'Katz ABVD',
    11: 'ICIQ-SF',
    12: 'GHQ-12',
    13: 'PHQ-9',
    14: 'Sociodemográfico',
    15: 'Determinantes Sociales',
    16: 'Asistencia en Consulta de Especialidad',
    17: 'Barreras Percibidas para la Asistencia',
    18: 'MoCA 8.1',
    19: 'MoCA Blind',
  };

  static const Map<int, String> surveyTypeToRouteCode = {
    1: 'bdi',
    2: 'bai',
    3: 'whoqol',
    5: 'sf36',
    6: 'assist',
    7: 'gds',
    8: 'lawton',
    9: 'osteoporosis',
    10: 'katz',
    11: 'iciqsf',
    12: 'ghq12',
    13: 'phq9',
    14: 'sociodemographic',
    15: 'social_determinants',
    16: 'specialty_consultation_attendance',
    17: 'perceived_attendance_barriers',
    18: 'moca_basic',
    19: 'moca_blind',
  };

  List<InvestigationModel> _investigations = [];

  List<InvestigationModel> get investigations => List.unmodifiable(_investigations);

  InvestigationModel? byId(int id) {
    for (final investigation in _investigations) {
      if (investigation.id == id) return investigation;
    }
    return null;
  }

  Future<void> loadInvestigations() async {
    try {
      final supabase = SupabaseConfig.client;
      final data = await supabase
          .from('investigations')
          .select()
          .order('created_at', ascending: false);

      final investigations = <InvestigationModel>[];
      for (final raw in List<Map<String, dynamic>>.from(data)) {
        final investigationId = raw['id'] as int;
        final surveyTypeIds = await _loadSurveyTypeIds(investigationId);
        final participantIds = await _loadParticipantIds(investigationId);
        final consentCheckboxes = await _loadConsentCheckboxes(investigationId);

        investigations.add(
          InvestigationModel.fromJson(
            raw,
            surveyTypeIds: surveyTypeIds,
            participantIds: participantIds,
            consentCheckboxes: consentCheckboxes,
          ),
        );
      }

      _investigations = investigations;
      await _saveToHive(_investigations);
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error al cargar investigaciones desde servidor, usando cache local', e);
      _investigations = await _loadFromHive();
      notifyListeners();
    }
  }

  Future<InvestigationModel?> createInvestigation({
    required String investigationName,
    required String formConsent,
    required List<int> surveyTypeIds,
    List<String> consentCheckboxes = const [],
  }) async {
    try {
      final supabase = SupabaseConfig.client;

      final inserted = await supabase
          .from('investigations')
          .insert({
            'investigation_name': investigationName,
            'form_consent': formConsent,
          })
          .select()
          .single();

      final investigationId = inserted['id'] as int;
      await _saveSurveyTypeRelations(investigationId, surveyTypeIds);
      await _saveConsentCheckboxes(investigationId, consentCheckboxes);

      final created = InvestigationModel.fromJson(
        inserted,
        surveyTypeIds: surveyTypeIds,
        consentCheckboxes: consentCheckboxes,
      );

      _investigations = [created, ..._investigations];
      await _saveToHive(_investigations);
      notifyListeners();
      return created;
    } catch (e) {
      AppLogger.error('Error al crear investigacion', e);
      return null;
    }
  }

  Future<InvestigationModel?> updateInvestigation({
    required int investigationId,
    required String investigationName,
    required String formConsent,
    required List<int> surveyTypeIds,
    List<String> consentCheckboxes = const [],
  }) async {
    try {
      final supabase = SupabaseConfig.client;

      final updatedRaw = await supabase
          .from('investigations')
          .update({
            'investigation_name': investigationName,
            'form_consent': formConsent,
          })
          .eq('id', investigationId)
          .select()
          .single();

      await _replaceSurveyTypeRelations(investigationId, surveyTypeIds);
      await _replaceConsentCheckboxes(investigationId, consentCheckboxes);

      final current = byId(investigationId);
      final updated = InvestigationModel.fromJson(
        updatedRaw,
        surveyTypeIds: surveyTypeIds,
        participantIds: current?.participantIds ?? const <int>{},
        consentCheckboxes: consentCheckboxes,
      );

      _investigations = _investigations
          .map((item) => item.id == investigationId ? updated : item)
          .toList();
      await _saveToHive(_investigations);
      notifyListeners();
      return updated;
    } catch (e) {
      AppLogger.error('Error al actualizar investigacion', e);
      return null;
    }
  }

  Future<void> linkParticipant({
    required int investigationId,
    required int patientId,
    String? email,
    String? phone1,
    String? phone2,
  }) async {
    try {
      final supabase = SupabaseConfig.client;
      await supabase.from('investigation_participants').upsert({
        'investigation_id': investigationId,
        'patient_id': patientId,
        if (email != null) 'email': email,
        if (phone1 != null) 'phone1': phone1,
        if (phone2 != null && phone2.trim().isNotEmpty) 'phone2': phone2,
      });

      final current = byId(investigationId);
      if (current != null && !current.participantIds.contains(patientId)) {
        final updated = current.copyWith(
          participantIds: {...current.participantIds, patientId},
        );
        _investigations = _investigations
            .map((i) => i.id == current.id ? updated : i)
            .toList();
        await _saveToHive(_investigations);
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('No se pudo vincular participante a investigacion', e);
    }
  }

  Future<void> unlinkParticipant({
    required int investigationId,
    required int patientId,
  }) async {
    try {
      final supabase = SupabaseConfig.client;
      await supabase
          .from('investigation_participants')
          .delete()
          .eq('investigation_id', investigationId)
          .eq('patient_id', patientId);

      final current = byId(investigationId);
      if (current != null && current.participantIds.contains(patientId)) {
        final updated = current.copyWith(
          participantIds: current.participantIds.difference({patientId}),
        );
        _investigations = _investigations
            .map((i) => i.id == current.id ? updated : i)
            .toList();
        await _saveToHive(_investigations);
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('No se pudo desvincular participante de investigacion', e);
    }
  }

  Future<void> _saveToHive(List<InvestigationModel> investigations) async {
    try {
      final box = await Hive.openBox<InvestigationModel>('investigations');
      await box.clear();
      await box.addAll(investigations);
    } catch (e) {
      AppLogger.error('Error al guardar investigaciones en cache local', e);
    }
  }

  Future<List<InvestigationModel>> _loadFromHive() async {
    try {
      Box<InvestigationModel> box;
      try {
        box = await Hive.openBox<InvestigationModel>('investigations');
      } catch (e) {
        await Hive.deleteBoxFromDisk('investigations');
        box = await Hive.openBox<InvestigationModel>('investigations');
      }
      return box.values.toList();
    } catch (e) {
      AppLogger.error('Error al leer cache local de investigaciones', e);
      return [];
    }
  }

  Future<List<int>> _loadSurveyTypeIds(int investigationId) async {
    try {
      final supabase = SupabaseConfig.client;
      final rows = await supabase
          .from('investigation_survey_types')
          .select('survey_type_id')
          .eq('investigation_id', investigationId);

      final ids = List<Map<String, dynamic>>.from(rows)
          .map((e) => e['survey_type_id'])
          .whereType<int>()
          .toList();

      if (ids.isNotEmpty) return ids;
    } catch (_) {}

    return const <int>[];
  }

  Future<Set<int>> _loadParticipantIds(int investigationId) async {
    try {
      final supabase = SupabaseConfig.client;
      final rows = await supabase
          .from('investigation_participants')
          .select('patient_id')
          .eq('investigation_id', investigationId);

      return List<Map<String, dynamic>>.from(rows)
          .map((e) => e['patient_id'])
          .whereType<int>()
          .toSet();
    } catch (_) {
      return <int>{};
    }
  }

  Future<void> _saveSurveyTypeRelations(int investigationId, List<int> surveyTypeIds) async {
    if (surveyTypeIds.isEmpty) return;

    try {
      final supabase = SupabaseConfig.client;
      final rows = surveyTypeIds
          .map((id) => {
                'investigation_id': investigationId,
                'survey_type_id': id,
              })
          .toList();
      await supabase.from('investigation_survey_types').insert(rows);
    } catch (_) {}
  }

  Future<void> _replaceSurveyTypeRelations(int investigationId, List<int> surveyTypeIds) async {
    try {
      final supabase = SupabaseConfig.client;
      await supabase
          .from('investigation_survey_types')
          .delete()
          .eq('investigation_id', investigationId);
      await _saveSurveyTypeRelations(investigationId, surveyTypeIds);
    } catch (_) {}
  }

  Future<List<String>> _loadConsentCheckboxes(int investigationId) async {
    try {
      final supabase = SupabaseConfig.client;
      final rows = await supabase
          .from('investigation_consent_checkboxes')
          .select('label')
          .eq('investigation_id', investigationId)
          .order('sort_order', ascending: true);
      return List<Map<String, dynamic>>.from(rows)
          .map((e) => e['label'] as String)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _saveConsentCheckboxes(int investigationId, List<String> labels) async {
    if (labels.isEmpty) return;
    try {
      final supabase = SupabaseConfig.client;
      final rows = labels.asMap().entries.map((e) => {
        'investigation_id': investigationId,
        'label': e.value,
        'sort_order': e.key,
      }).toList();
      await supabase.from('investigation_consent_checkboxes').insert(rows);
    } catch (_) {}
  }

  Future<void> _replaceConsentCheckboxes(int investigationId, List<String> labels) async {
    try {
      final supabase = SupabaseConfig.client;
      await supabase
          .from('investigation_consent_checkboxes')
          .delete()
          .eq('investigation_id', investigationId);
      await _saveConsentCheckboxes(investigationId, labels);
    } catch (_) {}
  }
}
