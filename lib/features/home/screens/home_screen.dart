import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/floating_particles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Mock data
  final int notificationCount = 5;
  final int activeLobbiesCount = 24;

  final List<LobbyInfo> lobbies = [
    LobbyInfo(
      name: 'HIGH ROLLERS TABLE',
      minBet: 100,
      seats: 2,
      maxSeats: 4,
      isActive: true,
    ),
    LobbyInfo(
      name: 'CLASSIC BELOTE',
      minBet: 10,
      seats: 1,
      maxSeats: 4,
      isActive: true,
    ),
    LobbyInfo(
      name: 'BEGINNER FRIENDLY',
      minBet: 5,
      seats: 3,
      maxSeats: 4,
      isActive: false,
    ),
  ];

  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(0);
    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return formatted.replaceAllMapped(regex, (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final walletBalance = user?.walletBalance ?? 12450.0;

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
              child: Column(
                children: [
                  // Header
                  _buildHeader(walletBalance),
                  
                  // Promotional Carousel
                  _buildPromotionalCarousel(),
                  
                  // Active Lobbies
                  Expanded(
                    child: _buildActiveLobbies(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double walletBalance) {
    return GlassCard(
      padding: EdgeInsets.all(AppSpacing.m),
      margin: EdgeInsets.all(AppSpacing.m),
      opacity: 0.2,
      blurIntensity: 10.0,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // App Title and Welcome
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MR BELOTE',
                      style: AppTypography.h1(context).copyWith(
                        color: AppColors.goldPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome back, Player!',
                      style: AppTypography.body(context).copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Wallet and Notifications
              Row(
                children: [
                  // Notification Bell
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.notifications,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                        onPressed: () {
                          // TODO: Show notifications
                        },
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                '$notificationCount',
                                style: AppTypography.bodySmall(context).copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  // Wallet Button
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: AppSpacing.s,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: AppColors.background,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${_formatCurrency(walletBalance)} €',
                          style: AppTypography.body(context).copyWith(
                            color: AppColors.background,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.2, end: 0, duration: 300.ms);
  }

  Widget _buildPromotionalCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROMOTIONS',
                style: AppTypography.h2(context).copyWith(
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to all promotions
                },
                child: Text(
                  'View All >',
                  style: AppTypography.body(context).copyWith(
                    color: AppColors.accentLight,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Container(
          height: 200,
          margin: EdgeInsets.symmetric(vertical: AppSpacing.m),
          child: PageView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  context.go('/lobby');
                },
                child: GlassCard(
                  margin: EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  height: 200,
                  opacity: 0.2,
                  blurIntensity: 10.0,
                  borderRadius: BorderRadius.circular(12),
                  borderColor: AppColors.goldPrimary,
                  borderWidth: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Placeholder image background
                        Image.asset(
                          'assets/images/Table_Game.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback gradient if image not found
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.accentPrimary.withValues(alpha: 0.3),
                                    AppColors.goldPrimary.withValues(alpha: 0.2),
                                    AppColors.accentLight.withValues(alpha: 0.3),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.casino,
                                  size: 60,
                                  color: AppColors.goldPrimary.withValues(alpha: 0.5),
                                ),
                              ),
                            );
                          },
                        ),
                        // Dark overlay for better text readability
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.4),
                                Colors.black.withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                        ),
                        // Content overlay
                        Padding(
                          padding: EdgeInsets.all(AppSpacing.m),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'MTT DAILY FREEROLL ENTRY',
                                          style: AppTypography.h3(context).copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          'Join now and win big!',
                                          style: AppTypography.body(context).copyWith(
                                            color: AppColors.goldPrimary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.emoji_events,
                                    color: AppColors.goldPrimary,
                                    size: 40,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 400.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms);
  }

  Widget _buildActiveLobbies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Row(
            children: [
              Text(
                'ACTIVE LOBBIES',
                style: AppTypography.h2(context).copyWith(
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '$activeLobbiesCount Active',
                style: AppTypography.body(context).copyWith(
                  color: AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
            itemCount: lobbies.length,
            itemBuilder: (context, index) {
              return _buildLobbyCard(lobbies[index])
                  .animate()
                  .fadeIn(delay: (index * 100).ms, duration: 300.ms)
                  .slideX(begin: -0.1, end: 0, duration: 300.ms);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLobbyCard(LobbyInfo lobby) {
    return GestureDetector(
      onTap: () {
        context.go('/lobby');
      },
      child: GlassCard(
        margin: EdgeInsets.only(bottom: AppSpacing.m),
        padding: EdgeInsets.all(AppSpacing.m),
        opacity: 0.25,
        blurIntensity: 12.0,
        borderRadius: BorderRadius.circular(12),
        borderColor: AppColors.cardBorder,
        borderWidth: 1,
        child: Row(
          children: [
            // Status Dot
            Container(
              width: 10,
              height: 10,
              margin: EdgeInsets.only(right: AppSpacing.s),
              decoration: BoxDecoration(
                color: lobby.isActive ? AppColors.success : AppColors.textTertiary,
                shape: BoxShape.circle,
              ),
            ),
            
            // Lobby Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    lobby.name,
                    style: AppTypography.h3(context).copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  // Min Bet and Seats
                  Row(
                    children: [
                      // Min Bet Button
                      Container(
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
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: AppColors.background,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.casino,
                                color: AppColors.goldPrimary,
                                size: 10,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Min Bet ${lobby.minBet} €',
                              style: AppTypography.bodySmall(context).copyWith(
                                color: AppColors.background,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      // Seats Button
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.s,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentLight.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.accentLight,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people,
                              color: AppColors.textPrimary,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Seats ${lobby.seats}/${lobby.maxSeats}',
                              style: AppTypography.bodySmall(context).copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // JOIN Button
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.l,
                vertical: AppSpacing.m,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.accentPrimary,
                    AppColors.accentLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'JOIN',
                style: AppTypography.body(context).copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Model
class LobbyInfo {
  final String name;
  final int minBet;
  final int seats;
  final int maxSeats;
  final bool isActive;

  LobbyInfo({
    required this.name,
    required this.minBet,
    required this.seats,
    required this.maxSeats,
    required this.isActive,
  });
}
