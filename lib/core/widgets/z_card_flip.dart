import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 3D card flip animation using Flutter's native Transform
class ZCardFlip extends StatelessWidget {
  final Widget front;
  final Widget back;
  final bool showBack;

  const ZCardFlip({
    super.key,
    required this.front,
    required this.back,
    required this.showBack,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: showBack ? math.pi : 0.0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      builder: (context, angle, child) {
        // Determine which side to show based on rotation angle
        final showingBack = angle > math.pi / 2;
        
        // Calculate the rotation transform with perspective
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001) // perspective
          ..rotateY(angle);

        return Transform(
          alignment: Alignment.center,
          transform: transform,
          child: showingBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: back,
                )
              : front,
        );
      },
    );
  }
}
