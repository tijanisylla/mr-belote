import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

import '../../../core/models/card.dart';
import '../../../core/widgets/playing_card_widget.dart';

/// One animated card traveling from [from] -> [to] with a mid-flight flip.
///
/// Flip behavior (spec):
/// - for t < 0.5: always show back
/// - for t >= 0.5: show front only if [faceUp] == true, otherwise keep back
class AnimatedCardActor extends StatelessWidget {
  final PlayingCard card;
  final bool faceUp;
  final Offset from;
  final Offset to;
  final double width;
  final double height;
  final Animation<double> t;

  /// Optional custom builder if you don't want to use [PlayingCardWidget].
  /// The bool is whether the front should be shown.
  final Widget Function(bool showFront)? builder;

  const AnimatedCardActor({
    super.key,
    required this.card,
    required this.faceUp,
    required this.from,
    required this.to,
    required this.width,
    required this.height,
    required this.t,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: t,
      builder: (context, _) {
        final tt = t.value.clamp(0.0, 1.0);

        // Seeded randomness for slight path/rotation variation (deterministic per card).
        final rand = math.Random(card.hashCode);
        final lateral = (rand.nextDouble() - 0.5) * 28.0; // +/-14 px sideways
        final arcHeight = 32.0 + rand.nextDouble() * 18.0; // upward arc

        // Quadratic bezier for a natural arc.
        final control = Offset(
          (from.dx + to.dx) / 2 + lateral,
          math.min(from.dy, to.dy) - arcHeight,
        );
        double bezierLerp(double a, double b, double c, double t) {
          final mt = 1 - t;
          return mt * mt * a + 2 * mt * t * b + t * t * c;
        }
        final eased = Curves.easeInOut.transform(tt);
        final bx = bezierLerp(from.dx, control.dx, to.dx, eased);
        final by = bezierLerp(from.dy, control.dy, to.dy, eased);

        // Add a subtle spring settle toward the end.
        final settleT = Curves.easeOutBack.transform(tt);
        final settleDy = lerpDouble(10, 0, settleT)!;

        // Slight Z rotation during flight for life
        final zRot = lerpDouble(-0.12, 0.08, Curves.easeOut.transform(tt))!;

        // Flip around Y axis (true 3D flip)
        final flipT = Curves.easeInOut.transform(tt);
        final yRot = lerpDouble(0.0, math.pi, flipT)!;

        // True 3D flip visibility: angle < pi/2 show BACK, >= pi/2 show FRONT (only if faceUp)
        final isFirstHalf = yRot < math.pi / 2;
        final showBack = isFirstHalf || !faceUp;

        // ✅ CRITICAL: correct the rotation for the front half to avoid mirroring
        final yRotFixed = showBack ? yRot : (yRot - math.pi);

        // Small scale-in
        final scale = lerpDouble(0.92, 1.0, Curves.easeOutBack.transform(tt))!;

        // If the card is face-up, give it a subtle "toward player" tilt.
        final xTilt = faceUp ? -0.10 : 0.0;

        final cardWidget = builder != null
            ? builder!(!showBack)
            : PlayingCardWidget(
                card: card,
                size: CardSize.large,
                isPlayable: false,
                showBack: showBack,
                widthOverride: width,
                heightOverride: height,
              );

        return Positioned(
          left: bx - width / 2,
          top: (by + settleDy) - height / 2,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0016)
              ..scale(scale)
              ..rotateZ(zRot)
              ..rotateX(xTilt)
              ..rotateY(yRotFixed), // ✅ use fixed rotation
            child: cardWidget,
          ),
        );
      },
    );
  }
}


