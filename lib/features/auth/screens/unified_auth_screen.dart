import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/floating_particles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/universal_back_button.dart';
import '../../../core/widgets/social_login_button.dart';
import '../../../core/widgets/auth_text_field.dart';
import '../../../core/providers/auth_provider.dart';

class UnifiedAuthScreen extends ConsumerStatefulWidget {
  final bool initialTabIsSignUp;
  
  const UnifiedAuthScreen({
    super.key,
    this.initialTabIsSignUp = false,
  });

  @override
  ConsumerState<UnifiedAuthScreen> createState() => _UnifiedAuthScreenState();
}

class _UnifiedAuthScreenState extends ConsumerState<UnifiedAuthScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialTabIsSignUp;
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    // Mock auth - replace with actual auth later
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() => _isLoading = false);
      
      // Create user if signing up, or get existing user if logging in
      if (_isSignUp) {
        // New signup - create user without setup
        ref.read(authProvider.notifier).createUserWithSetup(
          username: _usernameController.text.isNotEmpty 
              ? _usernameController.text 
              : 'Player${DateTime.now().millisecondsSinceEpoch}',
          hasCompletedSetup: false,
        );
      } else {
        // Login - create mock user (in real app, fetch from backend)
        await ref.read(authProvider.notifier).signInWithEmail(
          _emailController.text,
        );
      }
      
      // Check if user has completed setup
      final authState = ref.read(authProvider);
      if (authState.user?.hasCompletedSetup == true) {
        context.go('/home');
      } else {
        context.go('/setup');
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    await ref.read(authProvider.notifier).signInWithGoogle();
    if (mounted && ref.read(authProvider).isAuthenticated) {
      final authState = ref.read(authProvider);
      if (authState.user?.hasCompletedSetup == true) {
        context.go('/home');
      } else {
        context.go('/setup');
      }
    }
  }

  Future<void> _handleFacebookSignIn() async {
    await ref.read(authProvider.notifier).signInWithFacebook();
    if (mounted && ref.read(authProvider).isAuthenticated) {
      final authState = ref.read(authProvider);
      if (authState.user?.hasCompletedSetup == true) {
        context.go('/home');
      } else {
        context.go('/setup');
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      // Check if user has completed setup
      final authState = ref.read(authProvider);
      if (authState.user?.hasCompletedSetup == true) {
        context.go('/home');
      } else {
        context.go('/setup');
      }
    }
  }

  String? _validateUsername(String? value) {
    if (_isSignUp && (value == null || value.isEmpty)) {
      return 'Username is required';
    }
    if (_isSignUp && value != null && value.length < 2) {
      return 'Username must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = _isLoading || authState.isLoading;

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
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.l),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Back button
                        Align(
                          alignment: Alignment.topLeft,
                          child: const UniversalBackButton(),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        
                        // Logo and Title
                        Hero(
                          tag: 'app_logo',
                          child: _buildAnimatedLogo(),
                        )
                            .animate()
                            .scale(duration: 600.ms, curve: Curves.elasticOut)
                            .fadeIn(duration: 400.ms),
                        
                        const SizedBox(height: AppSpacing.m),
                        
                        // App Name
                        Text(
                          'MAURITANIAN BELOTE',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: 2,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 600.ms)
                            .slideY(begin: -0.2, end: 0, duration: 600.ms),
                        
                        const SizedBox(height: AppSpacing.s),
                        
                        // Tagline
                        Text(
                          'Premium Card Game Experience',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.goldPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 300.ms, duration: 600.ms),
                        
                        Text(
                          'by Tijani Sylla',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 600.ms),
                        
                        const SizedBox(height: AppSpacing.xl),
                        
                        // Auth Card
                        GlassCard(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          opacity: 0.25,
                          blurIntensity: 15.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Tab Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: _TabButton(
                                      text: 'LOGIN',
                                      isActive: !_isSignUp,
                                      onTap: () => setState(() => _isSignUp = false),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.s),
                                  Expanded(
                                    child: _TabButton(
                                      text: 'SIGN UP',
                                      isActive: _isSignUp,
                                      onTap: () => setState(() => _isSignUp = true),
                                    ),
                                  ),
                                ],
                              )
                                  .animate()
                                  .fadeIn(delay: 500.ms, duration: 400.ms),
                              
                              const SizedBox(height: AppSpacing.xl),
                              
                              // Social Login Buttons
                              SocialLoginButton(
                                type: SocialLoginType.google,
                                isLoading: isLoading,
                                onPressed: isLoading ? null : _handleGoogleSignIn,
                              )
                                  .animate()
                                  .fadeIn(delay: 600.ms, duration: 400.ms)
                                  .slideX(begin: -0.1, end: 0, duration: 400.ms),
                              
                              const SizedBox(height: AppSpacing.m),
                              
                              SocialLoginButton(
                                type: SocialLoginType.facebook,
                                isLoading: isLoading,
                                onPressed: isLoading ? null : _handleFacebookSignIn,
                              )
                                  .animate()
                                  .fadeIn(delay: 700.ms, duration: 400.ms)
                                  .slideX(begin: -0.1, end: 0, duration: 400.ms),
                              
                              const SizedBox(height: AppSpacing.m),
                              
                              SocialLoginButton(
                                type: SocialLoginType.apple,
                                isLoading: isLoading,
                                onPressed: isLoading ? null : _handleAppleSignIn,
                              )
                                  .animate()
                                  .fadeIn(delay: 800.ms, duration: 400.ms)
                                  .slideX(begin: -0.1, end: 0, duration: 400.ms),
                              
                              const SizedBox(height: AppSpacing.xl),
                              
                              // Divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: AppColors.cardBorder,
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
                                    child: Text(
                                      'or',
                                      style: AppTypography.bodySmall(context).copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: AppColors.cardBorder,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              )
                                  .animate()
                                  .fadeIn(delay: 900.ms, duration: 400.ms),
                              
                              const SizedBox(height: AppSpacing.xl),
                              
                              // Input Fields
                              if (_isSignUp) ...[
                                AuthTextField(
                                  label: 'Username',
                                  hint: 'Enter your username',
                                  keyboardType: TextInputType.text,
                                  prefixIcon: Icons.person_outlined,
                                  controller: _usernameController,
                                  validator: _validateUsername,
                                  enabled: !isLoading,
                                )
                                    .animate()
                                    .fadeIn(delay: 1000.ms, duration: 400.ms)
                                    .slideX(begin: -0.1, end: 0, duration: 400.ms),
                                
                                const SizedBox(height: AppSpacing.l),
                              ],
                              
                              AuthTextField(
                                label: 'Email address',
                                hint: 'Enter your email',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icons.email_outlined,
                                controller: _emailController,
                                validator: _validateEmail,
                                enabled: !isLoading,
                              )
                                  .animate()
                                  .fadeIn(delay: 1100.ms, duration: 400.ms)
                                  .slideX(begin: -0.1, end: 0, duration: 400.ms),
                              
                              const SizedBox(height: AppSpacing.l),
                              
                              AuthTextField(
                                label: 'Password',
                                hint: 'Enter your password',
                                obscureText: true,
                                prefixIcon: Icons.lock_outlined,
                                controller: _passwordController,
                                validator: _validatePassword,
                                enabled: !isLoading,
                              )
                                  .animate()
                                  .fadeIn(delay: 1200.ms, duration: 400.ms)
                                  .slideX(begin: -0.1, end: 0, duration: 400.ms),
                              
                              const SizedBox(height: AppSpacing.xl),
                              
                              // Action Button
                              _ActionButton(
                                text: _isSignUp ? 'CREATE ACCOUNT' : 'LOGIN',
                                isLoading: isLoading,
                                onPressed: isLoading ? null : _handleEmailAuth,
                              )
                                  .animate()
                                  .fadeIn(delay: 1300.ms, duration: 400.ms)
                                  .slideY(begin: 0.1, end: 0, duration: 400.ms),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 500.ms)
                            .scale(delay: 400.ms, duration: 500.ms, begin: const Offset(0.95, 0.95)),
                        
                        const SizedBox(height: AppSpacing.l),
                        
                        // Terms and Privacy
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppTypography.bodySmall(context).copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            children: [
                              const TextSpan(text: 'By signing up, you agree to our '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    // TODO: Navigate to terms
                                  },
                                  child: Text(
                                    'Terms',
                                    style: AppTypography.bodySmall(context).copyWith(
                                      color: AppColors.accentLight,
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    // TODO: Navigate to privacy policy
                                  },
                                  child: Text(
                                    'Privacy Policy',
                                    style: AppTypography.bodySmall(context).copyWith(
                                      color: AppColors.accentLight,
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 1400.ms, duration: 400.ms),
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

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.goldPrimary,
                AppColors.goldSecondary,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
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
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/Mauritanian_Belote_Logo2.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.cardBackground,
                        child: Icon(
                          Icons.casino,
                          size: 50,
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

class _TabButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.m),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [
                    AppColors.accentPrimary,
                    AppColors.accentLight,
                  ],
                )
              : null,
          color: isActive ? null : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.text,
    required this.isLoading,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.goldPrimary,
            AppColors.goldSecondary,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldPrimary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.background),
                    ),
                  )
                : Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.background,
                      letterSpacing: 1.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

