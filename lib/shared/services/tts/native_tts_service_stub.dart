class NativeTtsService {
  Future<void> speak({
    required String text,
    VoidTtsCallback? onStart,
    VoidTtsCallback? onComplete,
    StringTtsCallback? onError,
  }) async {
    onComplete?.call();
  }

  Future<void> stop() async {}

  Future<void> dispose() async {}
}

typedef VoidTtsCallback = void Function();
typedef StringTtsCallback = void Function(String message);
