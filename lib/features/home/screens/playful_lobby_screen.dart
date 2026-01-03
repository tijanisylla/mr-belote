import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/floating_particles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/lobby_model.dart';

class PlayfulLobbyScreen extends ConsumerStatefulWidget {
  const PlayfulLobbyScreen({super.key});

  @override
  ConsumerState<PlayfulLobbyScreen> createState() => _PlayfulLobbyScreenState();
}

class _PlayfulLobbyScreenState extends ConsumerState<PlayfulLobbyScreen> {
  // Mock lobbies data
  final List<LobbyModel> lobbies = [
    LobbyModel(
      id: '1',
      roomId: 'ABC123',
      name: 'HIGH ROLLERS TABLE',
      isFree: false,
      minBet: 500,
      currentPlayers: 2,
      maxPlayers: 4,
      isActive: true,
      hostName: 'Ahmed',
      hostLevel: 25,
      gameMode: 'CLASSIC BELOTE',
    ),
    LobbyModel(
      id: '2',
      roomId: 'FREE99',
      name: 'FREE PRACTICE ROOM',
      isFree: true,
      currentPlayers: 1,
      maxPlayers: 4,
      isActive: true,
      hostName: 'Fatima',
      hostLevel: 10,
      gameMode: 'CLASSIC BELOTE',
    ),
    LobbyModel(
      id: '3',
      roomId: 'VIP456',
      name: 'VIP TOURNAMENT',
      isFree: false,
      minBet: 1000,
      currentPlayers: 3,
      maxPlayers: 4,
      isActive: true,
      hostName: 'Tijani',
      hostLevel: 30,
      gameMode: 'TOURNAMENT',
    ),
    LobbyModel(
      id: '4',
      roomId: 'BEG789',
      name: 'BEGINNER FRIENDLY',
      isFree: true,
      currentPlayers: 2,
      maxPlayers: 4,
      isActive: true,
      hostName: 'Sara',
      hostLevel: 5,
      gameMode: 'CLASSIC BELOTE',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    // Get user data or use defaults
    final username = user?.username ?? 'Player123';
    final level = user?.level ?? 15;
    final score = 12500; // Could be calculated from games
    final avatarPath = user?.avatarPath ?? 'assets/avatars/adventurer-1766914875318.svg';
    return Scaffold(
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            // Floating particles
            const Positioned.fill(
              child: FloatingParticles(
                numberOfParticles: 30,
                particleColor: Colors.white24,
              ),
            ),
            // Decorative card suits
            _buildCardSuitsBackground(),
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.m),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // User Profile Card
                    _buildUserProfileCard()
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(delay: 100.ms, duration: 400.ms, begin: const Offset(0.9, 0.9)),
                    
                    const SizedBox(height: AppSpacing.l),
                    
                    // Action Buttons Grid
                    _buildActionButtons()
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, duration: 400.ms),
                    
                    const SizedBox(height: AppSpacing.l),
                    
                    // Quick Stats
                    _buildQuickStats()
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, duration: 400.ms),
                    
                    const SizedBox(height: AppSpacing.l),
                    
