import 'package:flutter/foundation.dart';
import 'package:ssapp/config/supabase_config.dart';
import 'package:ssapp/models/investigation_model.dart';

class InvestigationService extends ChangeNotifier {
  static const Map<int, String> surveyTypes = {
    1: 'BDI-II',
    2: 'BAI',
    3: 'WHOQOL-BREF',
    4: 'MoCA',
    5: 'SF-36',
    6: 'ASSIST V3.0',
    7: 'GDS-15',
  };

  static const Map<int, String> surveyTypeToRouteCode = {
    1: 'bdi',
    2: 'bai',
    3: 'whoqol',
    4: 'moca',
    5: 'sf36',
    6: 'assist',
    7: 'gds',
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

        investigations.add(
          InvestigationModel.fromJson(
            raw,
            surveyTypeIds: surveyTypeIds,
            participantIds: participantIds,
          ),
        );
      }

      _investigations = investigations;
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar investigaciones: $e');
    }
  }

  Future<InvestigationModel?> createInvestigation({
    required String investigationName,
    required String formConsent,
    required List<int> surveyTypeIds,
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

      final created = InvestigationModel.fromJson(
        inserted,
        surveyTypeIds: surveyTypeIds,
      );

      _investigations = [created, ..._investigations];
      notifyListeners();
      return created;
    } catch (e) {
      debugPrint('Error al crear investigación: $e');
      return null;
    }
  }

  Future<void> linkParticipant({
    required int investigationId,
    required int patientId,
  }) async {
    try {
      final supabase = SupabaseConfig.client;
      await supabase.from('investigation_participants').upsert({
        'investigation_id': investigationId,
        'patient_id': patientId,
      });

      final current = byId(investigationId);
      if (current != null && !current.participantIds.contains(patientId)) {
        final updated = current.copyWith(
          participantIds: {...current.participantIds, patientId},
        );
        _investigations = _investigations
            .map((i) => i.id == current.id ? updated : i)
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('No se pudo vincular participante a investigación: $e');
    }
  }

  Future<List<int>> _loadSurveyTypeIds(int investigationId) async {    try {
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
    } catch (_) {
      // Fallback a campo simple cuando aún no existe la tabla relacional.
    }

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
    } catch (_) {
      // Ignorar si la tabla relacional no está disponible todavía.
    }
  }
}

