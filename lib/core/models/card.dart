/// Card Suit enum
enum Suit {
  spades,
  hearts,
  diamonds,
  clubs,
}

/// Card Rank enum
enum Rank {
  seven,
  eight,
  nine,
  jack,
  queen,
  king,
  ten,
  ace,
}

/// Playing Card model
class PlayingCard {
  final Suit suit;
  final Rank rank;
  final bool isTrump;

  PlayingCard({
    required this.suit,
    required this.rank,
    this.isTrump = false,
  });

  /// Get card value in non-trump suit
  int getNonTrumpValue() {
    switch (rank) {
      case Rank.seven:
      case Rank.eight:
      case Rank.nine:
        return 0;
      case Rank.jack:
        return 2;
      case Rank.queen:
        return 3;
      case Rank.king:
        return 4;
      case Rank.ten:
        return 10;
      case Rank.ace:
        return 11;
    }
  }

  /// Get card value in trump suit
  int getTrumpValue() {
    switch (rank) {
      case Rank.seven:
      case Rank.eight:
        return 0;
      case Rank.nine:
        return 14;
      case Rank.jack:
        return 20;
      case Rank.queen:
        return 3;
      case Rank.king:
        return 4;
      case Rank.ten:
        return 10;
      case Rank.ace:
        return 11;
    }
  }

  /// Get card value based on trump status
  int getValue() {
    return isTrump ? getTrumpValue() : getNonTrumpValue();
  }

  /// Get card order in trump suit (higher = stronger)
  int getTrumpOrder() {
    switch (rank) {
      case Rank.jack:
        return 8;
      case Rank.nine:
        return 7;
      case Rank.ace:
        return 6;
      case Rank.ten:
        return 5;
      case Rank.king:
        return 4;
      case Rank.queen:
        return 3;
      case Rank.eight:
        return 2;
      case Rank.seven:
        return 1;
    }
  }

  /// Get card order in non-trump suit
  int getNonTrumpOrder() {
    switch (rank) {
      case Rank.ace:
        return 8;
      case Rank.ten:
        return 7;
      case Rank.king:
        return 6;
      case Rank.queen:
        return 5;
      case Rank.jack:
        return 4;
      case Rank.nine:
        return 3;
      case Rank.eight:
        return 2;
      case Rank.seven:
        return 1;
    }
  }

  /// Get card order based on trump status
  int getOrder() {
    return isTrump ? getTrumpOrder() : getNonTrumpOrder();
  }

  /// Get asset path for card PNG
  String getAssetPath() {
    final suitName = _getSuitAssetName();
    final rankName = _getRankAssetName();
    return 'assets/new-cards/${suitName}_${rankName}.png';
  }

  String _getSuitAssetName() {
    switch (suit) {
      case Suit.spades:
        return 'spade';
      case Suit.hearts:
        return 'heart';
      case Suit.diamonds:
        return 'diamond';
      case Suit.clubs:
        return 'club';
    }
  }

  String _getRankAssetName() {
    switch (rank) {
      case Rank.seven:
        return '7';
      case Rank.eight:
        return '8';
      case Rank.nine:
        return '9';
      case Rank.ten:
        return '10';
      case Rank.jack:
        return 'jack';
      case Rank.queen:
        return 'queen';
      case Rank.king:
        return 'king';
      case Rank.ace:
        return '1'; // Ace maps to 1 in the asset files
    }
  }

  String _getRankName() {
    switch (rank) {
      case Rank.seven:
        return '7';
      case Rank.eight:
        return '8';
      case Rank.nine:
        return '9';
      case Rank.jack:
        return 'jack';
      case Rank.queen:
        return 'queen';
      case Rank.king:
        return 'king';
      case Rank.ten:
        return '10';
      case Rank.ace:
        return 'ace';
    }
  }

  /// Check if card is red (hearts or diamonds)
  bool get isRed => suit == Suit.hearts || suit == Suit.diamonds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayingCard &&
          runtimeType == other.runtimeType &&
          suit == other.suit &&
          rank == other.rank;

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;

  @override
  String toString() => '${_getRankName()}_of_${suit.name}';
}


