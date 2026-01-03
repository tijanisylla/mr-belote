import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

enum SocialLoginType {
  google,
  facebook,
  apple,
}

/// Social login button widget with proper styling
class SocialLoginButton extends StatefulWidget {
  final SocialLoginType type;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.type,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<SocialLoginButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getButtonText() {
    switch (widget.type) {
      case SocialLoginType.google:
        return 'Continue with Google';
      case SocialLoginType.facebook:
        return 'Continue with Facebook';
      case SocialLoginType.apple:
        return 'Continue with Apple';
    }
  }

  Color _getBackgroundColor() {
    if (widget.isLoading || widget.onPressed == null) {
      return AppColors.textTertiary;
    }

    switch (widget.type) {
      case SocialLoginType.google:
        return Colors.white;
      case SocialLoginType.facebook:
        return const Color(0xFF1877F2);
      case SocialLoginType.apple:
        return Colors.black;
    }
  }

  Color _getTextColor() {
    switch (widget.type) {
      case SocialLoginType.google:
        return Colors.black87;
      case SocialLoginType.facebook:
      case SocialLoginType.apple:
        return Colors.white;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case SocialLoginType.google:
        return Icons.g_mobiledata;
      case SocialLoginType.facebook:
        return Icons.facebook;
      case SocialLoginType.apple:
        return Icons.apple;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide Apple button on non-iOS platforms
    final bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    if (widget.type == SocialLoginType.apple && !isIOS) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null && !widget.isLoading) {
          setState(() => _isPressed = true);
          _controller.forward();
        }
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        if (widget.onPressed != null && !widget.isLoading) {
          widget.onPressed!();
        }
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = _isPressed ? 0.97 : 1.0;
          return Transform.scale(
            scale: scale,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.m,
              ),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getTextColor(),
                        ),
                      ),
                    )
                  else ...[
                    Icon(
                      _getIcon(),
                      color: _getTextColor(),
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Text(
                      _getButtonText(),
                      style: AppTypography.body(context).copyWith(
                        color: _getTextColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

