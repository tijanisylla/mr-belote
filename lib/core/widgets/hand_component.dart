import 'package:flame/components.dart';
import '../models/card.dart';
import '../models/game_state.dart';
import 'card_component.dart';
import 'flame_table_game.dart';

/// Hand component - renders player's hand
class HandComponent extends Component with HasGameRef {
  final PlayerPosition position;
  List<PlayingCard> _cards = [];
  
  // Hand positions in world coordinates
  static final Map<PlayerPosition, Vector2> handPositions = {
    PlayerPosition.north: Vector2(FlameTableGame.worldWidth / 2, 120),
    PlayerPosition.south: Vector2(FlameTableGame.worldWidth / 2, FlameTableGame.worldHeight - 120),
    PlayerPosition.east: Vector2(FlameTableGame.worldWidth - 120, FlameTableGame.worldHeight / 2),
    PlayerPosition.west: Vector2(120, FlameTableGame.worldHeight / 2),
  };
  
  HandComponent({required this.position});
  
  void updateHand(List<PlayingCard> cards) {
    if (_cards.length == cards.length && _cards == cards) {
      return; // No change
    }
    
    _cards = cards;
    _renderHand();
  }
  
  Future<void> _renderHand() async {
    // Remove old card components
    children.whereType<CardComponent>().forEach((card) {
      card.removeFromParent();
    });
    
    if (_cards.isEmpty) return;
    
    // For opponents, show card backs in a fan
    final showBack = position != PlayerPosition.south;
    final cardCount = _cards.length;
    
    // Calculate card positions in a fan
    final basePosition = handPositions[position]!;
    final overlap = showBack ? 18.0 : 52.0; // Smaller overlap for opponents
    
    for (int i = 0; i < cardCount; i++) {
      final card = _cards[i];
      final offsetX = showBack 
          ? (i - cardCount / 2) * (CardComponent.cardWidth - overlap)
          : (i - cardCount / 2) * (CardComponent.cardWidth - overlap);
      final offsetY = showBack ? 0.0 : 0.0; // No vertical offset for fan
      
      final cardPosition = basePosition + Vector2(offsetX, offsetY);
      final cardComponent = CardComponent(
        card: card,
        showBack: showBack,
        position: cardPosition,
      );
      
      await add(cardComponent);
    }
  }
  
  Vector2 getHandPosition() {
    return handPositions[position]!;
  }
}

