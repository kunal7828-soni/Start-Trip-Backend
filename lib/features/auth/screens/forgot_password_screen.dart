import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/auth_layout.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';

/// Password recovery screen.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleReset() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password reset token dispatched to inbox.')),
          );
          context.go('/login');
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
                Icons.mark_email_unread_rounded,
                size: 70,
                color: Colors.white,
              ),
              AppSpacing.vMD,
              Text(
                'Recover Account',
                style: AppTextStyles.h1(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              Card(
                elevation: 8,
                color: isDark ? AppColors.cardDark.withOpacity(0.9) : Colors.white.withOpacity(0.92),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Reset Password',
                        style: AppTextStyles.h3(
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                      AppSpacing.vSM,
                      Text(
                        'Provide your register email address and we will dispatch recovery instructions.',
                        style: AppTextStyles.body(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 24),

                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email Address',
                        hintText: 'name@example.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: AppValidators.validateEmail,
                      ),
                      const SizedBox(height: 32),

                      PrimaryButton(
                        text: 'Send Recovery Email',
                        isLoading: _isLoading,
                        onPressed: _handleReset,
                      ),
                      AppSpacing.vMD,
                      SecondaryButton(
                        text: 'Back to Sign In',
                        onPressed: () => context.go('/login'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
