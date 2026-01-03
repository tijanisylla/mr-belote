import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/playing_card_widget.dart';
import '../../../core/widgets/player_avatar_3d.dart';
import '../../../core/models/card.dart';
import '../../../core/models/game_state.dart';
import '../../../core/providers/game_provider.dart';
import '../../../core/widgets/flame_game_widget_wrapper.dart';
import '../widgets/hand_fan.dart';
import '../widgets/deck_stack.dart';
import '../widgets/center_trick_display.dart';
import '../widgets/won_tricks_pile.dart';

/// Belote Layout Configuration
/// All layout constants in one place to avoid magic numbers
class BeloteLayoutConfig {
  // === PLAYER AVATAR POSITIONS ===
  static const double northAvatarY = 0.08;
  static const double sideAvatarY = 0.42;
  static const double eastAvatarX = 0.95;
  static const double westAvatarX = 0.05;
  static const double avatarSize = 65.0;
  
  // === OPPONENT HAND POSITIONS ===
  // Hands must be OUTSIDE the oval table
  static const double northHandY = 0.01;  // Above oval, outside table
  static const double eastHandY = 0.40;   // Right side, just outside oval edge
  static const double westHandY = 0.40;   // Left side, just outside oval edge
  static const double eastHandX = 0.98;    // Just outside right oval edge
  static const double westHandX = 0.02;    // Just outside left oval edge
  
  // === NORTH HAND PERSPECTIVE ===
  static const double northHandTiltX = -0.15;  // 3D tilt toward camera (facing user)
  
  // === CENTER TRICK (PLAYED CARDS) ===
  // MUST be in the CENTER of the rounded table
  static const double trickCenterY = 0.50;  // Dead center vertically
  static const double trickCenterX = 0.50;   // Dead center horizontally
  static const double centerTrickCardWidth = 75.0;  // Slightly larger for visibility
  static const double centerTrickCardHeight = 105.0; // Slightly larger for visibility
  
  // === SOUTH HAND (PLAYER) ===
  // MUST be OUTSIDE the oval, below it
  static const double southHandBottomOffset = 10.0;   // Raised up more (positive value)
  static const double southHandVisibleRatio = 0.80;   // Show top 80% (more visible)
  static const double southCardWidth = 90.0;
  static const double southCardHeight = 126.0;
  static const double southCardOverlap = 52.0;
  static const double southMaxRotation = 5.0;
  static const double southGroupTiltX = -0.12;  // 3D perspective toward camera
  
  // === OPPONENT CARDS ===
  static const double opponentCardWidth = 30.0;
  static const double opponentCardHeight = 42.0;
  static const double opponentCardOverlap = 18.0;
  static const double opponentMaxRotation = 5.0;
  static const int maxOpponentCardsDisplay = 8;
  
  // === DECK STACK ===
  static const double deckY = 0.38;
  static const double deckX = 0.68;
  static const double deckWidth = 50.0;
  static const double deckHeight = 70.0;
  static const int deckCardCount = 12;
  static const double deckOffsetX = 1.4;
  static const double deckOffsetY = 1.6;
  
