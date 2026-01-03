import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/card.dart';
import '../providers/game_provider.dart';
import 'center_trick_component.dart';
import 'deck_component.dart';
import 'player_entity_component.dart';

/// Main Flame game class for the table scene
class FlameTableGame extends FlameGame {
  // World size - set from table image
  double worldWidth = 1536.0;
  double worldHeight = 1024.0;
  bool _cameraSetup = false;
  
  final WidgetRef ref;
  GameState? _lastGameState;
  SpriteComponent? _table;
  late CenterTrickComponent _centerTrick;
  
  FlameTableGame(this.ref);
  
  @override
  Color backgroundColor() => Colors.transparent;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Load table to get world size
    await _loadTable();

    // Create a World and add it to the game. All in-game visuals
    // (table, deck, players, hands, center trick) will be children
    // of this world so a single camera transforms them together.
    final world = World();

    // Table already created in _loadTable as _table; move it into world
    if (_table != null) {
      world.add(_table!);
    }

    // Add center trick component into the world (uses world coordinates)
    _centerTrick = CenterTrickComponent(
      onTrickCollected: () {
        ref.read(gameProvider.notifier).clearCurrentTrick();
      },
    );
    world.add(_centerTrick);

    // Add simple deck placeholder component (will render in world space)
    final deck = DeckComponent();
    world.add(deck);

    // Add simple player placeholders (avatars) at fixed world positions
  world.add(PlayerEntityComponent(playerPosition: PlayerPosition.north));
  world.add(PlayerEntityComponent(playerPosition: PlayerPosition.east));
  world.add(PlayerEntityComponent(playerPosition: PlayerPosition.west));
  world.add(PlayerEntityComponent(playerPosition: PlayerPosition.south));

    add(world);

    // Update from current game state once loaded
    _updateFromGameState(ref.read(gameProvider));
  }
  
  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    // Setup camera when we have screen size
    _setupCamera();
  }
  
  void _setupCamera() {
    // Need both screen size and world size
    if (size.x == 0 || size.y == 0 || worldWidth == 0 || worldHeight == 0) {
      return;
    }
    
    // If camera already configured, avoid re-applying settings.
    // Previous code attempted to read `camera.viewfinder.visibleWorldSize`,
    // which isn't available on the current Flame Viewfinder API; keep the
    // guard simple to avoid calling an unknown getter.
    if (_cameraSetup) {
      return; // Already set up correctly
    }
    
      // CONTAIN scale: min(screenW/worldW, screenH/worldH)
      // Use contain so the whole table fits on screen (no cropping), then
      // apply an extra zoom-out factor so the scene looks smaller/less 'big'.
      final scaleX = size.x / worldWidth;
      final scaleY = size.y / worldHeight;
      final containScale = scaleX < scaleY ? scaleX : scaleY;

    // Apply a slight zoom OUT relative to the cover scale so the scene
    // feels more 'zoomed out'. Use a factor slightly less than 1.0.
    // This preserves the fill behaviour while pulling the camera back.
      // Reduce zoom more aggressively; this keeps the full table visible
      // while making the whole scene feel pulled back.
      const zoomOutFactor = 0.62; // more zoomed out than before
      camera.viewfinder.zoom = containScale * zoomOutFactor;
    camera.viewfinder.anchor = Anchor.center;

    // Position the camera at the world center but shift it upward
    // (negative Y) so the north area appears farther and the table
    // feels vertically expanded. We keep the table centered in X.
    // Use a fraction of the worldHeight so this adapts to different
    // table images without changing widget coordinates.
      // Adjust vertical offset so the north area reads as farther away.
      // Slightly smaller than before because we're using contain scale.
      final verticalOffset = worldHeight * 0.14; // tuned to balance composition
    camera.viewfinder.position = Vector2(
      worldWidth / 2,
      worldHeight / 2 - verticalOffset,
    );

    // Subtle tilt illusion: we can't do real 3D, but a tiny additional
    // upward nudge and slightly reduced zoom gives the perception that
    // the south side is closer. Avoid non-uniform scaling to prevent
    // visible distortion.
    // (No transform matrix changes here — keep the visual geometry clean.)
    
    _cameraSetup = true;
    
  print('Camera setup: screen=${size.x}x${size.y}, world=${worldWidth}x${worldHeight}, zoom=${containScale * zoomOutFactor}');
  }
  
  Future<void> _loadTable() async {
    try {
      final image = await images.load('new_table_game_bg.png');
      worldWidth = image.width.toDouble();
      worldHeight = image.height.toDouble();
      
      print('Table loaded: ${worldWidth}x${worldHeight}');
      
      // Table at full size, centered
      _table = SpriteComponent(
        sprite: Sprite(image),
        size: Vector2(worldWidth, worldHeight),
        position: Vector2(worldWidth / 2, worldHeight / 2),
        anchor: Anchor.center,
      );
      
      add(_table!);
      
      // Try to setup camera if size is already available
      _setupCamera();
    } catch (e) {
      print('Error loading table: $e');
    }
  }
  
  void updateGameState(GameState? gameState) {
    if (gameState == null) return;
    if (_lastGameState != gameState) {
      _lastGameState = gameState;
      _updateFromGameState(gameState);
    }
  }
  
  void _updateFromGameState(GameState? gameState) {
    if (!isLoaded || gameState == null) return;
    _centerTrick.updateTrickCards(
      gameState.currentTrickCards,
      gameState: gameState,
    );
  }
  
  double get staticWorldWidth => worldWidth;
  double get staticWorldHeight => worldHeight;
}
