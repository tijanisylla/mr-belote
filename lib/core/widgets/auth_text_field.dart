import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

/// Custom text field for authentication forms
class AuthTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final VoidCallback? onSuffixTap;
  final bool enabled;

  const AuthTextField({
    super.key,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.prefixIcon,
    this.onSuffixTap,
    this.enabled = true,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _isObscured = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final bool showObscureToggle = widget.obscureText && widget.onSuffixTap == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: AppTypography.label(context).copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        FocusScope(
          child: Focus(
            onFocusChange: (focused) {
              setState(() => _isFocused = focused);
            },
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText && _isObscured,
              validator: widget.validator,
              keyboardType: widget.keyboardType,
              enabled: widget.enabled,
              style: AppTypography.body(context).copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTypography.body(context).copyWith(
                  color: AppColors.textTertiary,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _isFocused
                            ? AppColors.goldPrimary
                            : AppColors.textSecondary,
                        size: 20,
                      )
                    : null,
                suffixIcon: showObscureToggle
                    ? IconButton(
                        icon: Icon(
                          _isObscured
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _isObscured = !_isObscured);
                        },
                      )
                    : widget.onSuffixTap != null
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: widget.onSuffixTap,
                          )
                        : null,
                filled: true,
                fillColor: AppColors.cardBackground,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: AppSpacing.m,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.cardBorder,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.cardBorder,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.goldPrimary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.error,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.cardBorder.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}









