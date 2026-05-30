import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/auth_layout.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() => _isLoading = false);
          // Redirect onboarding flow directly onto Role Selection screen
          context.go('/role-selection');
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
                Icons.person_add_rounded,
                size: 70,
                color: Colors.white,
              ),
              AppSpacing.vMD,
              Text(
                AppStrings.signupTitle,
                style: AppTextStyles.h1(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Signup Card
              Card(
                elevation: 8,
                color: isDark ? AppColors.cardDark.withOpacity(0.9) : Colors.white.withOpacity(0.92),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Create Account',
                        style: AppTextStyles.h3(
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                      AppSpacing.vSM,
                      Text(
                        'Create profile to begin.',
                        style: AppTextStyles.body(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Input Forms
                      CustomTextField(
                        controller: _nameController,
                        labelText: 'Full Name',
                        hintText: 'John Doe',
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (val) => AppValidators.validateRequired(val, 'Full Name'),
                      ),
                      AppSpacing.vMD,
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email Address',
                        hintText: 'name@example.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: AppValidators.validateEmail,
                      ),
                      AppSpacing.vMD,
                      CustomTextField(
                        controller: _phoneController,
                        labelText: 'Phone Number',
                        hintText: '+1234567890',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                        validator: AppValidators.validatePhone,
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
                      const SizedBox(height: 32),

                      PrimaryButton(
                        text: 'Register',
                        isLoading: _isLoading,
                        onPressed: _handleSignup,
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.vXL,

              // Link to Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(color: Colors.white70),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: const Text(
                      'Sign In',
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
