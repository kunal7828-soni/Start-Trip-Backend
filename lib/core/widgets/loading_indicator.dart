import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../constants/app_colors.dart';

/// Uniform premium spinner layout for network queries and page transits.
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final bool isFullScreen;

  const LoadingIndicator({
    super.key,
    this.size = 50.0,
    this.color,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? AppColors.primary;

    final spinner = Center(
      child: SpinKitDoubleBounce(
        color: themeColor,
        size: size,
      ),
    );

    if (isFullScreen) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        color: (isDark ? AppColors.bgDark : AppColors.bgLight).withOpacity(0.7),
        width: double.infinity,
        height: double.infinity,
        child: spinner,
      );
    }

    return spinner;
  }
}
