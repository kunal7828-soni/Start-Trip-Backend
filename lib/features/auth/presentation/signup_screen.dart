import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

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
  
  // Role System Selection
  String _selectedRole = 'user'; // 'user' or 'worker'

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
      // Execute Repository Call
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registering as $_selectedRole...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkGradient : AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 70,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.signupTitle,
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Signup container
                    Card(
                      elevation: 8,
                      color: isDark
                          ? AppColors.cardDark.withOpacity(0.85)
                          : Colors.white.withOpacity(0.92),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Register Account',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppStrings.signupSubtitle,
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 24),

                            // Inputs
                            CustomTextField(
                              controller: _nameController,
                              labelText: 'Full Name',
                              hintText: 'John Doe',
                              prefixIcon: const Icon(Icons.person_outline),
                              validator: (val) => AppValidators.validateRequired(val, 'Full Name'),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _emailController,
                              labelText: 'Email Address',
                              hintText: 'name@example.com',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email_outlined),
                              validator: AppValidators.validateEmail,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _phoneController,
                              labelText: 'Phone Number',
                              hintText: '+1234567890',
                              keyboardType: TextInputType.phone,
                              prefixIcon: const Icon(Icons.phone_outlined),
                              validator: AppValidators.validatePhone,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _passwordController,
                              labelText: 'Password',
                              hintText: '••••••••',
                              obscureText: true,
                              prefixIcon: const Icon(Icons.lock_outlined),
                              validator: AppValidators.validatePassword,
                            ),
                            const SizedBox(height: 20),

                            // Dynamic Role Selector Section
                            Text(
                              'I am registering as:',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Text(AppStrings.roleUser),
                                    selected: _selectedRole == 'user',
                                    selectedColor: AppColors.primary.withOpacity(0.2),
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() => _selectedRole = 'user');
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Text('Travel Partner'),
                                    selected: _selectedRole == 'worker',
                                    selectedColor: AppColors.primary.withOpacity(0.2),
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() => _selectedRole = 'worker');
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Action button
                            CustomButton(
                              text: 'Create Account',
                              onPressed: _handleSignup,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
