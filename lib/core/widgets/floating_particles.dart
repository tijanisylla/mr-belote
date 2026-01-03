import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Floating particles animation for background effects
class FloatingParticles extends StatefulWidget {
  final int numberOfParticles;
  final Color particleColor;
  
  const FloatingParticles({
    super.key,
    this.numberOfParticles = 30,
    this.particleColor = Colors.white24,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    _particles = List.generate(
      widget.numberOfParticles,
      (index) => Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 4 + 2,
        speedX: (_random.nextDouble() - 0.5) * 0.5,
        speedY: (_random.nextDouble() - 0.5) * 0.5,
        opacity: _random.nextDouble() * 0.5 + 0.2,
      ),
    );
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
        return CustomPaint(
          painter: ParticlePainter(
            particles: _particles,
            animation: _controller,
            color: widget.particleColor,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  final double size;
  final double speedX;
  final double speedY;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Animation<double> animation;
  final Color color;

  ParticlePainter({
    required this.particles,
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Update particle position
      particle.x += particle.speedX * 0.001;
      particle.y += particle.speedY * 0.001;

      // Wrap around edges
      if (particle.x < 0) particle.x = 1;
      if (particle.x > 1) particle.x = 0;
      if (particle.y < 0) particle.y = 1;
      if (particle.y > 1) particle.y = 0;

      final paint = Paint()
        ..color = color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      // Draw particle with glow effect
      final glowPaint = Paint()
        ..color = color.withOpacity(particle.opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      final offset = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );

      // Draw glow
      canvas.drawCircle(offset, particle.size * 2, glowPaint);
      // Draw particle
      canvas.drawCircle(offset, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

