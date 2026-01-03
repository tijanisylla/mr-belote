import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/auth_text_field.dart';
import '../../../core/widgets/social_login_button.dart';
import '../../../core/widgets/auth_card.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/floating_particles.dart';
import '../../../core/widgets/universal_back_button.dart';
import '../../../core/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    // Mock login - replace with actual auth later
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() => _isLoading = false);
      // Navigate to home on success
      context.go('/home');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    await ref.read(authProvider.notifier).signInWithGoogle();
    if (mounted && ref.read(authProvider).isAuthenticated) {
      context.go('/home');
    }
  }

  Future<void> _handleFacebookSignIn() async {
    await ref.read(authProvider.notifier).signInWithFacebook();
    if (mounted && ref.read(authProvider).isAuthenticated) {
      context.go('/home');
    }
  }

  Future<void> _handleAppleSignIn() async {
    // Mock Apple Sign In - UI only
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      context.go('/home');
    }
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
                padding: EdgeInsets.all(AppSpacing.l),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Universal back button
                      Align(
                        alignment: Alignment.topLeft,
                        child: const UniversalBackButton(),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                
                // Logo with Hero animation
                Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/images/Mauritanian_Belote_Logo2.png',
                    height: 120,
                    width: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(60),
                          border: Border.all(
                            color: AppColors.goldPrimary,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.casino,
                          size: 60,
                          color: AppColors.goldPrimary,
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: AppSpacing.m),
                
                // App Title
                Text(
                  'MR BELOTE 🇲🇷',
                  style: AppTypography.h1(context).copyWith(
                    color: AppColors.goldPrimary,
                    fontSize: 36,
                    letterSpacing: 2,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms)
                    .slideY(begin: -0.2, end: 0, delay: 300.ms, duration: 400.ms),
                
                const SizedBox(height: AppSpacing.s),
                
                Text(
                  'Welcome back!',
                  style: AppTypography.body(context).copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // Auth Card
                AuthCard(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email Field
                      AuthTextField(
                        label: 'Email',
                        hint: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        controller: _emailController,
                        validator: _validateEmail,
                        enabled: !isLoading,
                      )
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 400.ms)
                          .slideX(begin: -0.1, end: 0, delay: 500.ms, duration: 400.ms),
                      
                      const SizedBox(height: AppSpacing.l),
                      
                      // Password Field
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
                          .fadeIn(delay: 600.ms, duration: 400.ms)
                          .slideX(begin: -0.1, end: 0, delay: 600.ms, duration: 400.ms),
                      
                      const SizedBox(height: AppSpacing.s),
                      
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  // TODO: Navigate to forgot password screen
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Forgot password feature coming soon!'),
                                    ),
                                  );
                                },
                          child: Text(
                            'Forgot password?',
                            style: AppTypography.bodySmall(context).copyWith(
                              color: AppColors.goldPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 700.ms, duration: 400.ms),
                      
                      const SizedBox(height: AppSpacing.l),
                      
                      // Login Button
                      AppButton(
                        text: 'Login',
                        type: ButtonType.gold,
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _handleEmailLogin,
                        width: double.infinity,
                      )
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 400.ms)
                          .slideY(begin: 0.1, end: 0, delay: 800.ms, duration: 400.ms),
                      
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
                              'OR',
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
                      
                      // Social Login Buttons
                      SocialLoginButton(
                        type: SocialLoginType.google,
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _handleGoogleSignIn,
                      )
                          .animate()
                          .fadeIn(delay: 1000.ms, duration: 400.ms)
                          .slideX(begin: 0.1, end: 0, delay: 1000.ms, duration: 400.ms),
                      
                      const SizedBox(height: AppSpacing.m),
                      
                      SocialLoginButton(
                        type: SocialLoginType.facebook,
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _handleFacebookSignIn,
                      )
                          .animate()
                          .fadeIn(delay: 1100.ms, duration: 400.ms)
                          .slideX(begin: 0.1, end: 0, delay: 1100.ms, duration: 400.ms),
                      
                      const SizedBox(height: AppSpacing.m),
                      
                      SocialLoginButton(
                        type: SocialLoginType.apple,
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _handleAppleSignIn,
                      )
                          .animate()
                          .fadeIn(delay: 1200.ms, duration: 400.ms)
                          .slideX(begin: 0.1, end: 0, delay: 1200.ms, duration: 400.ms),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 500.ms)
                    .scale(delay: 400.ms, duration: 500.ms, begin: const Offset(0.95, 0.95)),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTypography.body(context).copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: isLoading ? null : () => context.go('/signup'),
                      child: Text(
                        'Sign Up',
                        style: AppTypography.body(context).copyWith(
                          color: AppColors.goldPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 1300.ms, duration: 400.ms),
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
}