                    // Lobbies Section
                    _buildLobbiesSection()
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, duration: 400.ms),
                  ],
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
      children: List.generate(15, (index) {
        final random = math.Random(index);
        return Positioned(
          left: random.nextDouble() * MediaQuery.of(context).size.width,
          top: random.nextDouble() * MediaQuery.of(context).size.height,
          child: Transform.rotate(
            angle: random.nextDouble() * 2 * math.pi,
            child: Opacity(
              opacity: 0.08,
              child: Text(
                suits[index % 4],
                style: TextStyle(
                  fontSize: 30 + random.nextDouble() * 30,
                  color: colors[index % 4],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildUserProfileCard() {
    return GlassCard(
      padding: EdgeInsets.all(AppSpacing.l),
      opacity: 0.3,
      blurIntensity: 15.0,
      borderColor: AppColors.goldPrimary,
      borderWidth: 2,
      child: Row(
        children: [
          // Avatar with level badge
          Stack(
            children: [
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
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldPrimary.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: avatarPath.endsWith('.svg')
                      ? SvgPicture.asset(
                          avatarPath,
                          fit: BoxFit.cover,
                          placeholderBuilder: (context) => Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.textPrimary,
                          ),
                        )
                      : Image.asset(
                          avatarPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.textPrimary,
                            );
                          },
                        ),
                ),
              ),
              // Level badge
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.accentPrimary,
                        AppColors.accentLight,
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.background,
                      width: 3,
                    ),
                  ),
                  child: Text(
                    '$level',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(width: AppSpacing.l),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: AppColors.goldPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Level $level',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.goldPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: AppColors.accentLight,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Score: ${_formatScore(score)}',
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
      ),
    );
  }

  Widget _buildActionButtons() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.m,
      mainAxisSpacing: AppSpacing.m,
      childAspectRatio: 1.2,
      children: [
        _buildActionButton(
          icon: Icons.play_circle_filled,
          label: 'Start Game',
          color: AppColors.goldPrimary,
          onTap: () => context.push('/create-game'),
        ),
        _buildActionButton(
          icon: Icons.group,
          label: 'Join Room',
          color: AppColors.accentPrimary,
          onTap: () => context.go('/lobby'),
        ),
        _buildActionButton(
          icon: Icons.person,
          label: 'Profile',
          color: AppColors.accentLight,
          onTap: () => context.go('/profile'),
        ),
        _buildActionButton(
          icon: Icons.settings,
          label: 'Settings',
          color: AppColors.cardBorder,
          onTap: () {
            // TODO: Open settings
          },
        ),
        _buildActionButton(
          icon: Icons.shopping_bag,
          label: 'Shop',
          color: AppColors.goldSecondary,
          onTap: () {
            // TODO: Open shop
          },
        ),
        _buildActionButton(
          icon: Icons.card_giftcard,
          label: 'Rewards',
          color: AppColors.cardRed,
          onTap: () {
            // TODO: Open rewards
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: EdgeInsets.all(AppSpacing.m),
        opacity: 0.25,
        blurIntensity: 12.0,
        borderColor: color,
        borderWidth: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withValues(alpha: 0.7),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: AppColors.textPrimary,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          .animate()
          .scale(
            duration: 100.ms,
            begin: const Offset(1, 1),
            end: const Offset(0.95, 0.95),
          ),
    );
  }

  Widget _buildQuickStats() {
    return GlassCard(
      padding: EdgeInsets.all(AppSpacing.m),
      opacity: 0.25,
      blurIntensity: 12.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.games, '342', 'Games'),
          _buildStatItem(Icons.trending_up, '68%', 'Win Rate'),
          _buildStatItem(Icons.emoji_events, '234', 'Wins'),
        ],
      ),
    );
  }

  Widget _buildLobbiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AVAILABLE GAMES',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${lobbies.length} Active',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        ...lobbies.map((lobby) => _buildLobbyCard(lobby)).toList(),
      ],
    );
  }

  Widget _buildLobbyCard(LobbyModel lobby) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.m),
      child: GestureDetector(
        onTap: lobby.canJoin 
            ? () => context.push('/lobby', extra: {
                'lobbyId': lobby.id,
                'roomName': lobby.name,
                'isFree': lobby.isFree,
                'minBet': lobby.minBet,
                'maxPlayers': lobby.maxPlayers,
                'gameMode': lobby.gameMode,
              }) 
            : lobby.isFull 
                ? () => context.push('/spectate/${lobby.id}')
                : null,
        child: GlassCard(
          padding: EdgeInsets.all(AppSpacing.m),
          opacity: 0.25,
          blurIntensity: 12.0,
          borderColor: lobby.isFree ? AppColors.accentPrimary : AppColors.goldPrimary,
          borderWidth: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Free/Money Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: lobby.isFree
                            ? [AppColors.accentPrimary, AppColors.accentLight]
                            : [AppColors.goldPrimary, AppColors.goldSecondary],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          lobby.isFree ? Icons.card_giftcard : Icons.account_balance_wallet,
                          size: 14,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lobby.isFree ? 'FREE GAME' : 'MONEY GAME',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Status indicator
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: lobby.isActive ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                lobby.name,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    lobby.hostName ?? 'Host',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (lobby.hostLevel != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Lv.${lobby.hostLevel}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.accentPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(Icons.group, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${lobby.currentPlayers}/${lobby.maxPlayers} Players',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (!lobby.isFree && lobby.minBet != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.casino, size: 16, color: AppColors.goldPrimary),
                    const SizedBox(width: 4),
                    Text(
                      '${lobby.minBet!.toStringAsFixed(0)} MRU',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.goldPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              if (lobby.isFull)
                Padding(
                  padding: EdgeInsets.only(top: AppSpacing.s),
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          'FULL - Can Spectate',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.goldPrimary, size: 28),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatScore(int score) {
    if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    }
    return score.toString();
  }
}

