import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/floating_particles.dart';
import '../../../core/widgets/glass_card.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            // Floating particles layer
            const Positioned.fill(
              child: FloatingParticles(
                numberOfParticles: 40,
                particleColor: Colors.white24,
              ),
            ),

            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo with Hero animation and entrance effect
                        Hero(
                          tag: 'app_logo',
                          child: Container(
                            width: size.width * 0.5,
                            height: size.width * 0.5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentPrimary.withOpacity(0.3),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/Mauritanian_Belote_Logo2.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                              .animate()
                              .scale(
                                duration: 800.ms,
                                curve: Curves.elasticOut,
                              )
                              .fadeIn(duration: 600.ms),
                        ),

                        const SizedBox(height: 40),

                        // App Name
                        Text(
                          'Belote Royale',
                          style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: 1.2,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 800.ms)
                            .slideY(begin: 0.3, end: 0, duration: 800.ms),

                        const SizedBox(height: 16),

                        // Animated tagline with sparkle effect
                        AnimatedBuilder(
                          animation: _sparkleController,
                          builder: (context, child) {
                            return ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  stops: [
                                    _sparkleController.value - 0.3,
                                    _sparkleController.value,
                                    _sparkleController.value + 0.3,
                                  ].map((e) => e.clamp(0.0, 1.0)).toList(),
                                  colors: const [
                                    AppColors.goldSecondary,
                                    AppColors.goldPrimary,
                                    AppColors.goldSecondary,
                                  ],
                                ).createShader(bounds);
                              },
                              child: Text(
                                '✨ Let\'s Play! ✨',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        )
                            .animate()
                            .fadeIn(delay: 800.ms, duration: 1000.ms)
                            .slideY(begin: 0.3, end: 0, duration: 800.ms),

                        const SizedBox(height: 60),

                        // Login Button
                        _AnimatedButton(
                          onPressed: () => context.go('/login'),
                          text: 'Login',
                          isPrimary: true,
                          delay: 1200,
                        ),

                        const SizedBox(height: 20),

                        // Sign Up Button
                        _AnimatedButton(
                          onPressed: () => context.go('/signup'),
                          text: 'Sign Up',
                          isPrimary: false,
                          delay: 1400,
                        ),

                        const SizedBox(height: 40),

                        // Decorative element
                        _buildCardIcons()
                            .animate()
                            .fadeIn(delay: 1600.ms, duration: 1000.ms)
                            .scale(delay: 1600.ms, duration: 800.ms),
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

  Widget _buildCardIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CardIcon(suit: '♠', color: AppColors.textPrimary),
        const SizedBox(width: 20),
        _CardIcon(suit: '♥', color: AppColors.cardRed),
        const SizedBox(width: 20),
        _CardIcon(suit: '♦', color: AppColors.cardRed),
        const SizedBox(width: 20),
        _CardIcon(suit: '♣', color: AppColors.textPrimary),
      ],
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isPrimary;
  final int delay;

  const _AnimatedButton({
    required this.onPressed,
    required this.text,
    required this.isPrimary,
    required this.delay,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
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

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(16),
          opacity: widget.isPrimary ? 0.3 : 0.15,
          borderColor: widget.isPrimary ? AppColors.accentPrimary : AppColors.accentLight,
          borderWidth: widget.isPrimary ? 1.5 : 2.0,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: widget.isPrimary
                ? BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.accentPrimary,
                        AppColors.accentLight,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  )
                : null,
            child: Center(
              child: Text(
                widget.text,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: widget.delay.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0, duration: 600.ms);
  }
}

class _CardIcon extends StatefulWidget {
  final String suit;
  final Color color;

  const _CardIcon({
    required this.suit,
    required this.color,
  });

  @override
  State<_CardIcon> createState() => _CardIconState();
}

class _CardIconState extends State<_CardIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -10 * _controller.value),
          child: GlassCard(
            width: 50,
            height: 50,
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(8),
            opacity: 0.2,
            borderColor: widget.color,
            borderWidth: 1.5,
            child: Center(
              child: Text(
                widget.suit,
                style: TextStyle(
                  fontSize: 28,
                  color: widget.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

