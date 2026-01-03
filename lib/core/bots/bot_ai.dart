import 'dart:math';
import '../models/card.dart';
import '../models/game_state.dart';
import '../utils/game_helpers.dart';

/// Bot AI for Belote game
class BotAI {
  final Random _random = Random();

  /// Should bot take the turned suit? (Round 1 bidding)
  /// Simple heuristic: take if has J or (9 + another trump) or (A + 10 + another trump)
  bool shouldTakeTurnedSuit({
    required GameState gameState,
    required PlayerPosition botPosition,
    required List<PlayingCard> hand,
  }) {
    if (gameState.turnedCard == null) return false;
    
    final turnedSuit = gameState.turnedCard!.suit;
    final trumpCards = hand.where((c) => c.suit == turnedSuit).toList();
    
    if (trumpCards.isEmpty) return false;
    
    // Count high trumps (J=20, 9=14, A=11, 10=10)
    bool hasJack = trumpCards.any((c) => c.rank == Rank.jack);
    bool hasNine = trumpCards.any((c) => c.rank == Rank.nine);
    bool hasAce = trumpCards.any((c) => c.rank == Rank.ace);
    bool hasTen = trumpCards.any((c) => c.rank == Rank.ten);
    
    // Take if has J
    if (hasJack) return true;
    
    // Take if has 9 + at least one other trump
    if (hasNine && trumpCards.length >= 2) return true;
    
    // Take if has A + 10 + at least one other trump
    if (hasAce && hasTen && trumpCards.length >= 3) return true;
    
    return false;
  }

  /// Choose a suit in Round 2 (choose another suit or null to pass)
  Suit? chooseSuitRound2({
    required GameState gameState,
    required PlayerPosition botPosition,
    required List<PlayingCard> hand,
  }) {
    if (gameState.turnedCard == null) return null;
    final turnedSuit = gameState.turnedCard!.suit;
    
    // Evaluate each suit (except turned suit) as potential trump
    Suit? bestSuit;
    int bestStrength = 0;
    
    for (final suit in Suit.values) {
      if (suit == turnedSuit) continue; // Can't choose turned suit in round 2
      
      final trumpCards = hand.where((c) => c.suit == suit).toList();
      if (trumpCards.isEmpty) continue;
      
      int strength = 0;
      for (final card in trumpCards) {
        // Estimate value: J=20, 9=14, A=11, 10=10, K=4, Q=3
        switch (card.rank) {
          case Rank.jack:
            strength += 20;
            break;
          case Rank.nine:
            strength += 14;
            break;
          case Rank.ace:
            strength += 11;
            break;
          case Rank.ten:
            strength += 10;
            break;
          case Rank.king:
            strength += 4;
            break;
          case Rank.queen:
            strength += 3;
            break;
          default:
            break;
        }
      }
      
      // Bonus for having multiple trumps
      if (trumpCards.length >= 3) strength += 20;
      
      if (strength > bestStrength && strength > 80) {
        bestStrength = strength;
        bestSuit = suit;
      }
    }
    
    return bestSuit;
  }

