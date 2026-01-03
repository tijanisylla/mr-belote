import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/floating_particles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class UserSetupScreen extends ConsumerStatefulWidget {
  const UserSetupScreen({super.key});

  @override
  ConsumerState<UserSetupScreen> createState() => _UserSetupScreenState();
}

class _UserSetupScreenState extends ConsumerState<UserSetupScreen> {
  int _currentStep = 0;
  String? _selectedGender;
  int? _age;
  String? _selectedAvatar;
  final TextEditingController _usernameController = TextEditingController();

  final List<String> _maleAvatars = [
    'assets/avatars/adventurer-1766914875318.svg',
    'assets/avatars/adventurer-1766914879909.svg',
    'assets/avatars/adventurer-1766914883742.svg',
    'assets/avatars/adventurer-1766914888318.svg',
    'assets/avatars/adventurer-1766914891975.svg',
    'assets/avatars/adventurer-1766914895177.svg',
  ];

  final List<String> _femaleAvatars = [
    'assets/avatars/adventurer-1766914898179.svg',
    'assets/avatars/adventurer-1766914901584.svg',
    'assets/avatars/adventurer-1766914908174.svg',
    'assets/avatars/adventurer-1766914911686.svg',
    'assets/avatars/adventurer-1766914917005.svg',
    'assets/avatars/adventurer-1766914922150.svg',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // Auto-assign default avatar if skipped on step 2
    if (_currentStep == 2 && _selectedAvatar == null) {
      _assignDefaultAvatar();
    }
    
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      _completeSetup();
    }
  }
  
  void _assignDefaultAvatar() {
    final avatars = _selectedGender == 'male' ? _maleAvatars : _femaleAvatars;
    setState(() {
      _selectedAvatar = avatars.first; // Assign first avatar as default
    });
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _completeSetup() {
    // Generate username if not provided
    final username = _usernameController.text.isEmpty 
        ? 'Player${math.Random().nextInt(1000)}' 
        : _usernameController.text;
    
    // Update user profile with setup data
    final authState = ref.read(authProvider);
    final user = authState.user;
    
    if (user != null) {
      ref.read(authProvider.notifier).updateUserProfile(
        username: username,
        avatarPath: _selectedAvatar,
        gender: _selectedGender,
        age: _age,
        hasCompletedSetup: true,
      );
    } else {
      // Create new user if doesn't exist
      ref.read(authProvider.notifier).createUserWithSetup(
        username: username,
        avatarPath: _selectedAvatar,
        gender: _selectedGender,
        age: _age,
      );
    }
    
    // Navigate to profile preview
    context.push('/profile-preview', extra: {
      'gender': _selectedGender,
      'age': _age,
      'avatar': _selectedAvatar,
      'username': username,
    });
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _selectedGender != null;
      case 1:
        return _age != null && _age! >= 18;
      case 2:
        return true; // Avatar is now optional (can be skipped)
      case 3:
        return true; // Username is optional
      case 4:
        return true; // All required fields are filled, can complete
      default:
        return false;
    }
  }

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
              child: Column(
                children: [
                  // Progress indicator
                  _buildProgressIndicator(),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(AppSpacing.l),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          
                          // Step content
                          _buildStepContent(),
                          
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  
                  // Navigation buttons
                  _buildNavigationButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.m),
      child: Row(
        children: List.generate(5, (index) {
          final isActive = index <= _currentStep;
          final isCurrent = index == _currentStep;
          
          return Expanded(
            child: Container(
              height: 6,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(
                        colors: [
                          AppColors.goldPrimary,
                          AppColors.goldSecondary,
                        ],
                      )
                    : null,
                color: isActive ? null : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(3),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppColors.goldPrimary.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            )
                .animate()
                .scale(
                  duration: 300.ms,
                  begin: isCurrent ? const Offset(1, 1) : const Offset(1, 1),
                  end: isCurrent ? const Offset(1.1, 1.1) : const Offset(1, 1),
                ),
          );
        }),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.2, end: 0, duration: 400.ms);
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildGenderSelection();
      case 1:
        return _buildAgeInput();
      case 2:
        return _buildAvatarSelection();
      case 3:
        return _buildUsernameInput();
      case 4:
        return _buildProfilePreview();
      default:
        return const SizedBox();
    }
  }

  Widget _buildGenderSelection() {
    return Column(
      children: [
        Text(
          'Choose Your Gender',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: -0.2, end: 0, duration: 400.ms),
        
        const SizedBox(height: 60),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGenderOption('male', 'Male', Icons.person),
            const SizedBox(width: AppSpacing.xl),
            _buildGenderOption('female', 'Female', Icons.person_outline),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender, String label, IconData icon) {
    final isSelected = _selectedGender == gender;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
          _selectedAvatar = null; // Reset avatar when gender changes
        });
      },
      child: GlassCard(
        padding: EdgeInsets.all(AppSpacing.xl),
        opacity: isSelected ? 0.4 : 0.25,
        blurIntensity: 15.0,
        borderColor: isSelected ? AppColors.goldPrimary : AppColors.cardBorder,
        borderWidth: isSelected ? 3 : 1,
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [
                          AppColors.goldPrimary,
                          AppColors.goldSecondary,
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          AppColors.accentLight,
                          AppColors.accentPrimary,
                        ],
                      ),
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.goldPrimary.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: 50,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      )
          .animate()
          .scale(
            duration: 200.ms,
            begin: const Offset(1, 1),
            end: isSelected ? const Offset(1.05, 1.05) : const Offset(1, 1),
          ),
    );
  }

  Widget _buildAgeInput() {
    return Column(
      children: [
        Text(
          'How Old Are You?',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: -0.2, end: 0, duration: 400.ms),
        
        const SizedBox(height: 60),
        
        // Age selector
        Container(
          height: 200,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 60,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              setState(() => _age = 18 + index);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                final age = 18 + index;
                final isSelected = _age == age;
                
                return Center(
                  child: Text(
                    '$age',
                    style: GoogleFonts.poppins(
                      fontSize: isSelected ? 36 : 24,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.goldPrimary : AppColors.textSecondary,
                    ),
                  ),
                );
              },
              childCount: 83, // 18 to 100
            ),
          ),
        ),
        
        if (_age != null && _age! < 18)
          Padding(
            padding: EdgeInsets.only(top: AppSpacing.m),
            child: Text(
              'You must be 18+ to play',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarSelection() {
    final avatars = _selectedGender == 'male' ? _maleAvatars : _femaleAvatars;
    
    return Column(
      children: [
        Text(
          'Choose Your Avatar',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: -0.2, end: 0, duration: 400.ms),
        
        const SizedBox(height: 10),
        
        Text(
          '(Optional - Default will be assigned if skipped)',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms),
        
        const SizedBox(height: 30),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: AppSpacing.m,
            mainAxisSpacing: AppSpacing.m,
            childAspectRatio: 1,
          ),
          itemCount: avatars.length,
          itemBuilder: (context, index) {
            final avatar = avatars[index];
            final isSelected = _selectedAvatar == avatar;
            
            return GestureDetector(
              onTap: () {
                setState(() => _selectedAvatar = avatar);
              },
              child: GlassCard(
                padding: EdgeInsets.all(AppSpacing.s),
                opacity: isSelected ? 0.4 : 0.25,
                blurIntensity: 15.0,
                borderColor: isSelected ? AppColors.goldPrimary : AppColors.cardBorder,
                borderWidth: isSelected ? 3 : 1,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.goldPrimary.withValues(alpha: 0.5),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ]
                        : null,
                  ),
                  child: ClipOval(
                    child: avatar.endsWith('.svg')
                        ? SvgPicture.asset(
                            avatar,
                            fit: BoxFit.cover,
                            placeholderBuilder: (context) => Container(
                              color: AppColors.cardBackground,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.goldPrimary,
                              ),
                            ),
                          )
                        : Image.asset(
                            avatar,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.cardBackground,
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: AppColors.goldPrimary,
                                ),
                              );
                            },
                          ),
                  ),
                ),
              )
                  .animate()
                  .scale(
                    duration: 200.ms,
                    begin: const Offset(1, 1),
                    end: isSelected ? const Offset(1.1, 1.1) : const Offset(1, 1),
                  ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUsernameInput() {
    return Column(
      children: [
        Text(
          'Choose a Username',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: -0.2, end: 0, duration: 400.ms),
        
        const SizedBox(height: 20),
        
        Text(
          '(Optional)',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        
        const SizedBox(height: 60),
        
        GlassCard(
          padding: EdgeInsets.all(AppSpacing.m),
          opacity: 0.3,
          blurIntensity: 15.0,
          child: TextField(
            controller: _usernameController,
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Enter username...',
              hintStyle: GoogleFonts.poppins(
                color: AppColors.textTertiary,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.person,
                color: AppColors.goldPrimary,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: AppSpacing.m),
        
        Text(
          'If left empty, a random username will be generated',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfilePreview() {
    return Column(
      children: [
        Text(
          'Your Profile',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: -0.2, end: 0, duration: 400.ms),
        
        const SizedBox(height: 40),
        
        GlassCard(
          padding: EdgeInsets.all(AppSpacing.xl),
          opacity: 0.3,
          blurIntensity: 15.0,
          borderColor: AppColors.goldPrimary,
          borderWidth: 2,
          child: Column(
            children: [
              // Avatar
              Container(
                width: 120,
                height: 120,
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
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _selectedAvatar != null
                      ? (_selectedAvatar!.endsWith('.svg')
                          ? SvgPicture.asset(
                              _selectedAvatar!,
                              fit: BoxFit.cover,
                              placeholderBuilder: (context) => Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.textPrimary,
                              ),
                            )
                          : Image.asset(
                              _selectedAvatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppColors.textPrimary,
                                );
                              },
                            ))
                      : Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.textPrimary,
                        ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.l),
              
              // Username
              Text(
                _usernameController.text.isEmpty
                    ? 'Player${math.Random().nextInt(1000)}'
                    : _usernameController.text,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: AppSpacing.m),
              
              // Gender and Age
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _selectedGender == 'male' ? Icons.person : Icons.person_outline,
                    color: AppColors.goldPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    _selectedGender?.toUpperCase() ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.l),
                  Icon(
                    Icons.cake,
                    color: AppColors.goldPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    '$_age years old',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: _buildButton(
                text: 'Back',
                onTap: _previousStep,
                isSecondary: true,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: AppSpacing.m),
          
          // Show "Skip" button on avatar selection step if no avatar selected
          if (_currentStep == 2 && _selectedAvatar == null)
            Expanded(
              flex: _currentStep == 0 ? 1 : 2,
              child: _buildButton(
                text: 'Skip',
                onTap: _nextStep,
                isSkip: true,
              ),
            )
          else
            Expanded(
              flex: _currentStep == 0 ? 1 : 2,
              child: _buildButton(
                text: _currentStep == 4 ? 'Complete' : 'Next',
                onTap: _canProceed ? _nextStep : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback? onTap,
    bool isSecondary = false,
    bool isSkip = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.m),
        decoration: BoxDecoration(
          gradient: onTap != null && !isSecondary && !isSkip
              ? const LinearGradient(
                  colors: [
                    AppColors.goldPrimary,
                    AppColors.goldSecondary,
                  ],
                )
              : null,
          color: onTap == null
              ? AppColors.cardBackground
              : (isSecondary || isSkip ? AppColors.cardBackground : null),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSkip
                ? AppColors.textSecondary
                : (isSecondary
                    ? AppColors.cardBorder
                    : (onTap != null ? AppColors.goldPrimary : AppColors.cardBorder)),
            width: 1,
          ),
          boxShadow: onTap != null && !isSecondary && !isSkip
              ? [
                  BoxShadow(
                    color: AppColors.goldPrimary.withValues(alpha: 0.5),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: onTap == null
                  ? AppColors.textTertiary
                  : (isSecondary || isSkip ? AppColors.textPrimary : AppColors.background),
            ),
          ),
        ),
      ),
    )
        .animate()
        .scale(
          duration: 100.ms,
          begin: const Offset(1, 1),
          end: onTap != null ? const Offset(0.95, 0.95) : const Offset(1, 1),
        );
  }
}

