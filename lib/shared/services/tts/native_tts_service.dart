import 'dart:io' show Platform;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ssapp/core/logger/app_logger.dart';

/// Servicio TTS que usa el motor nativo del dispositivo via [flutter_tts].
class NativeTtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    try {
      final langs = await _tts.getLanguages as List<dynamic>?;

      // Agregamos variantes con guión bajo porque algunos dispositivos Android las usan así
      const preferred = ['es-MX', 'es_MX'];

      String? chosenLang;
      if (langs != null) {
        final normalizedLangs = langs.map((e) => e.toString().toLowerCase()).toList();

        for (final lang in preferred) {
          final searchLang = lang.toLowerCase();
          // Buscamos si la lista contiene la variante con guión normal o guión bajo
          final index = normalizedLangs.indexWhere((l) =>
          l == searchLang || l == searchLang.replaceAll('-', '_') || l == searchLang.replaceAll('_', '-')
          );

          if (index != -1) {
            chosenLang = langs[index].toString();
            break;
          }
        }
      }

      await _tts.setLanguage(chosenLang ?? 'es-MX');

      // Intentar seleccionar voz femenina estricta
      await _selectFemaleVoice();

      // FIX DE VELOCIDAD: 1.0 es normal en Android, 0.5 es normal en iOS.
      final speechRate = Platform.isAndroid ? 0.45 : 0.45;
      await _tts.setSpeechRate(speechRate);

      await _tts.setPitch(1.1); // Un poco más agudo para acentuar el tono femenino
      await _tts.setVolume(1.0);

      _initialized = true;
      AppLogger.info('NativeTtsService inicializado con idioma: ${chosenLang ?? "es-MX"}');
    } catch (e, st) {
      AppLogger.error('NativeTtsService: error al inicializar', e, st);
      _initialized = true;
    }
  }

  Future<void> _selectFemaleVoice() async {
    try {
      final voices = await _tts.getVoices as List<dynamic>?;
      if (voices == null || voices.isEmpty) return;

      final voiceList = voices
          .whereType<Map<dynamic, dynamic>>()
          .map((v) => Map<String, String>.from(
        v.map((k, val) => MapEntry(k.toString(), val.toString())),
      ))
          .toList();

      Map<String, String>? best;

      // 🎯 NUEVO ENFOQUE: Buscar directamente por los IDs internos de Android.
      // Puedes cambiar el orden de esta lista si la primera no es la "Voz 2" que te gustó.
      const targetVoices = [
        'es-us-x-esc-network',
        'es-us-x-sfb-network', // Suele ser una voz femenina muy natural (con internet)
        'es-us-x-esf-network', // Variante femenina D
        'es-us-x-sfb-local',   // Las mismas, pero offline
        'es-us-x-esc-local',
        'es-us-x-esd-local',
        'es-us-x-esf-local',
      ];

      for (final targetName in targetVoices) {
        // Buscamos si el teléfono tiene exactamente ese nombre de voz
        for (final voice in voiceList) {
          if (voice['name'] == targetName) {
            best = voice;
            break;
          }
        }
        if (best != null) break; // Si ya encontró una, detenemos la búsqueda
      }

      // RESPALDO: Por si instalas la app en otro cel que no tenga esas voces exactas
      if (best == null) {
        for (final voice in voiceList) {
          final locale = (voice['locale'] ?? '').toLowerCase();
          if (locale == 'es_us' || locale == 'es-us' || locale == 'es_mx' || locale == 'es-mx') {
            best = voice;
            break;
          }
        }
      }

      if (best != null) {
        await _tts.setVoice(best);
        AppLogger.info('NativeTtsService: ¡Voz elegida! → ${best['name']} (${best['locale']})');
      }
    } catch (e) {
      AppLogger.warning('NativeTtsService: no se pudo seleccionar voz', e);
    }
  }

  Future<void> speak({
    required String text,
    VoidTtsCallback? onStart,
    VoidTtsCallback? onComplete,
    StringTtsCallback? onError,
  }) async {
    await _ensureInitialized();

    _tts.setStartHandler(() => onStart?.call());
    _tts.setCompletionHandler(() => onComplete?.call());
    _tts.setErrorHandler((msg) => onError?.call(msg));

    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      onComplete?.call();
      return;
    }

    await _tts.speak(trimmed);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> dispose() async {
    await _tts.stop();
  }
}

typedef VoidTtsCallback = void Function();
typedef StringTtsCallback = void Function(String message);