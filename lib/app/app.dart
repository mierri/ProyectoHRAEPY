import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/app/di.dart';
import 'package:ssapp/app/router.dart';
import 'package:ssapp/features/auth/provider/auth_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthService _authService;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _router = createAppRouter(_authService);
  }

  @override
  void dispose() {
    _router.dispose();
    _authService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: _authService),
        ...AppDi.providers(),
      ],
      child: ShadcnApp.router(
        title: 'Sistema de Evaluacion',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}
