import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Simple Deck placeholder component rendered in world space
class DeckComponent extends PositionComponent {
  DeckComponent() : super(size: Vector2(60, 80), anchor: Anchor.center) {
    position = Vector2(1536 * 0.68, 1024 * 0.38); // use fixed world positions
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = Colors.blueGrey.shade700;
    final rect = size.toRect();
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(6)), paint);
  }
}
