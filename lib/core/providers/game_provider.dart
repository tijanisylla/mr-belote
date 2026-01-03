import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/card.dart';
import '../utils/game_helpers.dart';
import '../bots/bot_ai.dart';

/// Game provider
class GameNotifier extends Notifier<GameState?> {
  final BotAI _botAI = BotAI();
  Timer? _botTimer;
  int _biddingPassCount = 0;
  PlayerPosition? _biddingStartPlayer;
  List<PlayingCard> _remainingDeck = [];

  @override
  GameState? build() {
    return null;
  }

  /// Start a new game with bots (Option A dealing)
  void startNewGame({PlayerPosition? humanPlayer}) {
    _biddingPassCount = 0;
    _biddingStartPlayer = null;
    _remainingDeck = [];

    // Create a 32-card deck
    final deck = <PlayingCard>[];
    for (final suit in Suit.values) {
      for (final rank in Rank.values) {
        deck.add(PlayingCard(suit: suit, rank: rank));
      }
    }
    deck.shuffle();

    // Option A: Deal 5 cards to each player (20 cards total)
    final hands = <PlayerPosition, List<PlayingCard>>{
      PlayerPosition.north: deck.sublist(0, 5),
      PlayerPosition.east: deck.sublist(5, 10),
      PlayerPosition.south: deck.sublist(10, 15),
      PlayerPosition.west: deck.sublist(15, 20),
    };

    // Flip card 20 as turned card
    final turnedCard = deck[20];
    
    // Remaining 11 cards (positions 21-31) for final deal
    // Standard: taker gets turned card (6 cards), then deals 2 more = 8
    // Others: 5 cards, then deal 3 more = 8
    // So: taker gets 2 from remaining, others get 3 each = 2+3+3+3 = 11 ✓
    _remainingDeck = deck.sublist(21); // Cards 21-31 (11 cards)
    
    // Determine bot players
    final human = humanPlayer ?? PlayerPosition.south;
    final botPlayers = PlayerPosition.values.where((p) => p != human).toSet();

    state = GameState(
      deck: deck.sublist(0, 20), // First 20 cards (already dealt)
      hands: hands,
      currentPlayer: PlayerPosition.east, // Player left of dealer (north is dealer)
      phase: GamePhase.biddingRound1,
      turnedCard: turnedCard,
      botPlayers: botPlayers,
    );

    _biddingStartPlayer = PlayerPosition.east;
    _handleBotTurn();
  }

  /// Make bid in Round 1 (take turned suit or pass)
  void makeBidRound1(bool take) {
    if (state == null || state!.phase != GamePhase.biddingRound1) return;

    final currentPlayer = state!.currentPlayer;

    if (take) {
      // Player takes the turned suit
      final trumpSuit = state!.turnedCard!.suit;
      final contractingTeam = GameHelpers.getTeamForPosition(currentPlayer);

      // Add turned card to taker's hand
      final updatedHands = Map<PlayerPosition, List<PlayingCard>>.from(state!.hands);
      updatedHands[currentPlayer] = List<PlayingCard>.from(updatedHands[currentPlayer]!)
        ..add(state!.turnedCard!);

      state = state!.copyWith(
        taker: currentPlayer,
        trumpSuit: trumpSuit,
        contractingTeam: contractingTeam,
        hands: updatedHands,
        phase: GamePhase.finalDeal,
      );

      _dealFinalCards();
    } else {
      // Pass
      _biddingPassCount++;
      final nextPlayer = GameHelpers.getNextPlayer(currentPlayer);

      if (nextPlayer == _biddingStartPlayer && _biddingPassCount >= 4) {
        // All passed round 1, go to round 2
        _biddingPassCount = 0;
        state = state!.copyWith(
          phase: GamePhase.biddingRound2,
          currentPlayer: _biddingStartPlayer!,
        );
      } else {
        state = state!.copyWith(currentPlayer: nextPlayer);
      }

      _handleBotTurn();
    }
  }

  /// Make bid in Round 2 (choose another suit or pass)
  void makeBidRound2(Suit? suit) {
    if (state == null || state!.phase != GamePhase.biddingRound2) return;
    if (suit != null && suit == state!.turnedCard?.suit) return; // Can't choose turned suit

    final currentPlayer = state!.currentPlayer;

    if (suit != null) {
      // Player chooses a suit
      final contractingTeam = GameHelpers.getTeamForPosition(currentPlayer);

      state = state!.copyWith(
        chosenSuit: suit,
        trumpSuit: suit,
        contractingTeam: contractingTeam,
        phase: GamePhase.finalDeal,
      );

      _dealFinalCards();
    } else {
      // Pass
      _biddingPassCount++;
      final nextPlayer = GameHelpers.getNextPlayer(currentPlayer);

      if (nextPlayer == _biddingStartPlayer && _biddingPassCount >= 4) {
        // All passed round 2, redeal
        startNewGame();
      } else {
        state = state!.copyWith(currentPlayer: nextPlayer);
      }

      _handleBotTurn();
    }
  }

