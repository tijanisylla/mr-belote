import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/game_state.dart';

/// Minimal player entity rendered in world space (avatar placeholder)
class PlayerEntityComponent extends PositionComponent {
  // store the logical player slot/enum separately to avoid colliding
  // with PositionComponent.position (which returns NotifyingVector2)
  final PlayerPosition playerPosition;

  PlayerEntityComponent({required this.playerPosition}) : super(anchor: Anchor.center) {
    // Use fixed world coordinates based on the world size 1536x1024
    switch (playerPosition) {
      case PlayerPosition.north:
        position = Vector2(1536 / 2, 1024 * 0.08);
        break;
      case PlayerPosition.east:
        position = Vector2(1536 * 0.95, 1024 / 2);
        break;
      case PlayerPosition.west:
        position = Vector2(1536 * 0.05, 1024 / 2);
        break;
      case PlayerPosition.south:
        position = Vector2(1536 / 2, 1024 * 0.92);
        break;
    }
    size = Vector2.all(64);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = Colors.deepOrange.shade400;
    canvas.drawCircle(Offset.zero, 28, paint);
  }
}
