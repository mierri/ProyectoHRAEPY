import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    await dotenv.load(fileName: ".env");

    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (url.isEmpty || anonKey.isEmpty) {
      throw StateError(
        'Faltan SUPABASE_URL y/o SUPABASE_ANON_KEY en el archivo .env',
      );
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
    _initialized = true;
  }

  static SupabaseClient get client => Supabase.instance.client;
}
