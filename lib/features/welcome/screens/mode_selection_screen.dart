import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/floating_particles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/universal_back_button.dart';
import 'package:google_fonts/google_fonts.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            // Floating particles layer
            const Positioned.fill(
              child: FloatingParticles(
                numberOfParticles: 30,
                particleColor: Colors.white24,
              ),
            ),
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Back Button
                    Align(
                      alignment: Alignment.topLeft,
                      child: const UniversalBackButton(),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Title
                    Text(
                      'Choose Your Mode',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 1.2,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: -0.2, end: 0, duration: 400.ms),
                    
                    const SizedBox(height: 60),
                    
                    // PLAY FOR FREE Card
                    _PlayForFreeCard()
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .slideX(begin: -0.2, end: 0, duration: 600.ms),
                    
                    const SizedBox(height: 24),
                    
                    // PLAY FOR REAL Card
                    _PlayForRealCard()
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideX(begin: 0.2, end: 0, duration: 600.ms),
                    
                    const SizedBox(height: 40),
                    
                    // Disclaimer
                    Text(
                      '18+ only. Play responsibly.',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 400.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayForFreeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Skip login, go directly to home with free mode
        context.go('/home');
      },
      child: GlassCard(
        padding: EdgeInsets.all(24),
        opacity: 0.25,
        blurIntensity: 15.0,
        borderColor: AppColors.accentPrimary,
        borderWidth: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.card_giftcard,
                    color: AppColors.accentLight,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PLAY FOR FREE',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Practice mode',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Features
            _buildFeature('Play with virtual chips (MRU)', Icons.check),
            const SizedBox(height: 12),
            _buildFeature('Join any table instantly', Icons.check),
            const SizedBox(height: 12),
            _buildFeature('Learn Belote rules & strategies', Icons.check),
            const SizedBox(height: 12),
            _buildFeature('Play with AI bots anytime', Icons.check),
            
            const SizedBox(height: 24),
            
            // Starting Balance
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accentPrimary,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.accentLight,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Starting Balance',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '10,000 MRU',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // No auth required
            Row(
              children: [
                Icon(
                  Icons.lock_open,
                  color: AppColors.success,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'No authentication required - instant play!',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.accentLight,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayForRealCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to login for real money mode
        context.go('/login');
      },
      child: Stack(
        children: [
          GlassCard(
            padding: EdgeInsets.all(24),
            opacity: 0.3,
            blurIntensity: 15.0,
            borderColor: AppColors.goldPrimary,
            borderWidth: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.goldPrimary,
                            AppColors.goldSecondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: AppColors.background,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'PLAY FOR REAL',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              // Premium Badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.goldPrimary,
                                      AppColors.goldSecondary,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'PREMIUM',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.background,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Real money indicator',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.goldPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Features
                _buildFeature('Win real MRU prizes', Icons.check),
                const SizedBox(height: 12),
                _buildFeature('Exclusive VIP tournaments', Icons.check),
                const SizedBox(height: 12),
                _buildFeature('Compete with top players', Icons.check),
                const SizedBox(height: 12),
                _buildFeature('Secure payment & withdrawal', Icons.check),
                
                const SizedBox(height: 24),
                
                // Welcome Bonus
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.goldPrimary.withValues(alpha: 0.2),
                        AppColors.goldSecondary.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.goldPrimary,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.celebration,
                        color: AppColors.goldPrimary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Bonus',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '+50% First Deposit',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.goldPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Requires auth
                Row(
                  children: [
                    Icon(
                      Icons.lock,
                      color: AppColors.goldPrimary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Requires authentication for safety',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.goldPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Sparkles decoration
          Positioned(
            top: 10,
            right: 10,
            child: Icon(
              Icons.auto_awesome,
              color: AppColors.goldPrimary.withValues(alpha: 0.5),
              size: 20,
            )
                .animate(onPlay: (controller) => controller.repeat())
                .scale(duration: 1000.ms, begin: const Offset(1, 1), end: const Offset(1.2, 1.2))
                .then()
                .scale(duration: 1000.ms, begin: const Offset(1.2, 1.2), end: const Offset(1, 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.goldPrimary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

