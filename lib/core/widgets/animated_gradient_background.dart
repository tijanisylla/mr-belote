import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated gradient background with moving colors
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  
  const AnimatedGradientBackground({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1F3A), // Background dark
                Color.lerp(
                  const Color(0xFF0F1419),
                  const Color(0xFF6366F1),
                  (math.sin(_controller.value * 2 * math.pi) + 1) / 4,
                )!,
                Color.lerp(
                  const Color(0xFF1A1F3A),
                  const Color(0xFFA5B4FC),
                  (math.cos(_controller.value * 2 * math.pi) + 1) / 6,
                )!,
                const Color(0xFF0F1419), // Background darkest
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}






