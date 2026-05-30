import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/auth_layout.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../providers/state_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Simulate credential delay and perform role verification
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() => _isLoading = false);
          
          // Coordinate role-based layouts
          final String email = _emailController.text.trim().toLowerCase();
          if (email.contains('worker')) {
            context.go('/worker-dashboard');
          } else {
            context.go('/home');
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: AuthLayout(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.lock_person_rounded,
                size: 70,
                color: Colors.white,
              ),
              AppSpacing.vMD,
              Text(
                AppStrings.loginTitle,
                style: AppTextStyles.h1(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Glassmorphic Input Card Container
              Card(
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.12),
                color: isDark ? AppColors.cardDark.withOpacity(0.9) : Colors.white.withOpacity(0.92),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Sign In',
                        style: AppTextStyles.h3(
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                      AppSpacing.vSM,
                      Text(
                        'Enter credentials. Standard emails redirect to traveler dashboard. Emails containing "worker" route to workforce portal.',
                        style: AppTextStyles.body(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Username & Password fields
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email Address',
                        hintText: 'traveler@email.com or worker@email.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: AppValidators.validateEmail,
                      ),
                      AppSpacing.vMD,
                      CustomTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        hintText: '••••••••',
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        validator: AppValidators.validatePassword,
                      ),
                      
                      // Forgot password tag link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.go('/forgot-password'),
                          child: Text(
                            'Forgot Password?',
                            style: AppTextStyles.caption(color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sign In Button
                      PrimaryButton(
                        text: 'Sign In',
                        isLoading: _isLoading,
                        onPressed: _handleLogin,
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.vXL,

              // Registration Entry
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.white70),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/signup'),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
