import 'package:flutter/material.dart';

class GameTableBackground extends StatelessWidget {
  const GameTableBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Exact table background image (no modifications)
          Image.asset(
            'assets/images/table_game_bg.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
          // Subtle vignette for depth
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.05),
                radius: 1.0,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

