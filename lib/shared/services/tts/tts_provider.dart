import 'package:flutter/foundation.dart';
import 'package:ssapp/core/logger/app_logger.dart';
import 'package:ssapp/shared/services/tts/native_tts_service.dart';

enum TtsState { idle, loading, playing, error }

/// Proveedor de TTS para la UI.
/// Orquesta [NativeTtsService] y expone el estado reactivo.
///
/// Registrar en [AppDi]:
/// ```dart
/// ChangeNotifierProvider(create: (_) => TtsProvider()),
/// ```
class TtsProvider extends ChangeNotifier {
  final NativeTtsService _service;

  TtsState _state = TtsState.idle;
  String? _errorMessage;

  /// Texto que se está reproduciendo actualmente (para resaltar en UI).
  String? _currentText;

  TtsProvider({NativeTtsService? service})
      : _service = service ?? NativeTtsService();

  TtsState get state => _state;
  bool get isLoading => _state == TtsState.loading;
  bool get isPlaying => _state == TtsState.playing;
  bool get hasError => _state == TtsState.error;
  String? get errorMessage => _errorMessage;
  String? get currentText => _currentText;

  /// Reproduce [text] como TTS.
  ///
  /// - Si ya está reproduciendo el MISMO texto → lo detiene (toggle).
  /// - Si está reproduciendo OTRO texto → lo reemplaza.
  Future<void> speak(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Toggle: detener si es el mismo texto
    if ((_state == TtsState.playing || _state == TtsState.loading) &&
        _currentText == trimmed) {
      await stop();
      return;
    }

    // Detener el audio previo si había otro
    if (_state == TtsState.playing || _state == TtsState.loading) {
      await _service.stop();
    }

    _updateState(TtsState.loading, text: trimmed);

    try {
      await _service.speak(
        text: trimmed,
        onStart: () {
          _updateState(TtsState.playing, text: trimmed);
        },
        onComplete: () {
          _updateState(TtsState.idle);
        },
        onError: (msg) {
          AppLogger.error('TtsProvider error', msg);
          _updateState(TtsState.error, error: msg);
        },
      );
    } catch (e, st) {
      AppLogger.error('TtsProvider.speak exception', e, st);
      _updateState(TtsState.error, error: e.toString());
    }
  }

  /// Detiene la reproducción actual.
  Future<void> stop() async {
    await _service.stop();
    _updateState(TtsState.idle);
  }

  void _updateState(TtsState state, {String? text, String? error}) {
    _state = state;
    if (text != null) _currentText = text;
    if (state == TtsState.idle || state == TtsState.error) {
      _currentText = null;
    }
    _errorMessage = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}