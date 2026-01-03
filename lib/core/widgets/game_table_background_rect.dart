import 'package:flutter/material.dart';

/// Full-screen table background with BoxFit.cover
/// Fills the entire screen nicely without empty dark areas
class GameTableBackground extends StatelessWidget {
  const GameTableBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/table_game_bg.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            width: double.infinity,
            height: double.infinity,
          ),
          // Subtle vignette
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.05),
                  radius: 1.1,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.28),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

