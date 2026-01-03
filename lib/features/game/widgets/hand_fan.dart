import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/models/card.dart';
import '../../../core/widgets/playing_card_widget.dart';
import '../../../core/models/game_state.dart';

/// A compact fan of cards for hands (south or opponents).
///
/// For south: large cards (92x132), face-up, overlap 44, ±7° rotation, group rotateX(-0.16)
/// For opponents: small cards (34x50), face-down, overlap 16, ±3° rotation
enum FanOrientation { horizontal, vertical }

class HandFan extends StatelessWidget {
  final List<PlayingCard> cards;
  final bool showBack;
  final double cardWidth;
  final double cardHeight;
  final double overlap;
  final double maxRotationDegrees;
  final FanOrientation orientation;
  final double? groupTiltX; // Optional group perspective tilt (e.g., -0.16 for south)
  final PlayingCard? selectedCard;
  final Function(PlayingCard)? onCardTap;
  final bool isPlayable;

  const HandFan({
    super.key,
    required this.cards,
    required this.showBack,
    required this.cardWidth,
    required this.cardHeight,
    required this.overlap,
    required this.maxRotationDegrees,
    required this.orientation,
    this.groupTiltX,
    this.selectedCard,
    this.onCardTap,
    this.isPlayable = false,
  });

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    final step = orientation == FanOrientation.horizontal
        ? cardWidth - overlap
        : cardHeight - overlap;

    final totalLength = cards.length > 0
        ? step * (cards.length - 1) + (orientation == FanOrientation.horizontal ? cardWidth : cardHeight)
        : 0.0;

    final centerIndex = (cards.length - 1) / 2.0;
    final maxAngleRad = maxRotationDegrees * math.pi / 180.0;

    Widget fanContent = Stack(
      clipBehavior: showBack ? Clip.hardEdge : Clip.none,  // ✅ Clip opponents, not south
      children: cards.asMap().entries.map((entry) {
        final index = entry.key;
        final card = entry.value;
        final isSelected = selectedCard == card;

        final t = centerIndex > 0 ? (index - centerIndex) / centerIndex : 0.0;
        final angle = t * maxAngleRad;
        final selectedLift = isSelected ? -14.0 : 0.0;  // ✅ Negative = UP in Flutter

        Offset position;
        if (orientation == FanOrientation.horizontal) {
          position = Offset(index * step, selectedLift);
        } else {
          position = Offset(0, index * step + selectedLift);
        }

        Widget cardWidget = SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: PlayingCardWidget(
          card: card,
          size: CardSize.large,
          showBack: showBack,
          isPlayable: isPlayable,
          isSelected: isSelected,
          onTap: onCardTap != null ? () => onCardTap!(card) : null,
          ),
        );

        // ✅ Removed per-card 90° rotation for vertical - cards stay upright

        return Positioned(
          left: position.dx,
          top: position.dy,
          child: Transform.rotate(
            angle: angle,
            child: cardWidget,
          ),
        );
      }).toList(),
    );

    // Apply group perspective tilt if specified (for south hand)
    if (groupTiltX != null) {
      fanContent = Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0014) // ✅ add perspective for true 3D
          ..rotateX(groupTiltX!),
        child: fanContent,
      );
    }

    // Container dimensions (cards stay upright now, no rotation)
    final containerWidth = orientation == FanOrientation.horizontal ? totalLength : cardWidth;
    final containerHeight = orientation == FanOrientation.horizontal ? cardHeight : totalLength;

    return SizedBox(
      width: containerWidth,
      height: containerHeight,
      child: fanContent,
    );
  }
}

