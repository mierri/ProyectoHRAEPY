import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Servicio singleton de texto a voz (TTS) para leer preguntas y textos en voz alta.
/// Usar: await TtsService.instance.speak('texto aqui');
class TtsService extends ChangeNotifier {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;
  String? _currentText;

  bool get isPlaying => _isPlaying;
  String? get currentText => _currentText;

  /// Inicializa el servicio con configuracion en espanol.
  Future<void> init() async {
    try {
      await _tts.setLanguage('es-MX');
      await _tts.setSpeechRate(0.45); // Velocidad ligeramente mas lenta para claridad clinica
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setCompletionHandler(() {
        _isPlaying = false;
        _currentText = null;
        notifyListeners();
      });

      _tts.setErrorHandler((msg) {
        _isPlaying = false;
        _currentText = null;
        notifyListeners();
        if (kDebugMode) debugPrint('[TTS] Error: $msg');
      });

      _tts.setCancelHandler(() {
        _isPlaying = false;
        _currentText = null;
        notifyListeners();
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[TTS] Init error: $e');
    }
  }

  /// Lee el [text] en voz alta.
  /// Si ya esta leyendo el mismo texto, lo pausa (toggle).
  Future<void> speak(String text) async {
    final isSameText = _isPlaying && _currentText == text;
    if (_isPlaying) {
      await stop();
      // Si era el mismo texto, solo pausamos (toggle off)
      if (isSameText) return;
    }

    _isPlaying = true;
    _currentText = text;
    notifyListeners();

    try {
      await _tts.speak(text);
    } catch (e) {
      _isPlaying = false;
      _currentText = null;
      notifyListeners();
      if (kDebugMode) debugPrint('[TTS] Speak error: $e');
    }
  }

  /// Detiene la reproduccion actual.
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    _isPlaying = false;
    _currentText = null;
    notifyListeners();
  }

  /// Devuelve true si el [text] es el que se esta reproduciendo actualmente.
  bool isReadingText(String text) => _isPlaying && _currentText == text;
}
