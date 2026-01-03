import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import 'flame_table_game.dart';

/// Wrapper widget that connects Flame game with Riverpod state
class FlameGameWidgetWrapper extends ConsumerStatefulWidget {
  const FlameGameWidgetWrapper({super.key});

  @override
  ConsumerState<FlameGameWidgetWrapper> createState() => _FlameGameWidgetWrapperState();
}

class _FlameGameWidgetWrapperState extends ConsumerState<FlameGameWidgetWrapper> {
  late FlameTableGame _game;
  
  @override
  void initState() {
    super.initState();
    // Create game instance once
    _game = FlameTableGame(ref);
  }
  
  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    
    // Update game state after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _game.updateGameState(gameState);
      }
    });
    
    return GameWidget(
      game: _game,
      loadingBuilder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorBuilder: (context, error) => Center(
        child: Text(
          'Game loading error: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
