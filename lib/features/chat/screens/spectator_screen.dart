import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/floating_particles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/universal_back_button.dart';

class SpectatorScreen extends StatefulWidget {
  final String roomId;
  final String roomName;
  final int participants;

  const SpectatorScreen({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.participants,
  });

  @override
  State<SpectatorScreen> createState() => _SpectatorScreenState();
}

class _SpectatorScreenState extends State<SpectatorScreen> {
  bool _isListening = true;
  bool _isMuted = false;
  double _volume = 1.0;

  // Mock players
  final List<SpectatorPlayer> _players = [
    SpectatorPlayer(
      id: '1',
      username: 'Tijani',
      isHost: true,
      isSpeaking: false,
    ),
    SpectatorPlayer(
      id: '2',
      username: 'Ahmed',
      isHost: false,
      isSpeaking: true,
    ),
    SpectatorPlayer(
      id: '3',
      username: 'Fatima',
      isHost: false,
      isSpeaking: false,
    ),
    SpectatorPlayer(
      id: '4',
      username: 'Omar',
      isHost: false,
      isSpeaking: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            // Floating particles layer
            const Positioned.fill(
              child: FloatingParticles(
                numberOfParticles: 20,
                particleColor: Colors.white24,
              ),
            ),
            // Dark overlay for better visibility
            Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  
                  // Room Info
                  _buildRoomInfo(),
                  
                  // Players Grid
                  Expanded(
                    child: _buildPlayersGrid(),
                  ),
                  
                  // Controls
                  _buildControls(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.m),
      child: Row(
        children: [
          const UniversalBackButton(),
          const Spacer(),
          Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.visibility,
                    color: AppColors.goldPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'SPECTATOR MODE',
                    style: AppTypography.h2(context).copyWith(
                      color: AppColors.goldPrimary,
                      fontSize: 14,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.roomName,
                style: AppTypography.body(context).copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(width: 40), // Balance spacing
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.2, end: 0, duration: 300.ms);
  }

  Widget _buildRoomInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: GlassCard(
        padding: EdgeInsets.all(AppSpacing.m),
        opacity: 0.3,
        blurIntensity: 15.0,
        borderColor: AppColors.goldPrimary,
        borderWidth: 2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem(Icons.people, '${widget.participants}/4', 'Players'),
            _buildInfoItem(Icons.mic, _isListening ? 'Listening' : 'Muted', 'Audio'),
            _buildInfoItem(Icons.volume_up, '${(_volume * 100).toInt()}%', 'Volume'),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 400.ms)
        .scale(delay: 100.ms, duration: 400.ms, begin: const Offset(0.95, 0.95));
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.goldPrimary, size: 24),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.body(context).copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodySmall(context).copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayersGrid() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.m),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.m,
          mainAxisSpacing: AppSpacing.m,
          childAspectRatio: 1.1,
        ),
        itemCount: _players.length,
        itemBuilder: (context, index) {
          final player = _players[index];
          return _buildPlayerCard(player)
              .animate()
              .fadeIn(delay: (index * 100).ms, duration: 400.ms)
              .scale(delay: (index * 100).ms, duration: 400.ms, begin: const Offset(0.9, 0.9));
        },
      ),
    );
  }

  Widget _buildPlayerCard(SpectatorPlayer player) {
    final borderColor = player.isSpeaking
        ? AppColors.success
        : (player.isHost ? AppColors.goldPrimary : AppColors.cardBorder);

    return GlassCard(
      padding: EdgeInsets.all(AppSpacing.m),
      opacity: 0.25,
      blurIntensity: 12.0,
      borderColor: borderColor,
      borderWidth: player.isSpeaking || player.isHost ? 2 : 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentLight,
                      AppColors.accentPrimary,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: AppColors.textPrimary,
                  size: 30,
                ),
              ),
              if (player.isHost)
                Positioned(
                  top: 0,
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
                      size: 12,
                    ),
                  ),
                ),
              if (player.isSpeaking)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.background,
                        width: 2,
                      ),
                    ),
                    child: _buildSpeakingIndicator(),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          // Username
          Text(
            player.username,
            style: AppTypography.body(context).copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (player.isHost) ...[
            const SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.goldPrimary,
                    AppColors.goldSecondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'HOST',
                style: AppTypography.bodySmall(context).copyWith(
                  color: AppColors.background,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpeakingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          margin: EdgeInsets.only(right: 1),
          width: 2,
          height: (index + 1) * 3.0,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(1),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .scaleY(
              duration: 400.ms,
              begin: 0.5,
              end: 1.0,
              curve: Curves.easeInOut,
            )
            .then()
            .scaleY(
              duration: 400.ms,
              begin: 1.0,
              end: 0.5,
              curve: Curves.easeInOut,
            );
      }),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Volume Control
          Row(
            children: [
              Icon(Icons.volume_up, color: AppColors.textPrimary, size: 20),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Slider(
                  value: _volume,
                  onChanged: (value) {
                    setState(() => _volume = value);
                  },
                  activeColor: AppColors.goldPrimary,
                  inactiveColor: AppColors.cardBorder,
                ),
              ),
              Text(
                '${(_volume * 100).toInt()}%',
                style: AppTypography.bodySmall(context).copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                icon: _isListening ? Icons.hearing : Icons.hearing_disabled,
                label: _isListening ? 'Listening' : 'Muted',
                isActive: _isListening,
                onTap: () {
                  setState(() => _isListening = !_isListening);
                },
              ),
              const SizedBox(width: AppSpacing.m),
              _buildControlButton(
                icon: _isMuted ? Icons.mic_off : Icons.mic,
                label: _isMuted ? 'Unmute' : 'Mute',
                isActive: !_isMuted,
                onTap: () {
                  setState(() => _isMuted = !_isMuted);
                },
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 400.ms)
        .slideY(begin: 0.3, end: 0, duration: 400.ms);
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.accentLight : AppColors.cardBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? AppColors.textPrimary : AppColors.textSecondary, size: 20),
            const SizedBox(width: AppSpacing.s),
            Text(
              label,
              style: AppTypography.body(context).copyWith(
                color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpectatorPlayer {
  final String id;
  final String username;
  final bool isHost;
  final bool isSpeaking;

  SpectatorPlayer({
    required this.id,
    required this.username,
    required this.isHost,
    required this.isSpeaking,
  });
}

