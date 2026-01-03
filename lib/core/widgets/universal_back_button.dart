import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// Universal back button with smooth animations
class UniversalBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool showLabel;

  const UniversalBackButton({
    super.key,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    
    if (!canPop && onPressed == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: backgroundColor ?? AppColors.cardBackground.withValues(alpha: 0.3),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed ?? () => context.pop(),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: iconColor ?? AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: -0.2, end: 0, duration: 300.ms);
  }
}






