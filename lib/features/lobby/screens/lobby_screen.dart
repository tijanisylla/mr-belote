import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/floating_particles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/universal_back_button.dart';

// Global variable to pass data between routes (temporary solution)
// In production, use a state management solution like Riverpod
Map<String, dynamic>? _lobbyRouteData;

// Function to set route data from router
void setLobbyRouteData(Map<String, dynamic> data) {
  _lobbyRouteData = data;
}

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  // Room state - will be initialized from route extras or defaults
  late String roomName;
  late String gameMode;
  int? minBet;
  late int pointsToWin;
  late int maxPlayers;
  late bool isFree;
  String roomId = '';

  @override
  void initState() {
    super.initState();
    // Default values
    roomName = 'VIP ROOM #247';
    gameMode = 'CLASSIC BELOTE';
    minBet = 500;
    pointsToWin = 1000;
    maxPlayers = 4;
    isFree = false;
    roomId = 'ABC123';
  }

  // --- lightweight local state & helpers (stubs to ensure compile)
  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];
  final List<LobbyPlayer> players = [
    LobbyPlayer(
      id: '1',
      username: 'You',
      level: 1,
      isHost: true,
      isReady: false,
      isBot: false,
      isSpeaking: false,
    ),
  ];

  int get readyCount => players.where((p) => p.isReady).length;
  int get currentPlayerCount => players.length;
  bool get isReady => players.isNotEmpty ? players.first.isReady : false;
  bool get canStartGame => readyCount == maxPlayers && currentPlayerCount == maxPlayers;

  bool micOn = false;
  bool soundOn = true;

  void _toggleReady() {
    if (players.isEmpty) return;
    setState(() {
      players[0] = players[0].copyWith(isReady: !players[0].isReady);
    });
  }

  void _addBot() {
    if (currentPlayerCount >= maxPlayers) return;
    setState(() {
      players.add(LobbyPlayer(
        id: '${players.length + 1}',
        username: 'Bot ${players.length}',
        level: 10 + players.length,
        isHost: false,
        isReady: true,
        isBot: true,
        isSpeaking: false,
      ));
    });
  }

  void _toggleMic() {
    setState(() => micOn = !micOn);
  }

  void _toggleSound() {
    setState(() => soundOn = !soundOn);
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _initializeFromExtras(dynamic extra) {
    if (extra != null && extra is Map<String, dynamic>) {
      setState(() {
        roomName = extra['roomName'] as String? ?? roomName;
        gameMode = extra['gameMode'] as String? ?? gameMode;
        minBet = extra['minBet'] as int?;
        maxPlayers = extra['maxPlayers'] as int? ?? maxPlayers;
        isFree = extra['isFree'] as bool? ?? (minBet == null);
        pointsToWin = extra['pointsToWin'] as int? ?? pointsToWin;
        roomId = extra['roomId'] as String? ?? roomId;
      });
    }
  }

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;
    
    setState(() {
      _chatMessages.add(ChatMessage(
        username: 'You',
        message: _chatController.text.trim(),
        color: AppColors.goldPrimary,
      ));
      _chatController.clear();
    });
  }

  void _startGame() {
    if (canStartGame) {
      context.go('/game');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get extras from GoRouter state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      if (route != null) {
        // Try to get from GoRouter state via context
        final extra = (route.settings.arguments as Map<String, dynamic>?);
        if (extra != null) {
          _initializeFromExtras(extra);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  // Top Navigation Bar
                  _buildTopBar(),
                  
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(AppSpacing.m),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Game Mode Panel
                          _buildGameModePanel(),
                          
                          const SizedBox(height: AppSpacing.l),
                          
                          // Players Section
                          _buildPlayersSection(),
                          
                          const SizedBox(height: AppSpacing.l),
                          
                          // Room Chat
                          _buildRoomChat(),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom Controls
                  _buildBottomControls(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.m),
      child: Row(
        children: [
          // Back Button
          const UniversalBackButton(),
          
          const Spacer(),
          
          // Room Info
          Column(
            children: [
              Text(
                roomName,
                style: AppTypography.h2(context).copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.goldPrimary, AppColors.goldSecondary],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      roomId,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    isFree ? '• FREE' : '• ${minBet ?? 0} MRU',
                    style: AppTypography.bodySmall(context).copyWith(
                      color: isFree ? AppColors.accentPrimary : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: isFree ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const Spacer(),
          
          // Share and Settings
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.share, color: AppColors.textPrimary),
                onPressed: () {
                  // TODO: Share room
                },
              ),
              IconButton(
                icon: Icon(Icons.settings, color: AppColors.textPrimary),
                onPressed: () {
                  // TODO: Open settings
                },
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

  Widget _buildGameModePanel() {
    return GlassCard(
      padding: EdgeInsets.all(AppSpacing.l),
      opacity: 0.3,
      blurIntensity: 15.0,
      borderColor: AppColors.accentPrimary,
      borderWidth: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Game Mode',
            style: AppTypography.bodySmall(context).copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              Expanded(
                child: Text(
                  gameMode,
                  style: AppTypography.h1(context).copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.casino,
                color: AppColors.goldPrimary,
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              _buildInfoChip('Points', '$pointsToWin'),
              const SizedBox(width: AppSpacing.s),
              if (!isFree)
                _buildInfoChip('Min Bet', '${minBet ?? 0} MRU', isHighlighted: true),
              if (isFree)
                _buildInfoChip('Mode', 'FREE GAME', isHighlighted: true),
              const SizedBox(width: AppSpacing.s),
              _buildInfoChip('Players', '$currentPlayerCount/$maxPlayers'),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 400.ms)
        .scale(delay: 100.ms, duration: 400.ms, begin: const Offset(0.95, 0.95));
  }

  Widget _buildInfoChip(String label, String value, {bool isHighlighted = false}) {
    return Expanded(
      child: GlassCard(
        padding: EdgeInsets.all(AppSpacing.s),
        opacity: isHighlighted ? 0.4 : 0.2,
        blurIntensity: 10.0,
        borderColor: isHighlighted ? AppColors.accentLight : AppColors.cardBorder,
        borderWidth: isHighlighted ? 1.5 : 1,
        child: Column(
          children: [
            Text(
              label,
              style: AppTypography.bodySmall(context).copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.body(context).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PLAYERS',
              style: AppTypography.h2(context).copyWith(
                fontSize: 16,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              '$readyCount/$currentPlayerCount Ready',
              style: AppTypography.body(context).copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        // Player Cards
        ...players.map((player) => Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.m),
          child: _buildPlayerCard(player),
        )),
        // Add Bot Button
        if (currentPlayerCount < maxPlayers)
          _buildAddBotButton(),
      ],
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms);
  }

  Widget _buildPlayerCard(LobbyPlayer player) {
    final isYou = player.id == '1';
    final borderColor = player.isSpeaking
        ? AppColors.success
        : (player.isReady ? AppColors.success.withValues(alpha: 0.5) : AppColors.cardBorder);

    return GlassCard(
      padding: EdgeInsets.all(AppSpacing.m),
      opacity: 0.25,
      blurIntensity: 12.0,
      borderColor: borderColor,
      borderWidth: player.isSpeaking ? 2 : 1,
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
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
                  size: 28,
                ),
              ),
              if (player.isHost)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
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
            ],
          ),
          const SizedBox(width: AppSpacing.m),
          // Player Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isYou ? 'You (${player.username})' : player.username,
                      style: AppTypography.body(context).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (player.isBot) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentLight.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'BOT',
                          style: AppTypography.bodySmall(context).copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${player.level}',
                        style: AppTypography.bodySmall(context).copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Level ${player.level}',
                      style: AppTypography.bodySmall(context).copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    if (player.isSpeaking) ...[
                      const SizedBox(width: AppSpacing.s),
                      _buildSpeakingIndicator(),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Ready Button
          if (isYou)
            _buildReadyButton(player.isReady)
          else
            _buildStatusBadge(player.isReady),
        ],
      ),
    );
  }

  Widget _buildSpeakingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          margin: EdgeInsets.only(right: 2),
          width: 3,
          height: (index + 1) * 4.0,
          decoration: BoxDecoration(
            color: AppColors.success,
            borderRadius: BorderRadius.circular(2),
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

  Widget _buildReadyButton(bool isReady) {
    return GestureDetector(
      onTap: _toggleReady,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        decoration: BoxDecoration(
          color: isReady ? AppColors.success : AppColors.goldPrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.background.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          isReady ? 'READY' : 'NOT READY',
          style: AppTypography.bodySmall(context).copyWith(
            color: AppColors.background,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isReady) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: isReady ? AppColors.success : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isReady ? AppColors.success : AppColors.cardBorder,
          width: 1,
        ),
      ),
      child: Text(
        isReady ? 'READY' : 'NOT READY',
        style: AppTypography.bodySmall(context).copyWith(
          color: isReady ? AppColors.textPrimary : AppColors.textSecondary,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildAddBotButton() {
    return GestureDetector(
      onTap: _addBot,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.cardBorder,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.s),
            Text(
              'Add Bot or Wait for Player',
              style: AppTypography.body(context).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomChat() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: AppColors.textPrimary,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'ROOM CHAT',
                  style: AppTypography.h2(context).copyWith(
                    fontSize: 14,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            Text(
              '${_chatMessages.length} messages',
              style: AppTypography.bodySmall(context).copyWith(
                color: AppColors.accentLight,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        // Chat Messages
        Container(
          constraints: const BoxConstraints(maxHeight: 120),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _chatMessages.length,
            itemBuilder: (context, index) {
              final message = _chatMessages[index];
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xs),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${message.username}: ',
                        style: AppTypography.bodySmall(context).copyWith(
                          color: message.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: message.message,
                        style: AppTypography.bodySmall(context).copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        // Chat Input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _chatController,
                style: AppTypography.body(context),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: AppTypography.body(context).copyWith(
                    color: AppColors.textTertiary,
                  ),
                  filled: true,
                  fillColor: AppColors.cardBackground.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.accentLight, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.s,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            IconButton(
              icon: Icon(Icons.send, color: AppColors.accentLight),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 400.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms);
  }

  Widget _buildBottomControls() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.m),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Voice Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildVoiceControl(
                icon: Icons.mic,
                label: 'Mic',
                isOn: micOn,
                onTap: _toggleMic,
              ),
              const SizedBox(width: AppSpacing.m),
              _buildVoiceControl(
                icon: Icons.volume_up,
                label: 'Sound',
                isOn: soundOn,
                onTap: _toggleSound,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          // Game Controls
          Row(
            children: [
              Expanded(
                child: _buildControlButton(
                  text: 'READY',
                  isActive: isReady,
                  onTap: _toggleReady,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                flex: 2,
                child: _buildControlButton(
                  text: 'START GAME',
                  isActive: canStartGame,
                  onTap: _startGame,
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 400.ms)
        .slideY(begin: 0.3, end: 0, duration: 400.ms);
  }

  Widget _buildVoiceControl({
    required IconData icon,
    required String label,
    required bool isOn,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        decoration: BoxDecoration(
          color: isOn ? AppColors.success : AppColors.error,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOn ? AppColors.success : AppColors.error,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Text(
              isOn ? '$label On' : '$label Off',
              style: AppTypography.bodySmall(context).copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required String text,
    required bool isActive,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.m),
        decoration: BoxDecoration(
          gradient: isActive && isPrimary
              ? const LinearGradient(
                  colors: [
                    AppColors.accentPrimary,
                    AppColors.accentLight,
                  ],
                )
              : null,
          color: isActive && !isPrimary
              ? AppColors.accentPrimary
              : (isActive ? null : AppColors.cardBackground),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? (isPrimary ? AppColors.accentLight : AppColors.accentPrimary)
                : AppColors.cardBorder,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: AppTypography.body(context).copyWith(
              color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
              fontWeight: FontWeight.bold,
              fontSize: isPrimary ? 14 : 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

// Models
class LobbyPlayer {
  final String id;
  final String username;
  final int level;
  final bool isHost;
  final bool isReady;
  final bool isBot;
  final bool isSpeaking;

  LobbyPlayer({
    required this.id,
    required this.username,
    required this.level,
    required this.isHost,
    required this.isReady,
    required this.isBot,
    required this.isSpeaking,
  });

  LobbyPlayer copyWith({
    String? id,
    String? username,
    int? level,
    bool? isHost,
    bool? isReady,
    bool? isBot,
    bool? isSpeaking,
  }) {
    return LobbyPlayer(
      id: id ?? this.id,
      username: username ?? this.username,
      level: level ?? this.level,
      isHost: isHost ?? this.isHost,
      isReady: isReady ?? this.isReady,
      isBot: isBot ?? this.isBot,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }
}

class ChatMessage {
  final String username;
  final String message;
  final Color color;

  ChatMessage({
    required this.username,
    required this.message,
    required this.color,
  });
}
