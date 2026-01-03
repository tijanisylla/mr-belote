import 'package:flutter/material.dart';
import '../../../core/models/game_state.dart';

/// Visual indicator for won tricks pile
/// Shows how many tricks each team has won
class WonTricksPile extends StatelessWidget {
  final Team team;
  final int tricksWon;
  final PlayerPosition position; // Where to display (north/south/east/west)
  final bool isActive; // Highlight when this team just won a trick

  const WonTricksPile({
    super.key,
    required this.team,
    required this.tricksWon,
    required this.position,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive 
            ? Colors.amber.withOpacity(0.3)
            : Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive 
              ? Colors.amber
              : Colors.white.withOpacity(0.2),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Card stack icon
          Stack(
            children: [
              _buildMiniCard(0),
              if (tricksWon > 0)
                Transform.translate(
                  offset: const Offset(3, -2),
                  child: _buildMiniCard(1),
                ),
              if (tricksWon > 1)
                Transform.translate(
                  offset: const Offset(6, -4),
                  child: _buildMiniCard(2),
                ),
            ],
          ),
          const SizedBox(width: 6),
          // Tricks count
          Text(
            '$tricksWon',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard(int index) {
    final opacity = tricksWon > index ? 1.0 : 0.3;
    return Container(
      width: 16,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: Colors.black.withOpacity(0.3),
          width: 0.5,
        ),
      ),
    );
  }
}

