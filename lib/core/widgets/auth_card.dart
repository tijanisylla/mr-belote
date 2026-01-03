import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'glass_card.dart';

/// Premium glassmorphism card container for auth screens
class AuthCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const AuthCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: padding ?? EdgeInsets.all(AppSpacing.xl),
      opacity: 0.25,
      blurIntensity: 15.0,
      borderColor: AppColors.accentLight,
      borderWidth: 1.5,
      child: child,
    );
  }
}


