import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ssapp/components/app_header.dart';
import 'package:ssapp/components/login_form.dart';
import 'package:ssapp/provider/auth_service.dart';
import 'package:ssapp/utils/theme.dart';
import 'package:ssapp/utils/widgets/info_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = context.read<AuthService>();
    final success = await authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go('/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales incorrectas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.paddingLg,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppHeader(
                  icon: Icons.psychology_rounded,
                  title: 'MindScale',
                  subtitle: 'Departamento de Psicología HRAEPY',
                ),
                SizedBox(height: AppSpacing.xxl),
                LoginForm(
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  onSubmit: _handleLogin,
                  isLoading: _isLoading,
                ),
                SizedBox(height: AppSpacing.lg),
                const InfoCard(
                  title: 'Credenciales de prueba:',
                  items: [
                    'Admin: admin@hraepy.com / admin123',
                    'Estudiante: maria@hraepy.com / student123',
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
