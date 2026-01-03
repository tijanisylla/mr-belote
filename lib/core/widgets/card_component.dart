import 'package:flame/components.dart';
import '../models/card.dart';

/// Card component for Flame rendering
class CardComponent extends SpriteComponent with HasGameRef {
  PlayingCard card;
  final bool showBack;
  
  // Card dimensions (will be scaled based on context)
  static const double cardWidth = 90.0;
  static const double cardHeight = 126.0;
  
  CardComponent({
    required this.card,
    this.showBack = false,
    Vector2? position,
    double? angle,
  }) : super(
          size: Vector2(cardWidth, cardHeight),
          position: position ?? Vector2.zero(),
          angle: angle ?? 0,
          anchor: Anchor.center,
        );
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadSprite();
  }
  
  Future<void> _loadSprite() async {
    if (showBack) {
      final image = await gameRef.images.load('new-cards/back-blue.png');
      sprite = Sprite(image);
    } else {
      // Get card asset path - convert to Flame asset path format
      final assetPath = card.getAssetPath();
      // Remove 'assets/' prefix for Flame
      final flamePath = assetPath.replaceFirst('assets/', '');
      final image = await gameRef.images.load(flamePath);
      sprite = Sprite(image);
    }
  }
}

