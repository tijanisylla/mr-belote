import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/floating_particles.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F1419), // Darker background
        ),
        child: Stack(
          children: [
            // Floating card suits background
            _buildCardSuitsBackground(),
            
            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        
                        // Animated Logo with Rotating Gold Border
                        _buildAnimatedLogo(size)
                            .animate()
                            .scale(
                              duration: 800.ms,
                              curve: Curves.elasticOut,
                            )
                            .fadeIn(duration: 600.ms),
                        
                        const SizedBox(height: 40),
                        
                        // Title
                        Text(
                          'MAURITANIAN',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: 2,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 800.ms)
                            .slideY(begin: -0.2, end: 0, duration: 800.ms),
                        
                        Text(
                          'BELOTE',
                          style: GoogleFonts.poppins(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldPrimary,
                            letterSpacing: 3,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 600.ms, duration: 800.ms)
                            .slideY(begin: -0.2, end: 0, duration: 800.ms),
                        
                        const SizedBox(height: 12),
                        
                        // Tagline
                        Text(
                          'Classic Card Game • Authentic Experience',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 800.ms, duration: 800.ms),
                        
                        Text(
                          'by Tijani Sylla',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.goldPrimary,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 1000.ms, duration: 800.ms),
                        
                        const SizedBox(height: 60),
                        
                        // Features List
                        _buildFeaturesList()
                            .animate()
                            .fadeIn(delay: 1200.ms, duration: 1000.ms)
                            .slideY(begin: 0.3, end: 0, duration: 1000.ms),
                        
                        const SizedBox(height: 60),
                        
                        // GET STARTED Button
                        _buildGetStartedButton()
                            .animate()
                            .fadeIn(delay: 1600.ms, duration: 600.ms)
                            .slideY(begin: 0.3, end: 0, duration: 600.ms),
                        
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
                            .fadeIn(delay: 1800.ms, duration: 600.ms),
                        
                        const SizedBox(height: 20),
                        
                        // Copyright
                        Text(
                          '© 2024 Mauritanian Belote. All rights reserved.',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                          ),
                          textAlign: TextAlign.center,
                        )
                            .animate()
                            .fadeIn(delay: 2000.ms, duration: 600.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSuitsBackground() {
    final suits = ['♠', '♥', '♦', '♣'];
    final colors = [
      AppColors.textPrimary,
      AppColors.cardRed,
      AppColors.cardRed,
      AppColors.textPrimary,
    ];
    
    return Stack(
      children: List.generate(20, (index) {
        final random = math.Random(index);
        return Positioned(
          left: random.nextDouble() * MediaQuery.of(context).size.width,
          top: random.nextDouble() * MediaQuery.of(context).size.height,
          child: Transform.rotate(
            angle: random.nextDouble() * 2 * math.pi,
            child: Opacity(
              opacity: 0.1,
              child: Text(
                suits[index % 4],
                style: TextStyle(
                  fontSize: 40 + random.nextDouble() * 40,
                  color: colors[index % 4],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAnimatedLogo(Size size) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.goldPrimary,
                AppColors.goldSecondary,
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldPrimary.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Rotating border
              Positioned.fill(
                child: CustomPaint(
                  painter: RotatingBorderPainter(
                    progress: _rotationController.value,
                  ),
                ),
              ),
              // Logo
              Padding(
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/Mauritanian_Belote_Logo2.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.cardBackground,
                        child: Icon(
                          Icons.casino,
                          size: 80,
                          color: AppColors.goldPrimary,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      (icon: Icons.people, text: 'Play with Friends & Bots'),
      (icon: Icons.emoji_events, text: 'Daily Tournaments & Prizes'),
      (icon: Icons.flash_on, text: 'Real-Time Multiplayer'),
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accentLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  feature.icon,
                  color: AppColors.accentLight,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                feature.text,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGetStartedButton() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final shimmerValue = _shimmerController.value;
        return Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                AppColors.goldPrimary,
                AppColors.goldSecondary,
                AppColors.goldPrimary,
              ],
              stops: [
                (shimmerValue - 0.3).clamp(0.0, 1.0),
                shimmerValue.clamp(0.0, 1.0),
                (shimmerValue + 0.3).clamp(0.0, 1.0),
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                context.go('/login');
              },
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: Text(
                  'GET STARTED',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.background,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class RotatingBorderPainter extends CustomPainter {
  final double progress;

  RotatingBorderPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.goldPrimary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path = Path();
    final angle = progress * 2 * math.pi;
    
    // Draw rotating border segments
    for (int i = 0; i < 4; i++) {
      final startAngle = angle + (i * math.pi / 2);
      final sweepAngle = math.pi / 4;
      
      path.addArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        startAngle,
        sweepAngle,
      );
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(RotatingBorderPainter oldDelegate) => true;
}

