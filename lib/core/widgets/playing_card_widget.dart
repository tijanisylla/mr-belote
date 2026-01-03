import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/card.dart';
import '../theme/app_colors.dart';

/// Card size enum
enum CardSize {
  tiny,
  small,
  medium,
  large,
}

/// Playing Card Widget
class PlayingCardWidget extends StatefulWidget {
  final PlayingCard card;
  final CardSize size;
  final bool isSelected;
  final bool isPlayable;
  final VoidCallback? onTap;
  final bool showBack;

  const PlayingCardWidget({
    super.key,
    required this.card,
    this.size = CardSize.medium,
    this.isSelected = false,
    this.isPlayable = true,
    this.onTap,
    this.showBack = false,
  });

  @override
  State<PlayingCardWidget> createState() => _PlayingCardWidgetState();
}

class _PlayingCardWidgetState extends State<PlayingCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _translateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _translateAnimation = Tween<double>(begin: 0.0, end: -15.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(PlayingCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardDimensions = _getCardDimensions();
    final fontSize = _getFontSize();
    final suitSize = _getSuitSize();

    return GestureDetector(
      onTap: widget.isPlayable ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _translateAnimation.value),
              child: Container(
                width: cardDimensions.width,
                height: cardDimensions.height,
                decoration: BoxDecoration(
                  color: widget.showBack
                      ? AppColors.background
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.isSelected
                        ? AppColors.goldPrimary
                        : AppColors.cardBorder,
                    width: widget.isSelected ? 2 : 1,
                  ),
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.goldPrimary.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: widget.showBack
                    ? _buildCardBack()
                    : _buildCardFront(fontSize, suitSize),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardBack() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/new-cards/back-blue.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.backgroundDark,
            child: Center(
              child: Text(
                'BELOTE',
                style: TextStyle(
                  color: AppColors.accentPrimary,
                  fontSize: _getFontSize() * 1.2,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardFront(double fontSize, double suitSize) {
    final rankText = _getRankText();
    final suitColor = widget.card.isRed
        ? AppColors.cardRed
        : AppColors.cardBlack;

    return Stack(
      children: [
        // Card PNG Image
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              widget.card.getAssetPath(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.white,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: _getCardDimensions().height * 0.3,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Note: PNG cards already have rank and suit printed on them
        // No need to overlay text/icons since the asset contains the full card design
      ],
    );
  }

  String _getRankText() {
    switch (widget.card.rank) {
      case Rank.seven:
        return '7';
      case Rank.eight:
        return '8';
      case Rank.nine:
        return '9';
      case Rank.jack:
        return 'J';
      case Rank.queen:
        return 'Q';
      case Rank.king:
        return 'K';
      case Rank.ten:
        return '10';
      case Rank.ace:
        return 'A';
    }
  }

  IconData _getSuitIcon() {
    switch (widget.card.suit) {
      case Suit.spades:
        return Icons.casino; // Using casino icon as spade alternative
      case Suit.hearts:
        return Icons.favorite;
      case Suit.diamonds:
        return Icons.diamond;
      case Suit.clubs:
        return Icons.extension; // Using extension icon as club alternative
    }
  }

  ({double width, double height}) _getCardDimensions() {
    switch (widget.size) {
      case CardSize.tiny:
        return (width: 24.0, height: 34.0);
      case CardSize.small:
        return (width: 32.0, height: 46.0);
      case CardSize.medium:
        return (width: 40.0, height: 58.0);
      case CardSize.large:
        return (width: 52.0, height: 74.0);
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case CardSize.tiny:
        return 7.0;
      case CardSize.small:
        return 9.0;
      case CardSize.medium:
        return 11.0;
      case CardSize.large:
        return 13.0;
    }
  }

  double _getSuitSize() {
    switch (widget.size) {
      case CardSize.tiny:
        return 9.0;
      case CardSize.small:
        return 12.0;
      case CardSize.medium:
        return 16.0;
      case CardSize.large:
        return 22.0;
    }
  }
}


