import '../models/card.dart';
import '../models/game_state.dart';

/// Game helper utilities
class GameHelpers {
  /// Get team for a player position
  static Team getTeamForPosition(PlayerPosition position) {
    return (position == PlayerPosition.north || position == PlayerPosition.south)
        ? Team.team1
        : Team.team2;
  }

  /// Get next player position
  static PlayerPosition getNextPlayer(PlayerPosition current) {
    switch (current) {
      case PlayerPosition.north:
        return PlayerPosition.east;
      case PlayerPosition.east:
        return PlayerPosition.south;
      case PlayerPosition.south:
        return PlayerPosition.west;
      case PlayerPosition.west:
        return PlayerPosition.north;
    }
  }

  /// Check if a card can be played (following Belote rules)
  /// Rules:
  /// - Must follow suit if possible
  /// - If cannot follow suit:
  ///   - If partner is currently winning: may throw away any card
  ///   - If partner is NOT winning: must trump if possible
  /// - If trump already played: must overtrump if possible
  static bool isValidMove({
    required PlayingCard card,
    required List<PlayingCard> hand,
    required Map<PlayerPosition, PlayingCard>? currentTrickCards,
    required Suit? trumpSuit,
    required PlayerPosition player,
    required PlayerPosition? trickLeader,
  }) {
    if (trumpSuit == null) return false; // No trump yet, shouldn't happen in playing phase
    
    // If leading (first card of trick), any card is valid
    if (currentTrickCards == null || currentTrickCards.isEmpty) {
      return true;
    }

    final leadCard = currentTrickCards[trickLeader!]!;
    final leadSuit = leadCard.suit;
    final isLeadTrump = leadCard.isTrump;
    final playerTeam = getTeamForPosition(player);

    // Check if player has cards of the lead suit
    final leadSuitCards = hand.where((c) => 
      c.suit == leadSuit && (!c.isTrump || (c.isTrump && isLeadTrump))
    ).toList();

    // Must follow suit if possible
    if (leadSuitCards.isNotEmpty) {
      if (isLeadTrump) {
        // Lead is trump - must play trump if have one
        if (card.isTrump) {
          // Check overtrumping rule: if trump already played, must overtrump if possible
          final trumpsPlayed = currentTrickCards.values
              .where((c) => c.isTrump)
              .toList();
          if (trumpsPlayed.isNotEmpty) {
            final highestTrumpPlayed = trumpsPlayed.reduce((a, b) => 
              a.getTrumpOrder() > b.getTrumpOrder() ? a : b
            );
            final playerTrumps = hand.where((c) => c.isTrump).toList();
            final canOvertrump = playerTrumps.any((c) => 
              c.getTrumpOrder() > highestTrumpPlayed.getTrumpOrder()
            );
            if (canOvertrump && card.getTrumpOrder() <= highestTrumpPlayed.getTrumpOrder()) {
              return false; // Must overtrump
            }
          }
          return true;
        }
        return false; // Must play trump
      } else {
        // Lead is not trump - must follow suit
        if (card.suit == leadSuit && !card.isTrump) {
          return true;
        }
        return false; // Must follow suit
      }
    }

    // Cannot follow suit
    // Check who is currently winning the trick
    final currentWinner = getTrickWinner(
      cards: currentTrickCards,
      leader: trickLeader,
      trumpSuit: trumpSuit,
    );
    final winnerTeam = currentWinner != null 
        ? getTeamForPosition(currentWinner)
        : null;
    final isPartnerWinning = winnerTeam == playerTeam && currentWinner != player;

    if (isPartnerWinning) {
      // Partner is winning - may throw away any card
      return true;
    } else {
      // Partner is NOT winning - must trump if possible
      final playerTrumps = hand.where((c) => c.isTrump).toList();
      if (playerTrumps.isNotEmpty) {
        // Must play trump
        if (!card.isTrump) {
          return false;
        }
        // If trump already played, must overtrump if possible
        final trumpsPlayed = currentTrickCards.values
            .where((c) => c.isTrump)
            .toList();
        if (trumpsPlayed.isNotEmpty) {
          final highestTrumpPlayed = trumpsPlayed.reduce((a, b) => 
            a.getTrumpOrder() > b.getTrumpOrder() ? a : b
          );
          final canOvertrump = playerTrumps.any((c) => 
            c.getTrumpOrder() > highestTrumpPlayed.getTrumpOrder()
          );
          if (canOvertrump && card.getTrumpOrder() <= highestTrumpPlayed.getTrumpOrder()) {
            return false; // Must overtrump
          }
        }
        return true;
      } else {
        // No trumps - can play any card
        return true;
      }
    }
  }

