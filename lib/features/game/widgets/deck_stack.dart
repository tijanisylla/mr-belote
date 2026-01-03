import 'package:flutter/material.dart';
import '../../../core/models/card.dart';
import '../../../core/widgets/playing_card_widget.dart';

/// A stacked deck widget that renders multiple card backs with offset and shadow
class DeckStack extends StatelessWidget {
  final double width;
  final double height;
  final int cardCount;
  final double offsetX;
  final double offsetY;

  const DeckStack({
    super.key,
    required this.width,
    required this.height,
    this.cardCount = 12,
    this.offsetX = 1.4,
    this.offsetY = 1.6,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width + (cardCount * offsetX),
      height: height + (cardCount * offsetY),
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(
          cardCount,
          (index) {
            final isBottom = index == 0;  // ✅ Only shadow the bottom card
            return Positioned(
              left: index * offsetX,
              top: index * offsetY,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isBottom
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : const [],  // ✅ No shadow on stacked cards
                ),
                child: SizedBox(
                  width: width,
                  height: height,
                child: PlayingCardWidget(
                  card: PlayingCard(suit: Suit.spades, rank: Rank.ace),
                  size: CardSize.large,
                  showBack: true,
                  isPlayable: false,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