  /// Get bot's card to play
  PlayingCard? playCard({
    required GameState gameState,
    required PlayerPosition botPosition,
    required List<PlayingCard> hand,
  }) {
    if (hand.isEmpty) return null;

    final currentTrickCards = gameState.currentTrickCards;
    final trickLeader = currentTrickCards != null && currentTrickCards.isNotEmpty
        ? currentTrickCards.keys.first
        : null;

    // Get valid moves
    final validMoves = GameHelpers.getValidMoves(
      hand: hand,
      currentTrickCards: currentTrickCards,
      trumpSuit: gameState.trumpSuit,
      player: botPosition,
      trickLeader: trickLeader,
    );

    if (validMoves.isEmpty) {
      return hand.first; // Fallback
    }

    // Strategy: Try to win if partner is not winning, or play low if partner is winning
    if (currentTrickCards != null && currentTrickCards.isNotEmpty) {
      final currentWinner = GameHelpers.getTrickWinner(
        cards: currentTrickCards,
        leader: trickLeader!,
        trumpSuit: gameState.trumpSuit,
      );

      final myTeam = GameHelpers.getTeamForPosition(botPosition);
      final winnerTeam = currentWinner != null
          ? GameHelpers.getTeamForPosition(currentWinner)
          : null;

      // If partner is winning, play low
      if (winnerTeam == myTeam && currentWinner != botPosition) {
        return _playLowCard(validMoves, gameState.trumpSuit);
      }

      // If opponent is winning or no winner yet, try to win
      if (winnerTeam != myTeam || currentWinner == null) {
        final winningCard = _tryToWin(
          validMoves: validMoves,
          currentTrickCards: currentTrickCards,
          trickLeader: trickLeader,
          trumpSuit: gameState.trumpSuit,
        );
        if (winningCard != null) {
          return winningCard;
        }
        // Can't win, play low
        return _playLowCard(validMoves, gameState.trumpSuit);
      }
    }

    // Starting a new trick - play a middle card
    return _playOpeningCard(validMoves, gameState.trumpSuit);
  }

  /// Try to play a card that will win the trick
  PlayingCard? _tryToWin({
    required List<PlayingCard> validMoves,
    required Map<PlayerPosition, PlayingCard> currentTrickCards,
    required PlayerPosition trickLeader,
    required Suit? trumpSuit,
  }) {
    if (currentTrickCards.isEmpty || trumpSuit == null) return null;

    final leadCard = currentTrickCards[trickLeader]!;
    final isLeadTrump = leadCard.isTrump;
    final leadSuit = leadCard.suit;

    PlayingCard? bestCard;
    int bestOrder = -1;

    for (final card in validMoves) {
      if (isLeadTrump) {
        // Lead is trump, need to play higher trump
        if (card.isTrump && card.getTrumpOrder() > leadCard.getTrumpOrder()) {
          if (bestCard == null || card.getTrumpOrder() > bestOrder) {
            bestCard = card;
            bestOrder = card.getTrumpOrder();
          }
        }
      } else {
        // Lead is not trump
        if (card.isTrump) {
          // Playing trump beats non-trump
          if (bestCard == null || !bestCard.isTrump || card.getTrumpOrder() > bestOrder) {
            bestCard = card;
            bestOrder = card.getTrumpOrder();
          }
        } else if (card.suit == leadSuit) {
          // Same suit, need higher
          if (card.getNonTrumpOrder() > leadCard.getNonTrumpOrder()) {
            if (bestCard == null ||
                (!bestCard.isTrump && card.getNonTrumpOrder() > bestOrder)) {
              bestCard = card;
              bestOrder = card.getNonTrumpOrder();
            }
          }
        }
      }
    }

    return bestCard;
  }

  /// Play a low card (when partner is winning)
  PlayingCard _playLowCard(List<PlayingCard> validMoves, Suit? trumpSuit) {
    PlayingCard? lowestCard;
    int lowestOrder = 100;

    for (final card in validMoves) {
      final order = card.getOrder();
      if (order < lowestOrder) {
        lowestOrder = order;
        lowestCard = card;
      }
    }

    return lowestCard ?? validMoves.first;
  }

  /// Play an opening card (start a new trick)
  PlayingCard _playOpeningCard(List<PlayingCard> validMoves, Suit? trumpSuit) {
    // Prefer playing non-trump if available
    final nonTrump = validMoves.where((c) => !c.isTrump).toList();
    if (nonTrump.isNotEmpty) {
      // Play a middle card
      nonTrump.sort((a, b) => a.getNonTrumpOrder().compareTo(b.getNonTrumpOrder()));
      final middleIndex = nonTrump.length ~/ 2;
      return nonTrump[middleIndex];
    }

    // Only trumps available, play a middle trump
    validMoves.sort((a, b) => a.getTrumpOrder().compareTo(b.getTrumpOrder()));
    final middleIndex = validMoves.length ~/ 2;
    return validMoves[middleIndex];
  }
}
