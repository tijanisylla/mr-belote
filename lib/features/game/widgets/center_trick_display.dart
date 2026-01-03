import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/models/card.dart';
import '../../../core/models/game_state.dart';
import '../../../core/widgets/playing_card_widget.dart';

/// Premium Belote card animation display with realistic physics
/// Handles: play animation, diamond layout, trick completion, winner fly-away
class CenterTrickDisplay extends StatefulWidget {
  final Map<PlayerPosition, PlayingCard> trickCards;
  final double cardWidth;
  final double cardHeight;
  final Size screenSize;
  final PlayerPosition? trickWinner; // Who won this trick
  final VoidCallback? onTrickCollected; // Called when trick animation completes
  final Suit? trumpSuit; // For winner determination

  const CenterTrickDisplay({
    super.key,
    required this.trickCards,
    required this.screenSize,
    this.cardWidth = 70.0,
    this.cardHeight = 98.0,
    this.trickWinner,
    this.onTrickCollected,
    this.trumpSuit,
  });

  @override
  State<CenterTrickDisplay> createState() => _CenterTrickDisplayState();
}

class _CenterTrickDisplayState extends State<CenterTrickDisplay>
    with TickerProviderStateMixin {
  // Individual card animations (play animation)
  final Map<PlayerPosition, AnimationController> _playControllers = {};
  final Map<PlayerPosition, Animation<Offset>> _offsetAnimations = {};
  final Map<PlayerPosition, Animation<double>> _scaleAnimations = {};
  final Map<PlayerPosition, Animation<double>> _rotationAnimations = {};
  final Map<PlayerPosition, Animation<double>> _shadowIntensityAnimations = {};
  
  // Trick completion animation (collect and fly to winner)
  AnimationController? _collectController;
  Animation<double>? _collectStackAnimation;
  Animation<Offset>? _collectFlyAnimation;
  Animation<double>? _collectFadeAnimation;
  
  Set<PlayerPosition> _previousPositions = {};
  bool _isCollecting = false;

  @override
  void initState() {
    super.initState();
    _initPlayAnimations();
  }

  @override
  void didUpdateWidget(CenterTrickDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // New card played - animate it
    for (final position in widget.trickCards.keys) {
      if (!_previousPositions.contains(position)) {
        print('🎴 Animating card from $position');
        _playControllers[position]?.reset();
        _playControllers[position]?.forward();
      }
    }
    
    // Trick completed (4 cards) and winner declared
    if (widget.trickCards.length == 4 && 
        widget.trickWinner != null && 
        !_isCollecting) {
      print('🏆 Trick complete! Winner: ${widget.trickWinner}');
      // Delay slightly to let last card settle
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_isCollecting) {
          _startTrickCollectionAnimation();
        }
      });
    }
    
    // Trick was cleared (start fresh)
    if (widget.trickCards.isEmpty && _previousPositions.isNotEmpty) {
      print('🔄 Trick cleared, resetting animations');
      _resetAllAnimations();
    }
    
    _previousPositions = widget.trickCards.keys.toSet();
  }

  void _initPlayAnimations() {
    for (final position in PlayerPosition.values) {
      // Play animation: 450ms with easeOutCubic
      final controller = AnimationController(
        duration: const Duration(milliseconds: 450),
        vsync: this,
      );

      _playControllers[position] = controller;

      // Offset: from player position to diamond slot
      _offsetAnimations[position] = Tween<Offset>(
        begin: _getPlayerHandPosition(position),
        end: _getDiamondSlotOffset(position),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ));

      // Scale: slight scale up during flight, settle to 1.0
      _scaleAnimations[position] = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.15)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 40,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.15, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 60,
        ),
      ]).animate(controller);

      // Rotation: starts with tilt, settles to final rotation
      _rotationAnimations[position] = Tween<double>(
        begin: _getStartRotation(position),
        end: _getFinalRotation(position),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ));

      // Shadow intensity: increases during flight, softens on land
      _shadowIntensityAnimations[position] = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.3, end: 0.8),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.8, end: 0.6),
          weight: 50,
        ),
      ]).animate(controller);
    }

    // Pre-animate existing cards
    for (final position in widget.trickCards.keys) {
      _playControllers[position]?.value = 1.0;
    }
    _previousPositions = widget.trickCards.keys.toSet();
  }

  void _startTrickCollectionAnimation() {
    if (_isCollecting) return;
    setState(() {
      _isCollecting = true;
    });

    // Longer animation: 800ms total
    // Phase 1: Brief pause (200ms)
    // Phase 2: Stack cards (200ms)
    // Phase 3: Fly to winner (400ms)
    _collectController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Stack: cards converge to center
    _collectStackAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _collectController!,
      curve: const Interval(0.25, 0.50, curve: Curves.easeInOut),
    ));

    // Fly: move stack to winner's direction (further distance)
    _collectFlyAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: _getWinnerFlyOffset(widget.trickWinner!),
    ).animate(CurvedAnimation(
      parent: _collectController!,
      curve: const Interval(0.50, 1.0, curve: Curves.easeInCubic),
    ));

    // Fade: fade out as it reaches destination
    _collectFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _collectController!,
      curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
    ));

    _collectController!.forward().then((_) {
      // Animation complete, notify parent
      widget.onTrickCollected?.call();
      setState(() {
        _isCollecting = false;
      });
    });
  }

  void _resetAllAnimations() {
    for (final controller in _playControllers.values) {
      controller.reset();
    }
    _collectController?.dispose();
    _collectController = null;
    setState(() {
      _isCollecting = false;
    });
  }

  @override
  void dispose() {
    for (final controller in _playControllers.values) {
      controller.dispose();
    }
    _collectController?.dispose();
    super.dispose();
  }

  /// Get player's hand position in screen coordinates (relative to center trick area)
  Offset _getPlayerHandPosition(PlayerPosition position) {
    final screenW = widget.screenSize.width;
    final screenH = widget.screenSize.height;
    
    switch (position) {
      case PlayerPosition.north:
        return Offset(0, -screenH * 0.4); // From top
      case PlayerPosition.south:
        return Offset(0, screenH * 0.35);  // From bottom
      case PlayerPosition.east:
        return Offset(screenW * 0.35, 0);  // From right
      case PlayerPosition.west:
        return Offset(-screenW * 0.35, 0); // From left
    }
  }

  /// Get diamond slot position (where card settles in the center)
  Offset _getDiamondSlotOffset(PlayerPosition position) {
    switch (position) {
      case PlayerPosition.north:
        return const Offset(0, -45);  // Top of diamond
      case PlayerPosition.south:
        return const Offset(0, 45);   // Bottom of diamond
      case PlayerPosition.east:
        return const Offset(50, 0);   // Right of diamond
      case PlayerPosition.west:
        return const Offset(-50, 0);  // Left of diamond
    }
  }

  /// Starting rotation for card entering animation
  double _getStartRotation(PlayerPosition position) {
    switch (position) {
      case PlayerPosition.north:
        return 0.3;  // Tilt right
      case PlayerPosition.south:
        return -0.2; // Tilt left
      case PlayerPosition.east:
        return 0.25;
      case PlayerPosition.west:
        return -0.25;
    }
  }

  /// Final settled rotation (subtle for realism)
  double _getFinalRotation(PlayerPosition position) {
    switch (position) {
      case PlayerPosition.north:
        return -0.05;
      case PlayerPosition.south:
        return 0.07;
      case PlayerPosition.east:
        return 0.12;
      case PlayerPosition.west:
        return -0.10;
    }
  }

  /// Where the card stack flies when trick is won
  Offset _getWinnerFlyOffset(PlayerPosition winner) {
    final distance = 300.0; // Increased distance for more visible animation
    switch (winner) {
      case PlayerPosition.north:
        return Offset(0, -distance); // Fly up toward north player
      case PlayerPosition.south:
        return Offset(0, distance);  // Fly down toward south player (you)
      case PlayerPosition.east:
        return Offset(distance, 0);  // Fly right toward east player
      case PlayerPosition.west:
        return Offset(-distance, 0); // Fly left toward west player
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trickCards.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: widget.cardWidth * 3,
      height: widget.cardHeight * 3,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: widget.trickCards.entries.map((entry) {
          return _buildAnimatedCard(entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  Widget _buildAnimatedCard(PlayerPosition position, PlayingCard card) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _playControllers[position]!,
        if (_collectController != null) _collectController!,
      ]),
      builder: (context, child) {
        // Play animation values
        final offsetValue = _offsetAnimations[position]!.value;
        final scaleValue = _scaleAnimations[position]!.value;
        final rotationValue = _rotationAnimations[position]!.value;
        final shadowIntensity = _shadowIntensityAnimations[position]!.value;

        // Collection animation values (if active)
        final collectStack = _collectStackAnimation?.value ?? 0.0;
        final collectFly = _collectFlyAnimation?.value ?? Offset.zero;
        final collectFade = _collectFadeAnimation?.value ?? 1.0;

        // Combine offsets: play position + collection convergence + fly
        final stackConverge = Offset.lerp(
          offsetValue,
          Offset.zero, // All cards converge to center during collection
          collectStack,
        )!;
        final finalOffset = stackConverge + collectFly;

        // Stacking effect: slight Z-index based on position
        final zOffset = _getZOffset(position);

        return Transform.translate(
          offset: finalOffset,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0018) // 3D perspective
              ..translate(0.0, 0.0, zOffset)
              ..scale(scaleValue * (1.0 - collectStack * 0.1)) // Slight scale down during stack
              ..rotateX(-0.55) // Lying on table
              ..rotateZ(rotationValue),
            child: Opacity(
              opacity: collectFade,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    // Dynamic shadow based on animation
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5 * shadowIntensity * collectFade),
                      blurRadius: 15 + (shadowIntensity * 10),
                      spreadRadius: 1,
                      offset: Offset(0, 8 + (shadowIntensity * 8)),
                    ),
                    // Soft secondary shadow
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2 * shadowIntensity * collectFade),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: widget.cardWidth,
                  height: widget.cardHeight,
                  child: PlayingCardWidget(
                    card: card,
                    size: CardSize.medium,
                    showBack: false,
                    isPlayable: false,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Z-offset for stacking effect (cards slightly offset in 3D space)
  double _getZOffset(PlayerPosition position) {
    switch (position) {
      case PlayerPosition.north:
        return 3.0;
      case PlayerPosition.south:
        return 2.0;
      case PlayerPosition.east:
        return 1.0;
      case PlayerPosition.west:
        return 0.0;
    }
  }
}
