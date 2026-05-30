import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../constants/app_colors.dart';

/// Reusable material button incorporating loading animations and custom styling options.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Gradient? gradient;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: gradient != null ? Colors.transparent : (backgroundColor ?? AppColors.primary),
      foregroundColor: textColor ?? Colors.white,
      shadowColor: Colors.transparent,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    Widget buttonContent = isLoading
        ? const Center(
            child: SpinKitRing(
              color: Colors.white,
              size: 24,
              lineWidth: 2.5,
            ),
          )
        : Text(
            text,
            style: theme.textTheme.titleLarge?.copyWith(
              color: textColor ?? Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          );

    if (gradient != null && !isLoading) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: onPressed == null ? null : gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: onPressed == null
              ? []
              : [
                  BoxShadow(
                    color: (gradient!.colors.first).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonContent,
        ),
      );
    }

    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: buttonContent,
      ),
    );
  }
}
