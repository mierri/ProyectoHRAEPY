import 'package:flutter_test/flutter_test.dart';

import 'package:ssapp/main.dart';

void main() {
  testWidgets('MyApp renders dashboard shell', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Sistema de Evaluación'), findsOneWidget);
    expect(find.text('Acciones rápidas'), findsOneWidget);
  });
}
