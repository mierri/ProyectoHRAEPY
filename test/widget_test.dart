import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssapp/core/supabase/supabase_config.dart';

import 'package:ssapp/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await SupabaseConfig.initialize();
  });

  testWidgets('MyApp renders login when signed out', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('MindScale'), findsOneWidget);
    expect(find.text('Iniciar sesion'), findsOneWidget);
  });
}
