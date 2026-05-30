import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/auth_layout.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';

/// Onboarding welcome page routing entries.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: AuthLayout(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.travel_explore_rounded,
              size: 80,
              color: Colors.white,
            ),
            AppSpacing.vMD,
            Text(
              'Begin Your Journey',
              style: AppTextStyles.h1(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSM,
            Text(
              'Your all-in-one assistant for smart rail, bus bookings, and certified local guides.',
              style: AppTextStyles.body(color: Colors.white.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 56),

            // Authentication options buttons
            PrimaryButton(
              text: 'Sign In',
              onPressed: () => context.go('/login'),
            ),
            AppSpacing.vMD,
            SecondaryButton(
              text: 'Register Account',
              onPressed: () => context.go('/signup'),
            ),
            const SizedBox(height: 40),

            Text(
              'By signing in you agree to our Terms and Conditions',
              style: AppTextStyles.caption(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
