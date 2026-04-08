import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/app/di.dart';
import 'package:ssapp/app/router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppDi.providers(),
      child: ShadcnApp.router(
        title: 'Sistema de Evaluación',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        routerConfig: appRouter,
      ),
    );
  }
}
