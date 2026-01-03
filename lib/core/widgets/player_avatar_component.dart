import 'package:flame/components.dart';
import '../models/game_state.dart';

/// Player avatar component (simplified - can be enhanced later with SVG rendering)
class PlayerAvatarComponent extends Component with HasGameRef {
  final PlayerPosition position;
  bool _isActive = false;
  
  // Avatar positions in world coordinates
  static final Map<PlayerPosition, Vector2> avatarPositions = {
    PlayerPosition.north: Vector2(768, 150), // Center X, top area
    PlayerPosition.south: Vector2(768, 874), // Center X, bottom area  
    PlayerPosition.east: Vector2(1386, 512), // Right side
    PlayerPosition.west: Vector2(150, 512),  // Left side
  };
  
  PlayerAvatarComponent({required this.position});
  
  void updateActiveState(bool isActive) {
    if (_isActive != isActive) {
      _isActive = isActive;
      // Could add visual feedback here (glow effect, etc.)
    }
  }
  
  Vector2 getAvatarPosition() {
    return avatarPositions[position]!;
  }
}

