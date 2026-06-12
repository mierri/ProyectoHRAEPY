import 'dart:async';

import 'package:hive/hive.dart';
import 'package:ssapp/core/logger/app_logger.dart';
import 'package:ssapp/core/network/network_executor.dart';
import 'package:ssapp/core/supabase/supabase_config.dart';
import 'package:ssapp/features/survey_builder/data/custom_survey_model.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_definition.dart';
import 'package:ssapp/shared/services/syncable.dart';

/// Se lanza al intentar eliminar una encuesta personalizada que ya tiene
/// encuestas respondidas asociadas (violaría `surveys_custom_survey_id_fkey`).
class CustomSurveyInUseException implements Exception {}

/// Persiste y sincroniza encuestas personalizadas (creadas por la doctora)
/// entre Hive (offline-first) y Supabase (tabla `custom_surveys`).
class CustomSurveyRepository implements ISyncable {
  Future<Box<CustomSurveyModel>> _openBox() async {
    try {
      return await Hive.openBox<CustomSurveyModel>('custom_surveys');
    } catch (e) {
      AppLogger.error('Error al abrir Hive box custom_surveys, limpiando datos antiguos', e);
      await Hive.deleteBoxFromDisk('custom_surveys');
      return await Hive.openBox<CustomSurveyModel>('custom_surveys');
    }
  }

  Future<List<CustomSurveyDefinition>> loadAll() async {
    try {
      await _downloadRemote();
    } catch (e) {
      AppLogger.error('Error al descargar encuestas personalizadas', e);
    }

    final box = await _openBox();
    return box.values.map((m) => m.definition).toList();
  }

  Future<CustomSurveyDefinition?> getById(int id) async {
    final box = await _openBox();
    final match = box.values.where((m) => m.id == id);
    if (match.isEmpty) return null;
    return match.first.definition;
  }

  Future<void> save(CustomSurveyDefinition definition) async {
    final box = await _openBox();
    final existingKey = box.keys.firstWhere(
      (key) => box.get(key)?.id == definition.id,
      orElse: () => null,
    );

    final model = CustomSurveyModel.fromDefinition(definition, synced: false);

    if (existingKey != null) {
      await box.put(existingKey, model);
    } else {
      await box.add(model);
    }

    await _syncToSupabase(model);
  }

  Future<void> delete(int id) async {
    final supabase = SupabaseConfig.client;

    try {
      final referencing = await NetworkExecutor.runWithRetry(
        () => supabase.from('surveys').select('survey_id').eq('custom_survey_id', id).limit(1),
        operationName: 'check custom survey usage',
      );
      if ((referencing as List).isNotEmpty) {
        throw CustomSurveyInUseException();
      }
    } on CustomSurveyInUseException {
      rethrow;
    } catch (e) {
      AppLogger.error('Error al verificar uso de encuesta personalizada', e);
    }

    final box = await _openBox();
    final existingKey = box.keys.firstWhere(
      (key) => box.get(key)?.id == id,
      orElse: () => null,
    );
    if (existingKey != null) {
      await box.delete(existingKey);
    }

    try {
      await NetworkExecutor.runWithRetry(
        () => supabase.from('custom_surveys').delete().eq('id', id),
        operationName: 'delete custom survey',
      );
    } catch (e) {
      AppLogger.error('Error al eliminar encuesta personalizada en Supabase', e);
    }
  }

  Future<bool> _syncToSupabase(CustomSurveyModel model) async {
    try {
      final supabase = SupabaseConfig.client;
      final definition = model.definition;
      await NetworkExecutor.runWithRetry(
        () => supabase.from('custom_surveys').upsert({
          'id': definition.id,
          'title': definition.title,
          'description': definition.description,
          'color_hex': definition.colorHex,
          'definition': definition.toJson(),
          'active': definition.active,
        }),
        operationName: 'upsert custom survey',
      );

      model.synced = true;
      await model.save();
      return true;
    } catch (e) {
      AppLogger.error('Error al sincronizar encuesta personalizada con Supabase', e);
      return false;
    }
  }

  Future<void> _downloadRemote() async {
    final supabase = SupabaseConfig.client;
    final data = await NetworkExecutor.runWithRetry(
      () => supabase.from('custom_surveys').select('*'),
      operationName: 'fetch custom surveys from supabase',
    );
    final remoteSurveys = List<Map<String, dynamic>>.from(data);

    final box = await _openBox();

    for (final row in remoteSurveys) {
      final definition = CustomSurveyDefinition.fromJson(
        row['definition'] as Map<String, dynamic>,
      );

      final existingKey = box.keys.firstWhere(
        (key) => box.get(key)?.id == definition.id,
        orElse: () => null,
      );

      if (existingKey != null) {
        final existing = box.get(existingKey)!;
        if (existing.synced) {
          existing.definition = definition;
          existing.synced = true;
          await existing.save();
        }
      } else {
        await box.add(CustomSurveyModel.fromDefinition(definition, synced: true));
      }
    }
  }

  @override
  Future<int> syncPendingToServer() async {
    final box = await _openBox();
    final pending = box.values.where((m) => !m.synced).toList();

    int syncedCount = 0;
    for (final model in pending) {
      if (await _syncToSupabase(model)) {
        syncedCount++;
      }
    }
    return syncedCount;
  }

  @override
  Future<void> downloadFromServer() async {
    try {
      await _downloadRemote();
    } catch (e) {
      AppLogger.error('Error al descargar encuestas personalizadas desde servidor', e);
    }
  }
}