  /// Deal final 3 cards to each player
  void _dealFinalCards() {
    if (state == null) return;

    // Deal remaining 11 cards: taker gets 2 (already has turned card = 6, +2 = 8), others get 3 (5+3=8)
    final updatedHands = Map<PlayerPosition, List<PlayingCard>>.from(state!.hands);
    final positions = [PlayerPosition.north, PlayerPosition.east, PlayerPosition.south, PlayerPosition.west];
    int deckIndex = 0;

    for (final pos in positions) {
      final cardsToDeal = (pos == state!.taker) ? 2 : 3;
      for (int j = 0; j < cardsToDeal && deckIndex < _remainingDeck.length; j++) {
        updatedHands[pos]!.add(_remainingDeck[deckIndex]);
        deckIndex++;
      }
    }

    // Mark cards as trump
    final trumpSuit = state!.trumpSuit!;
    final finalHands = <PlayerPosition, List<PlayingCard>>{};
    for (final entry in updatedHands.entries) {
      finalHands[entry.key] = entry.value.map((card) => PlayingCard(
        suit: card.suit,
        rank: card.rank,
        isTrump: card.suit == trumpSuit,
      )).toList();
    }

    // Check for Belote pairs and initialize tracking
    final beloteStarted = Map<PlayerPosition, bool>.from(state!.beloteStarted);
    for (final entry in finalHands.entries) {
      if (GameHelpers.hasBelotePair(entry.value, trumpSuit)) {
        beloteStarted[entry.key] = false; // Has pair, but hasn't played first yet
      }
    }

    // Determine first player (contracting team leads, or taker leads)
    final firstPlayer = state!.taker ?? 
        (state!.chosenSuit != null ? state!.currentPlayer : PlayerPosition.north);

    state = state!.copyWith(
      hands: finalHands,
      phase: GamePhase.playing,
      currentPlayer: firstPlayer,
      hasDealtFinalCards: true,
      beloteStarted: beloteStarted,
    );

    _handleBotTurn();
  }

  /// Play a card (human or bot)
  void playCard(PlayerPosition player, PlayingCard card) {
    if (state == null || state!.phase != GamePhase.playing) return;
    if (player != state!.currentPlayer) return;

    final hand = state!.hands[player]!;
    if (!hand.contains(card)) return;

    final currentTrickCards = Map<PlayerPosition, PlayingCard>.from(
      state!.currentTrickCards ?? {},
    );
    final trickLeader = currentTrickCards.isNotEmpty
        ? currentTrickCards.keys.first
        : player;

    // Validate move
    if (!GameHelpers.isValidMove(
      card: card,
      hand: hand,
      currentTrickCards: currentTrickCards,
      trumpSuit: state!.trumpSuit,
      player: player,
      trickLeader: trickLeader,
    )) {
      return;
    }

    // Remove card from hand
    final updatedHands = Map<PlayerPosition, List<PlayingCard>>.from(state!.hands);
    updatedHands[player] = hand.where((c) => c != card).toList();

    // Check for Belote/Rebelote
    final updatedBeloteStarted = Map<PlayerPosition, bool>.from(state!.beloteStarted);
    final updatedBeloteBonuses = Map<Team, int>.from(state!.beloteBonuses);
    
    if (card.isTrump && (card.rank == Rank.king || card.rank == Rank.queen)) {
      final hasStarted = updatedBeloteStarted[player] ?? false;
      if (!hasStarted) {
        // Check if player has the pair
        final remainingHand = updatedHands[player]!;
        final hasOther = card.rank == Rank.king
            ? remainingHand.any((c) => c.isTrump && c.rank == Rank.queen)
            : remainingHand.any((c) => c.isTrump && c.rank == Rank.king);
        if (hasOther) {
          updatedBeloteStarted[player] = true; // Belote announced
        }
      } else {
        // Rebelote - award +20 points
        final playerTeam = GameHelpers.getTeamForPosition(player);
        updatedBeloteBonuses[playerTeam] = (updatedBeloteBonuses[playerTeam] ?? 0) + 20;
        updatedBeloteStarted[player] = false; // Reset
      }
    }

    // Add card to current trick
    currentTrickCards[player] = card;

    // Check if trick is complete (4 cards played)
    if (currentTrickCards.length == 4) {
      // Determine winner
      final winner = GameHelpers.getTrickWinner(
        cards: currentTrickCards,
        leader: trickLeader,
        trumpSuit: state!.trumpSuit,
      )!;

      final winnerTeam = GameHelpers.getTeamForPosition(winner);

      // Create completed trick
      final completedTrick = Trick(
        cards: Map.from(currentTrickCards),
        leader: trickLeader,
        winner: winnerTeam,
      );

      // Add to tricks list
      final updatedTricks = List<Trick>.from(state!.tricks)..add(completedTrick);

      // Check if hand is complete (8 tricks)
      if (updatedTricks.length >= 8) {
        _endHand(updatedTricks, updatedBeloteBonuses);
        return;
      }

      // Start new trick with winner
      state = state!.copyWith(
        hands: updatedHands,
        currentTrickCards: {},
        currentPlayer: winner,
        currentTrick: state!.currentTrick + 1,
        tricks: updatedTricks,
        beloteStarted: updatedBeloteStarted,
        beloteBonuses: updatedBeloteBonuses,
      );
    } else {
      // Continue current trick
      state = state!.copyWith(
        hands: updatedHands,
        currentTrickCards: currentTrickCards,
        currentPlayer: GameHelpers.getNextPlayer(player),
        beloteStarted: updatedBeloteStarted,
        beloteBonuses: updatedBeloteBonuses,
      );
    }

    _handleBotTurn();
  }

