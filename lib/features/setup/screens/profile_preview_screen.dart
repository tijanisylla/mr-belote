import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/floating_particles.dart';
import '../../../core/widgets/glass_card.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_spacing.dart';

class ProfilePreviewScreen extends StatelessWidget {
  final Map<String, dynamic> profileData;

  const ProfilePreviewScreen({
    super.key,
    required this.profileData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            const Positioned.fill(
              child: FloatingParticles(
                numberOfParticles: 30,
                particleColor: Colors.white24,
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Avatar
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.goldPrimary,
                              AppColors.goldSecondary,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.goldPrimary.withValues(alpha: 0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                child: ClipOval(
                  child: profileData['avatar'] != null
                      ? ((profileData['avatar'] as String).endsWith('.svg')
                          ? SvgPicture.asset(
                              profileData['avatar'] as String,
                              fit: BoxFit.cover,
                              placeholderBuilder: (context) => Icon(
                                Icons.person,
                                size: 80,
                                color: AppColors.textPrimary,
                              ),
                            )
                          : Image.asset(
                              profileData['avatar'] as String,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 80,
                                  color: AppColors.textPrimary,
                                );
                              },
                            ))
                      : Icon(
                          Icons.person,
                          size: 80,
                          color: AppColors.textPrimary,
                        ),
                ),
                      )
                          .animate()
                          .scale(
                            duration: 800.ms,
                            curve: Curves.elasticOut,
                          )
                          .fadeIn(duration: 600.ms),
                      
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Username
                      Text(
                        profileData['username'] as String? ?? 'Player',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldPrimary,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 600.ms)
                          .slideY(begin: 0.2, end: 0, duration: 600.ms),
                      
                      const SizedBox(height: AppSpacing.l),
                      
                      // Profile info
                      GlassCard(
                        padding: EdgeInsets.all(AppSpacing.l),
                        opacity: 0.3,
                        blurIntensity: 15.0,
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.person,
                              'Gender',
                              (profileData['gender'] as String?)?.toUpperCase() ?? '',
                            ),
                            const SizedBox(height: AppSpacing.m),
                            _buildInfoRow(
                              Icons.cake,
                              'Age',
                              '${profileData['age']} years old',
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 600.ms, duration: 600.ms)
                          .slideY(begin: 0.2, end: 0, duration: 600.ms),
                      
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Enter button
                      GestureDetector(
                        onTap: () {
                          // Save profile and navigate to home
                          context.go('/home');
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.l),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.goldPrimary,
                                AppColors.goldSecondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.goldPrimary.withValues(alpha: 0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Enter Game Lobby',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.background,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0, duration: 600.ms),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.goldPrimary, size: 24),
        const SizedBox(width: AppSpacing.m),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

