import 'package:flutter/material.dart';
import 'package:ssapp/utils/theme.dart';
import 'package:ssapp/utils/widgets/custom_text_field.dart';
import 'package:ssapp/utils/widgets/password_text_field.dart';
import 'package:ssapp/utils/widgets/loading_button.dart';

/// Reusable login form component
class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final bool isLoading;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: emailController,
            labelText: 'Correo electrónico',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu correo';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.md),
          PasswordTextField(
            controller: passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu contraseña';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.xl),
          LoadingButton(
            onPressed: onSubmit,
            text: 'Iniciar sesión',
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