  /// Clear current trick cards after animation completes
  void clearCurrentTrick() {
    if (state == null) return;
    
    // Only clear if trick is complete (4 cards)
    if (state!.currentTrickCards != null && state!.currentTrickCards!.length == 4) {
      state = state!.copyWith(
        currentTrickCards: {},
      );
    }
  }

  /// End the hand and calculate scores
  void _endHand(List<Trick> tricks, Map<Team, int> beloteBonuses) {
    if (state == null) return;

    // Calculate points for each team
    final team1Points = GameHelpers.calculateTeamPoints(
      tricks: tricks,
      team: Team.team1,
      trumpSuit: state!.trumpSuit,
    ) + (beloteBonuses[Team.team1] ?? 0);

    final team2Points = GameHelpers.calculateTeamPoints(
      tricks: tricks,
      team: Team.team2,
      trumpSuit: state!.trumpSuit,
    ) + (beloteBonuses[Team.team2] ?? 0);

    // Contract success: contracting team must score more than opponents
    final contractingTeam = state!.contractingTeam;
    if (contractingTeam != null) {
      final contractPoints = contractingTeam == Team.team1 ? team1Points : team2Points;
      final opponentPoints = contractingTeam == Team.team1 ? team2Points : team1Points;

      if (contractPoints > opponentPoints) {
        // Contract succeeds - contracting team scores their points
        final updatedScores = Map<Team, int>.from(state!.scores);
        updatedScores[contractingTeam] = (updatedScores[contractingTeam] ?? 0) + contractPoints;
        state = state!.copyWith(
          scores: updatedScores,
          phase: GamePhase.scoring,
          tricks: tricks,
        );
      } else {
        // Contract fails - opponents take all 172
        final opponentTeam = contractingTeam == Team.team1 ? Team.team2 : Team.team1;
        final updatedScores = Map<Team, int>.from(state!.scores);
        updatedScores[opponentTeam] = (updatedScores[opponentTeam] ?? 0) + 172;
        state = state!.copyWith(
          scores: updatedScores,
          phase: GamePhase.scoring,
          tricks: tricks,
        );
      }
    } else {
      // No contract (shouldn't happen, but fallback)
      final updatedScores = Map<Team, int>.from(state!.scores);
      updatedScores[Team.team1] = (updatedScores[Team.team1] ?? 0) + team1Points;
      updatedScores[Team.team2] = (updatedScores[Team.team2] ?? 0) + team2Points;
      state = state!.copyWith(
        scores: updatedScores,
        phase: GamePhase.scoring,
        tricks: tricks,
      );
    }

    // Check if game is won (first to 1000)
    final team1Total = state!.scores[Team.team1]!;
    final team2Total = state!.scores[Team.team2]!;

    if (team1Total >= 1000 || team2Total >= 1000) {
      state = state!.copyWith(phase: GamePhase.finished);
    } else {
      // Continue to next hand
      Future.delayed(const Duration(seconds: 2), () {
        if (state != null && state!.phase == GamePhase.scoring) {
          startNewGame();
        }
      });
    }
  }

  /// Handle bot turn (bidding or playing)
  void _handleBotTurn() {
    _botTimer?.cancel();

    if (state == null) return;
    if (state!.phase == GamePhase.finished) return;

    final currentPlayer = state!.currentPlayer;
    if (!state!.isBot(currentPlayer)) return;

    _botTimer = Timer(const Duration(milliseconds: 800), () {
      if (state == null) return;
      if (state!.currentPlayer != currentPlayer) return;

      final hand = state!.hands[currentPlayer]!;

      if (state!.phase == GamePhase.biddingRound1) {
        // Bot bidding round 1
        final shouldTake = _botAI.shouldTakeTurnedSuit(
          gameState: state!,
          botPosition: currentPlayer,
          hand: hand,
        );
        makeBidRound1(shouldTake);
      } else if (state!.phase == GamePhase.biddingRound2) {
        // Bot bidding round 2
        final chosenSuit = _botAI.chooseSuitRound2(
          gameState: state!,
          botPosition: currentPlayer,
          hand: hand,
        );
        makeBidRound2(chosenSuit);
      } else if (state!.phase == GamePhase.playing) {
        // Bot playing card
        final card = _botAI.playCard(
          gameState: state!,
          botPosition: currentPlayer,
          hand: hand,
        );
        if (card != null) {
          playCard(currentPlayer, card);
        }
      }
    });
  }

  void abandonGame() {
    _botTimer?.cancel();
    _biddingPassCount = 0;
    _biddingStartPlayer = null;
    _remainingDeck = [];
    state = null;
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState?>(() {
  return GameNotifier();
});
