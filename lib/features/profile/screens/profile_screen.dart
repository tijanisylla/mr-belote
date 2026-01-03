import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/floating_particles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/player.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Mock data - replace with actual user data
    final username = user?.username ?? 'ELITE_PLAYER_X';
    final isPremium = true; // user?.isPremium ?? false;
    final level = user?.level ?? 24;
    final currentXP = 8450;
    final nextLevelXP = 10000;
    final xpProgress = currentXP / nextLevelXP;
    final rating = 4; // 4 out of 5 stars
    final gamesPlayed = user?.gamesPlayed ?? 342;
    final winRate = user != null && user.gamesPlayed > 0
        ? ((user.gamesWon / user.gamesPlayed) * 100).round()
        : 68;
    final tournaments = 28;
    final totalWins = user?.gamesWon ?? 234;

    return Scaffold(
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            // Floating particles layer
            const Positioned.fill(
              child: FloatingParticles(
                numberOfParticles: 25,
                particleColor: Colors.white24,
              ),
            ),
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.m),
                child: Column(
                  children: [
                    // Profile Header Section
                    _buildProfileHeader(
                      context,
                      user: user,
                      username: username,
                      isPremium: isPremium,
                      rating: rating,
                      level: level,
                      currentXP: currentXP,
                      nextLevelXP: nextLevelXP,
                      xpProgress: xpProgress,
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: -0.2, end: 0, duration: 400.ms),

                    const SizedBox(height: AppSpacing.xl),

                    // Statistics Section
                    _buildStatisticsSection(
                      context,
                      gamesPlayed: gamesPlayed,
                      winRate: winRate,
                      tournaments: tournaments,
                      totalWins: totalWins,
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, duration: 400.ms),

                    const SizedBox(height: AppSpacing.xl),

                    // Chip Store Section
                    _buildChipStoreSection(context)
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, duration: 400.ms),

                    const SizedBox(height: AppSpacing.xl),

                    // Sign Out Button
                    _buildSignOutButton(context, ref)
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

  Widget _buildProfileHeader(
    BuildContext context, {
    required Player? user,
    required String username,
    required bool isPremium,
    required int rating,
    required int level,
    required int currentXP,
    required int nextLevelXP,
    required double xpProgress,
  }) {
    return GlassCard(
      padding: EdgeInsets.all(AppSpacing.xl),
      opacity: 0.25,
      blurIntensity: 15.0,
      child: Column(
        children: [
          // Edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  // Navigate to edit profile
                  context.push('/setup');
                },
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.s),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.accentPrimary,
                        AppColors.accentLight,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              )
                  .animate()
                  .scale(
                    duration: 100.ms,
                    begin: const Offset(1, 1),
                    end: const Offset(0.9, 0.9),
                  ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.m),
          
          // Avatar with Crown
          Stack(
            children: [
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.goldPrimary,
                      AppColors.goldSecondary,
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.goldPrimary,
                    width: 4,
                  ),
                ),
                child: ClipOval(
                  child: user?.avatarPath != null
                      ? (user!.avatarPath!.endsWith('.svg')
                          ? SvgPicture.asset(
                              user.avatarPath!,
                              fit: BoxFit.cover,
                              placeholderBuilder: (context) => Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.textPrimary,
                              ),
                            )
                          : Image.asset(
                              user.avatarPath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppColors.textPrimary,
                                );
                              },
                            ))
                      : Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.textPrimary,
                        ),
                ),
              ),
              // Crown Icon
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.workspace_premium,
                    color: AppColors.background,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.m),

          // Username
          Text(
            username,
            style: AppTypography.h1(context).copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Premium Member Badge
          if (isPremium)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.goldPrimary,
                    AppColors.goldSecondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Premium Member',
                style: AppTypography.bodySmall(context).copyWith(
                  color: AppColors.background,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.m),

          // Star Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: AppColors.goldPrimary,
                size: 20,
              );
            }),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Level Progress Card
          GlassCard(
            padding: EdgeInsets.all(AppSpacing.m),
            opacity: 0.2,
            blurIntensity: 10.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Level Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.m,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.goldPrimary,
                            AppColors.goldSecondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'LEVEL $level',
                        style: AppTypography.bodySmall(context).copyWith(
                          color: AppColors.background,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Text(
                      'Next: Level ${level + 1}',
                      style: AppTypography.body(context).copyWith(
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$currentXP / $nextLevelXP XP',
                      style: AppTypography.body(context).copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: xpProgress,
                    minHeight: 8,
                    backgroundColor: AppColors.accentLight.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(
    BuildContext context, {
    required int gamesPlayed,
    required int winRate,
    required int tournaments,
    required int totalWins,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'STATISTICS',
            style: AppTypography.h2(context).copyWith(
              fontSize: 18,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        // 2x2 Grid
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.emoji_events,
                value: '$gamesPlayed',
                label: 'Games Played',
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.trending_up,
                value: '$winRate%',
                label: 'Win Rate',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.military_tech,
                value: '$tournaments',
                label: 'Tournaments',
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.workspace_premium,
                value: '$totalWins',
                label: 'Total Wins',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return GlassCard(
      padding: EdgeInsets.all(AppSpacing.l),
      opacity: 0.2,
      blurIntensity: 10.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.accentLight,
            size: 32,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            value,
            style: AppTypography.largeNumber(context).copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall(context).copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipStoreSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.email,
              color: AppColors.goldPrimary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.s),
            Text(
              'CHIP STORE',
              style: AppTypography.h2(context).copyWith(
                fontSize: 18,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.l),
        _buildChipPackage(
          context,
          chips: 1000,
          freeChips: 100,
          price: '€9.99',
          isPopular: false,
        ),
        const SizedBox(height: AppSpacing.m),
        _buildChipPackage(
          context,
          chips: 5000,
          freeChips: 1000,
          price: '€39.99',
          isPopular: true,
        ),
      ],
    );
  }

  Widget _buildChipPackage(
    BuildContext context, {
    required int chips,
    required int freeChips,
    required String price,
    required bool isPopular,
  }) {
    return Stack(
      children: [
        GlassCard(
          padding: EdgeInsets.all(AppSpacing.m),
          opacity: isPopular ? 0.3 : 0.2,
          blurIntensity: 10.0,
          borderColor: isPopular ? AppColors.accentLight : AppColors.cardBorder,
          borderWidth: isPopular ? 2 : 1,
          child: Row(
            children: [
              // Chip Circle
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.goldPrimary,
                      AppColors.goldSecondary,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${chips ~/ 1000}K',
                    style: AppTypography.body(context).copyWith(
                      color: AppColors.background,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              // Chip Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$chips CHIPS',
                      style: AppTypography.h3(context).copyWith(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '+$freeChips Free',
                      style: AppTypography.bodySmall(context).copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Price Button
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: AppSpacing.s,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentLight,
                      AppColors.accentPrimary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  price,
                  style: AppTypography.body(context).copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Popular Tag
        if (isPopular)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.goldPrimary,
                    AppColors.goldSecondary,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Text(
                'POPULAR',
                style: AppTypography.bodySmall(context).copyWith(
                  color: AppColors.background,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSignOutButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: OutlinedButton(
        onPressed: () {
          ref.read(authProvider.notifier).signOut();
          // Navigate to landing page after sign out
          context.go('/');
        },
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.m),
          side: BorderSide(color: AppColors.cardBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: AppColors.textPrimary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.s),
            Text(
              'Sign Out',
              style: AppTypography.body(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