  /// Get valid cards that can be played
  static List<PlayingCard> getValidMoves({
    required List<PlayingCard> hand,
    required Map<PlayerPosition, PlayingCard>? currentTrickCards,
    required Suit? trumpSuit,
    required PlayerPosition player,
    required PlayerPosition? trickLeader,
  }) {
    return hand.where((card) {
      return isValidMove(
        card: card,
        hand: hand,
        currentTrickCards: currentTrickCards,
        trumpSuit: trumpSuit,
        player: player,
        trickLeader: trickLeader,
      );
    }).toList();
  }

  /// Determine winner of a trick
  static PlayerPosition? getTrickWinner({
    required Map<PlayerPosition, PlayingCard> cards,
    required PlayerPosition leader,
    required Suit? trumpSuit,
  }) {
    if (cards.isEmpty || trumpSuit == null) return null;

    PlayerPosition? winner = leader;
    PlayingCard? winningCard = cards[leader]!;

    // Check if any trump was played
    final trumpsPlayed = cards.values.where((c) => c.isTrump).toList();
    
    if (trumpsPlayed.isNotEmpty) {
      // Trump wins - find highest trump
      for (final entry in cards.entries) {
        if (entry.value.isTrump && entry.value.getTrumpOrder() > winningCard!.getTrumpOrder()) {
          winner = entry.key;
          winningCard = entry.value;
        }
      }
    } else {
      // No trump - highest card of lead suit wins
      final leadSuit = cards[leader]!.suit;
      for (final entry in cards.entries) {
        if (entry.value.suit == leadSuit && !entry.value.isTrump) {
          if (entry.value.getNonTrumpOrder() > winningCard!.getNonTrumpOrder()) {
            winner = entry.key;
            winningCard = entry.value;
          }
        }
      }
    }

    return winner;
  }

  /// Calculate points for a team in a trick
  static int calculateTrickPoints({
    required Map<PlayerPosition, PlayingCard> cards,
    required Team team,
    required Suit? trumpSuit,
  }) {
    int points = 0;
    for (final entry in cards.entries) {
      final card = entry.value;
      final playerTeam = getTeamForPosition(entry.key);
      if (playerTeam == team) {
        points += card.getValue();
      }
    }
    return points;
  }

  /// Calculate total points for all cards won by a team
  static int calculateTeamPoints({
    required List<Trick> tricks,
    required Team team,
    required Suit? trumpSuit,
  }) {
    int totalPoints = 0;

    for (final trick in tricks) {
      if (trick.winner != null && trick.winner == team) {
        totalPoints += calculateTrickPoints(
          cards: trick.cards,
          team: team,
          trumpSuit: trumpSuit,
        );
      }
    }

    // Add last trick bonus (+10 points for last trick)
    if (tricks.length >= 8) {
      final lastTrick = tricks.last;
      if (lastTrick.winner != null && lastTrick.winner == team) {
        totalPoints += 10; // Last trick bonus
      }
    }

    return totalPoints;
  }

  /// Check if player has K and Q of trump (for Belote/Rebelote)
  static bool hasBelotePair(List<PlayingCard> hand, Suit trumpSuit) {
    final hasKing = hand.any((c) => c.isTrump && c.rank == Rank.king);
    final hasQueen = hand.any((c) => c.isTrump && c.rank == Rank.queen);
    return hasKing && hasQueen;
  }
}