  // === UI ELEMENTS ===
  static const double scoreboardTop = 20.0;
  static const double scoreboardLeft = 20.0;
  static const double topRightIconsTop = 20.0;
  static const double topRightIconsRight = 20.0;
  static const double spectatorCountBottom = 20.0;
  static const double spectatorCountRight = 20.0;
}

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  PlayingCard? _selectedCard;
  PlayerPosition? _dealer = PlayerPosition.north;

  // Mock player data
  final Map<PlayerPosition, Map<String, dynamic>> _players = {
    PlayerPosition.north: {
      'name': 'Ahmed',
      'avatar': 'assets/avatars/adventurer-1766914879909.svg',
      'isMuted': false,
    },
    PlayerPosition.east: {
      'name': 'Fatin',
      'avatar': 'assets/avatars/adventurer-1766914898179.svg',
      'isMuted': true,
    },
    PlayerPosition.west: {
      'name': 'Tijani',
      'avatar': 'assets/avatars/adventurer-1766914883742.svg',
      'isMuted': false,
    },
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).startNewGame();
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    if (gameState == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final playerHand = gameState.hands[PlayerPosition.south] ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
        body: Stack(
          children: [
          // Table Background Image
          _buildTable(),

          // Scoreboard (Top Left) - "Us 0 Them 0"
          _buildScoreboard(gameState),

          // Top Right Icons (Settings, Mic, Volume, Exit)
          _buildTopRightIcons(),

          // Bottom Right Spectator Count
          _buildSpectatorCount(),
          // All in-game visuals (avatars, hands, deck, center trick)
          // have been moved into the Flame world. We keep only HUD
          // overlays here so they remain fixed on screen and are
          // unaffected by camera transforms.
        ],
        ),
      );
    }

  Widget _buildTable() {
    // Background and table are now handled by Flame - no duplication
    return const Positioned.fill(
      child: FlameGameWidgetWrapper(),
    );
  }

  Widget _buildScoreboard(GameState gameState) {
    return Positioned(
      top: BeloteLayoutConfig.scoreboardTop,
      left: BeloteLayoutConfig.scoreboardLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
                Flexible(
                  child: Text(
                    'Us ',
                    style: AppTypography.body(context).copyWith(
                      color: Colors.green,
              fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    '${gameState.scores[Team.team1] ?? 0} ',
                    style: AppTypography.body(context).copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    'Them ',
                    style: AppTypography.body(context).copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    '${gameState.scores[Team.team2] ?? 0}',
                    style: AppTypography.body(context).copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Phase indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
              color: _getPhaseColor(gameState.phase),
              borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
              _getPhaseText(gameState.phase),
              style: AppTypography.body(context).copyWith(
                color: Colors.white,
                fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
        ],
      ),
    );
  }

  Color _getPhaseColor(GamePhase phase) {
    switch (phase) {
      case GamePhase.biddingRound1:
      case GamePhase.biddingRound2:
        return Colors.orange.withOpacity(0.8);
      case GamePhase.playing:
        return Colors.green.withOpacity(0.8);
      case GamePhase.scoring:
        return Colors.blue.withOpacity(0.8);
      default:
        return Colors.grey.withOpacity(0.8);
    }
  }

  String _getPhaseText(GamePhase phase) {
    switch (phase) {
      case GamePhase.initialDeal:
        return 'Dealing...';
      case GamePhase.biddingRound1:
        return 'Bidding R1';
      case GamePhase.biddingRound2:
        return 'Bidding R2';
      case GamePhase.finalDeal:
        return 'Final Deal';
      case GamePhase.playing:
        return 'Playing';
      case GamePhase.scoring:
        return 'Scoring';
      case GamePhase.finished:
        return 'Game Over';
    }
  }

  Widget _buildTopRightIcons() {
    final gameState = ref.watch(gameProvider);
    
    return Positioned(
      top: BeloteLayoutConfig.topRightIconsTop,
      right: BeloteLayoutConfig.topRightIconsRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
          // Test button - always visible for testing
          _buildIconButton(Icons.fast_forward, () {
            final currentPhase = gameState?.phase;
            if (currentPhase == GamePhase.biddingRound1) {
              // Skip bidding
              ref.read(gameProvider.notifier).makeBidRound1(true);
            } else if (currentPhase == GamePhase.playing) {
              // Start new game to test again
              ref.read(gameProvider.notifier).startNewGame();
              // Auto-skip bidding after a brief delay
              Future.delayed(const Duration(milliseconds: 500), () {
                if (ref.read(gameProvider)?.phase == GamePhase.biddingRound1) {
                  ref.read(gameProvider.notifier).makeBidRound1(true);
                }
              });
            }
          }, backgroundColor: Colors.orange),
          const SizedBox(width: 12),
          _buildIconButton(Icons.settings, () {}),
          const SizedBox(width: 12),
          _buildIconButton(Icons.mic, () {}),
          const SizedBox(width: 12),
          _buildIconButton(Icons.volume_up, () {}),
          const SizedBox(width: 12),
          _buildIconButton(Icons.exit_to_app, () {
            if (context.canPop()) {
              context.pop();
            }
          }),
            ],
          ),
        );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, {Color? backgroundColor}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
        width: 40,
        height: 40,
          decoration: BoxDecoration(
          color: backgroundColor?.withOpacity(0.8) ?? Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSpectatorCount() {
    return Positioned(
      bottom: BeloteLayoutConfig.spectatorCountBottom,
      right: BeloteLayoutConfig.spectatorCountRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
            const Icon(
                Icons.remove_red_eye,
              color: Colors.white,
              size: 16,
              ),
            const SizedBox(width: 6),
              Text(
              '5',
              style: AppTypography.body(context).copyWith(
                  color: Colors.white,
                fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
  }

  /// Determine trick winner based on Belote rules
  PlayerPosition? _getTrickWinner(GameState gameState) {
    final trickCards = gameState.currentTrickCards;
    if (trickCards == null || trickCards.length != 4) {
      return null; // Trick not complete
    }

    final trumpSuit = gameState.trumpSuit;
    if (trumpSuit == null) {
      return null; // No trump declared yet
    }

    // Get the first card played (leader determines suit to follow)
    final leader = _getTrickLeader(gameState);
    final leadCard = trickCards[leader]!;
    final leadSuit = leadCard.suit;

    PlayerPosition? winner = leader;
    PlayingCard winningCard = leadCard;

    // Check each subsequent card
    for (final entry in trickCards.entries) {
      if (entry.key == leader) continue;

      final currentCard = entry.value;
      
      // Compare cards using Belote rules
      if (_isCardStronger(currentCard, winningCard, leadSuit, trumpSuit)) {
        winner = entry.key;
        winningCard = currentCard;
      }
    }

    return winner;
  }

  /// Get the player who led this trick (first to play)
  PlayerPosition _getTrickLeader(GameState gameState) {
    // In Belote, the leader is typically tracked, but we can infer from current player
    // For now, assume it's the player before current player (simplified)
    // In production, this should be tracked in GameState
    final positions = PlayerPosition.values;
    final currentIndex = positions.indexOf(gameState.currentPlayer);
    final leaderIndex = (currentIndex - gameState.currentTrickCards!.length) % 4;
    return positions[leaderIndex < 0 ? leaderIndex + 4 : leaderIndex];
  }

  /// Check if card1 beats card2 based on Belote rules
  bool _isCardStronger(
    PlayingCard card1,
    PlayingCard card2,
    Suit leadSuit,
    Suit trumpSuit,
  ) {
    final isTrump1 = card1.suit == trumpSuit;
    final isTrump2 = card2.suit == trumpSuit;

    // Trump always beats non-trump
    if (isTrump1 && !isTrump2) return true;
    if (!isTrump1 && isTrump2) return false;

    // Both trump: compare trump rankings
    if (isTrump1 && isTrump2) {
      return _getTrumpValue(card1.rank) > _getTrumpValue(card2.rank);
    }

    // Both non-trump: only cards of lead suit can win
    if (card1.suit != leadSuit) return false; // Can't win if not following suit
    if (card2.suit != leadSuit) return true;  // Wins if opponent didn't follow suit

    // Both same suit (lead suit): compare normal rankings
    return _getNormalValue(card1.rank) > _getNormalValue(card2.rank);
  }

  /// Trump ranking (Jack highest)
  int _getTrumpValue(Rank rank) {
    switch (rank) {
      case Rank.jack:
        return 8; // Highest
      case Rank.nine:
        return 7;
      case Rank.ace:
        return 6;
      case Rank.ten:
        return 5;
      case Rank.king:
        return 4;
      case Rank.queen:
        return 3;
      case Rank.eight:
        return 2;
      case Rank.seven:
        return 1; // Lowest
    }
  }

  /// Normal ranking (Ace highest)
  int _getNormalValue(Rank rank) {
    switch (rank) {
      case Rank.ace:
        return 7; // Highest
      case Rank.ten:
        return 6;
      case Rank.king:
        return 5;
      case Rank.queen:
        return 4;
      case Rank.jack:
        return 3;
      case Rank.nine:
        return 2;
      case Rank.eight:
        return 1;
      case Rank.seven:
        return 0; // Lowest
    }
  }

  /// Get number of tricks won by a team
  int _getTeamTricksWon(GameState gameState, Team team) {
    return gameState.tricks.where((trick) => trick.winner == team).length;
  }

  /// Check if team just won the current trick (for highlighting)
  bool _isTeamActive(GameState gameState, Team team) {
    if (gameState.currentTrickCards == null || gameState.currentTrickCards!.length != 4) {
      return false;
    }
    final winner = _getTrickWinner(gameState);
    if (winner == null) return false;
    
    // Determine which team the winner belongs to
    final winnerTeam = (winner == PlayerPosition.north || winner == PlayerPosition.south)
        ? Team.team1
        : Team.team2;
    
    return winnerTeam == team;
  }
}

/// Card suit background painter for playful pattern (HD quality)
class _CardSuitBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true; // HD smooth rendering

    // Draw MANY more card suit patterns scattered across background
    final suitSize = 45.0;
    final spacing = 100.0; // Denser pattern (was 150)
    
    // Create a rich, dense pattern with multiple layers
    // Layer 1: Main grid
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        final offset = ((x + y) / spacing) % 8; // More variety
        
        if (offset < 1) {
          // Hearts - red
          paint.color = const Color(0xFFD32F2F).withOpacity(0.12);
          _drawHeart(canvas, Offset(x, y), suitSize, paint);
        } else if (offset < 2) {
          // Diamonds - red
          paint.color = const Color(0xFFE53935).withOpacity(0.12);
          _drawDiamond(canvas, Offset(x + spacing * 0.5, y + spacing * 0.3), suitSize * 0.8, paint);
        } else if (offset < 3) {
          // Spades - white
          paint.color = Colors.white.withOpacity(0.08);
          _drawSpade(canvas, Offset(x + spacing * 0.3, y + spacing * 0.6), suitSize, paint);
        } else if (offset < 4) {
          // Clubs - white
          paint.color = Colors.white.withOpacity(0.08);
          _drawClub(canvas, Offset(x + spacing * 0.7, y + spacing * 0.2), suitSize * 0.9, paint);
        } else if (offset < 5) {
          // More Hearts
          paint.color = const Color(0xFFC62828).withOpacity(0.10);
          _drawHeart(canvas, Offset(x + spacing * 0.2, y + spacing * 0.8), suitSize * 0.7, paint);
        } else if (offset < 6) {
          // More Diamonds
          paint.color = const Color(0xFFEF5350).withOpacity(0.10);
          _drawDiamond(canvas, Offset(x + spacing * 0.8, y + spacing * 0.5), suitSize * 0.6, paint);
        } else if (offset < 7) {
          // More Spades
          paint.color = Colors.white.withOpacity(0.06);
          _drawSpade(canvas, Offset(x + spacing * 0.4, y + spacing * 0.1), suitSize * 0.8, paint);
        } else {
          // More Clubs
          paint.color = Colors.white.withOpacity(0.06);
          _drawClub(canvas, Offset(x + spacing * 0.1, y + spacing * 0.4), suitSize * 0.85, paint);
        }
      }
    }
    
    // Layer 2: Offset grid for even more density
    for (double x = -spacing + spacing * 0.5; x < size.width + spacing; x += spacing) {
      for (double y = -spacing + spacing * 0.5; y < size.height + spacing; y += spacing) {
        final offset = ((x + y) / spacing) % 4;
        
        if (offset < 1) {
          paint.color = const Color(0xFFD32F2F).withOpacity(0.08);
          _drawDiamond(canvas, Offset(x, y), suitSize * 0.6, paint);
        } else if (offset < 2) {
          paint.color = Colors.white.withOpacity(0.05);
          _drawClub(canvas, Offset(x + spacing * 0.3, y), suitSize * 0.7, paint);
        } else if (offset < 3) {
          paint.color = const Color(0xFFE53935).withOpacity(0.08);
          _drawHeart(canvas, Offset(x, y + spacing * 0.3), suitSize * 0.65, paint);
        } else {
          paint.color = Colors.white.withOpacity(0.05);
          _drawSpade(canvas, Offset(x + spacing * 0.2, y + spacing * 0.2), suitSize * 0.75, paint);
        }
      }
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.3);
    
    // Left curve
    path.cubicTo(
      center.dx - size * 0.5, center.dy - size * 0.1,
      center.dx - size * 0.5, center.dy - size * 0.5,
      center.dx, center.dy - size * 0.3,
    );
    
    // Right curve
    path.cubicTo(
      center.dx + size * 0.5, center.dy - size * 0.5,
      center.dx + size * 0.5, center.dy - size * 0.1,
      center.dx, center.dy + size * 0.3,
    );
    
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size * 0.5); // Top
    path.lineTo(center.dx + size * 0.4, center.dy); // Right
    path.lineTo(center.dx, center.dy + size * 0.5); // Bottom
    path.lineTo(center.dx - size * 0.4, center.dy); // Left
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawSpade(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    
    // Main spade shape (inverted heart)
    path.moveTo(center.dx, center.dy - size * 0.4);
    
    // Left curve
    path.cubicTo(
      center.dx - size * 0.5, center.dy - size * 0.1,
      center.dx - size * 0.5, center.dy + size * 0.2,
      center.dx, center.dy + size * 0.1,
    );
    
    // Right curve
    path.cubicTo(
      center.dx + size * 0.5, center.dy + size * 0.2,
      center.dx + size * 0.5, center.dy - size * 0.1,
      center.dx, center.dy - size * 0.4,
    );
    
    path.close();
    canvas.drawPath(path, paint);
    
    // Stem
    final stemRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size * 0.3),
        width: size * 0.2,
        height: size * 0.3,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(stemRect, paint);
  }

  void _drawClub(Canvas canvas, Offset center, double size, Paint paint) {
    // Three circles forming a clover
    canvas.drawCircle(Offset(center.dx, center.dy - size * 0.2), size * 0.2, paint);
    canvas.drawCircle(Offset(center.dx - size * 0.25, center.dy + size * 0.1), size * 0.2, paint);
    canvas.drawCircle(Offset(center.dx + size * 0.25, center.dy + size * 0.1), size * 0.2, paint);
    
    // Stem
    final stemRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size * 0.35),
        width: size * 0.15,
        height: size * 0.25,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(stemRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
