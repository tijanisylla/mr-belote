import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/card.dart';
import 'card_component.dart';
import 'flame_table_game.dart';

/// Center trick component - renders cards in diamond pattern with animations
class CenterTrickComponent extends Component with HasGameRef<FlameTableGame> {
  final VoidCallback onTrickCollected;
  
  Map<PlayerPosition, CardComponent> _trickCards = {};
  Map<PlayerPosition, PlayingCard>? _lastTrickCards;
  bool _isAnimatingCollection = false;
  PlayerPosition? _pendingWinner;
  
  // Center position in world coordinates
  Vector2 get centerPosition => Vector2(
    gameRef.staticWorldWidth / 2,
    gameRef.staticWorldHeight / 2,
  );
  
  // Card positions in diamond pattern (offsets from center)
  static final Map<PlayerPosition, Vector2> cardOffsets = {
    PlayerPosition.north: Vector2(0, -80), // Up
    PlayerPosition.south: Vector2(0, 80),  // Down
    PlayerPosition.east: Vector2(80, 0),   // Right
    PlayerPosition.west: Vector2(-80, 0),  // Left
  };
  
  // Card angles for 3D effect (slight tilt)
  static final Map<PlayerPosition, double> cardAngles = {
    PlayerPosition.north: 0.0,
    PlayerPosition.south: 0.0,
    PlayerPosition.east: -0.05, // Slight tilt
    PlayerPosition.west: 0.05,
  };
  
  CenterTrickComponent({required this.onTrickCollected});
  
  /// Update trick cards from game state
  void updateTrickCards(
    Map<PlayerPosition, PlayingCard>? trickCards, {
    GameState? gameState,
  }) {
    if (_isAnimatingCollection) return; // Don't update while collecting
    
    final currentCards = trickCards ?? {};
    final lastCards = _lastTrickCards ?? {};
    
    // Check if trick was completed (had 4 cards, now empty)
    final hadCompleteTrick = lastCards.length == 4;
    final isNowEmpty = currentCards.isEmpty;
    
    if (hadCompleteTrick && isNowEmpty && gameState != null) {
      // Trick completed - winner is the new currentPlayer
      _pendingWinner = gameState.currentPlayer;
      _animateTrickCollection(lastCards, _pendingWinner!);
      _pendingWinner = null;
      _lastTrickCards = currentCards;
      return;
    }
    
    // Handle new cards being played
    for (final entry in currentCards.entries) {
      final position = entry.key;
      final card = entry.value;
      
      if (!lastCards.containsKey(position)) {
        // New card - animate from player position to center
        _animateCardToCenter(position, card);
      }
    }
    
    // Handle cards being removed (shouldn't happen except on clear)
    for (final position in lastCards.keys) {
      if (!currentCards.containsKey(position)) {
        // Card was removed (trick cleared) - remove component
        _trickCards[position]?.removeFromParent();
        _trickCards.remove(position);
      }
    }
    
    _lastTrickCards = Map.from(currentCards);
  }
  
  Future<void> _animateCardToCenter(PlayerPosition position, PlayingCard card) async {
    // Get start position (from player's hand area)
    final startPos = _getPlayerHandPosition(position);
    final targetPos = centerPosition + cardOffsets[position]!;
    final targetAngle = cardAngles[position] ?? 0.0;
    
    // Create card component
    final cardComponent = CardComponent(
      card: card,
      showBack: false,
      position: startPos,
      angle: 0,
    );
    await add(cardComponent);
    _trickCards[position] = cardComponent;
    
    // Animate to center (move, rotate, and scale in parallel)
    cardComponent.add(
      MoveEffect.to(
        targetPos,
        EffectController(duration: 0.5, curve: Curves.easeOutCubic),
      ),
    );
    cardComponent.add(
      RotateEffect.to(
        targetAngle,
        EffectController(duration: 0.5, curve: Curves.easeOutCubic),
      ),
    );
    cardComponent.add(
      ScaleEffect.to(
        Vector2.all(1.1),
        EffectController(
          duration: 0.25,
          curve: Curves.easeOut,
          reverseDuration: 0.25,
        ),
      ),
    );
  }
  
  Future<void> _animateTrickCollection(
    Map<PlayerPosition, PlayingCard> trickCards,
    PlayerPosition winner,
  ) async {
    if (_trickCards.isEmpty) return;
    
    _isAnimatingCollection = true;
    
    // Get collection target position
    final targetPos = _getCollectionPosition(winner);
    
    // Animate all cards to winner's position (in parallel)
    for (final cardComponent in _trickCards.values) {
      cardComponent.add(
        MoveEffect.to(
          targetPos,
          EffectController(duration: 0.6, curve: Curves.easeInCubic),
        ),
      );
      
      cardComponent.add(
        ScaleEffect.to(
          Vector2.all(0.3),
          EffectController(duration: 0.6, curve: Curves.easeInCubic),
        ),
      );
      
      cardComponent.add(
        OpacityEffect.to(
          0.0,
          EffectController(duration: 0.6, curve: Curves.easeInCubic),
        ),
      );
    }
    
    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 650));
    
    // Clear cards
    for (final card in _trickCards.values) {
      card.removeFromParent();
    }
    _trickCards.clear();
    
    // Notify callback
    onTrickCollected();
    
    _isAnimatingCollection = false;
  }
  
  Vector2 _getPlayerHandPosition(PlayerPosition position) {
    final worldWidth = gameRef.staticWorldWidth;
    final worldHeight = gameRef.staticWorldHeight;
    
    // Return approximate hand positions for animation start in world coordinates
    switch (position) {
      case PlayerPosition.north:
        return Vector2(worldWidth / 2, worldHeight * 0.1);
      case PlayerPosition.south:
        return Vector2(worldWidth / 2, worldHeight * 0.9);
      case PlayerPosition.east:
        return Vector2(worldWidth * 0.9, worldHeight / 2);
      case PlayerPosition.west:
        return Vector2(worldWidth * 0.1, worldHeight / 2);
    }
  }
  
  Vector2 _getCollectionPosition(PlayerPosition winner) {
    final worldWidth = gameRef.staticWorldWidth;
    final worldHeight = gameRef.staticWorldHeight;
    
    // Return position where collected tricks go (near winner's position) in world coordinates
    switch (winner) {
      case PlayerPosition.north:
        return Vector2(worldWidth / 2, worldHeight * 0.15);
      case PlayerPosition.south:
        return Vector2(worldWidth / 2, worldHeight * 0.85);
      case PlayerPosition.east:
        return Vector2(worldWidth * 0.85, worldHeight / 2);
      case PlayerPosition.west:
        return Vector2(worldWidth * 0.15, worldHeight / 2);
    }
  }
}
