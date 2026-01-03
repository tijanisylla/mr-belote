import 'card.dart';

/// Player position enum
enum PlayerPosition {
  north,
  east,
  south,
  west,
}

/// Team enum
enum Team {
  team1, // North-South
  team2, // East-West
}

/// Game phase enum
enum GamePhase {
  initialDeal, // Deal 5 cards and flip one
  biddingRound1, // Round 1: Accept turned suit or pass
  biddingRound2, // Round 2: Choose another suit or pass
  finalDeal, // Deal remaining 3 cards after trump chosen
  playing,
  scoring,
  finished,
}

/// Bidding round 1 action
enum BidActionRound1 {
  pass,
  take, // Accept the turned-up suit as trump
}

/// Bidding round 2 action
enum BidActionRound2 {
  pass,
  chooseSuit, // Choose a trump suit (different from turned-up suit)
}

/// Game state model
class GameState {
  final List<PlayingCard> deck;
  final Map<PlayerPosition, List<PlayingCard>> hands;
  final Suit? trumpSuit;
  final GamePhase phase;
  final PlayerPosition currentPlayer;
  final Map<Team, int> scores;
  final List<Trick> tricks;
  final int currentTrick;
  
  // Dealing (Option A)
  final PlayingCard? turnedCard; // The flipped card
  final bool hasDealtFinalCards; // Whether final 3 cards have been dealt
  
  // Bidding
  final PlayerPosition? taker; // Who took the turned suit (Round 1)
  final Suit? chosenSuit; // Who chose a suit (Round 2)
  final Team? contractingTeam; // The team that won the bid
  
  // Current trick
  final Map<PlayerPosition, PlayingCard>? currentTrickCards;
  
  // Bot players
  final Set<PlayerPosition> botPlayers;
  
  // Belote/Rebelote tracking
  final Map<PlayerPosition, bool> beloteStarted; // Has player played first of K/Q trump pair
  final Map<Team, int> beloteBonuses; // Belote/Rebelote bonuses per team

  GameState({
    required this.deck,
    required this.hands,
    this.trumpSuit,
    this.phase = GamePhase.initialDeal,
    required this.currentPlayer,
    Map<Team, int>? scores,
    List<Trick>? tricks,
    this.currentTrick = 0,
    this.turnedCard,
    this.hasDealtFinalCards = false,
    this.taker,
    this.chosenSuit,
    this.contractingTeam,
    this.currentTrickCards,
    Set<PlayerPosition>? botPlayers,
    Map<PlayerPosition, bool>? beloteStarted,
    Map<Team, int>? beloteBonuses,
  })  : scores = scores ?? {Team.team1: 0, Team.team2: 0},
        tricks = tricks ?? [],
        botPlayers = botPlayers ?? {PlayerPosition.north, PlayerPosition.east, PlayerPosition.west},
        beloteStarted = beloteStarted ?? {},
        beloteBonuses = beloteBonuses ?? {Team.team1: 0, Team.team2: 0};

  GameState copyWith({
    List<PlayingCard>? deck,
    Map<PlayerPosition, List<PlayingCard>>? hands,
    Suit? trumpSuit,
    GamePhase? phase,
    PlayerPosition? currentPlayer,
    Map<Team, int>? scores,
    List<Trick>? tricks,
    int? currentTrick,
    PlayingCard? turnedCard,
    bool? hasDealtFinalCards,
    PlayerPosition? taker,
    Suit? chosenSuit,
    Team? contractingTeam,
    Map<PlayerPosition, PlayingCard>? currentTrickCards,
    Set<PlayerPosition>? botPlayers,
    Map<PlayerPosition, bool>? beloteStarted,
    Map<Team, int>? beloteBonuses,
  }) {
    return GameState(
      deck: deck ?? this.deck,
      hands: hands ?? this.hands,
      trumpSuit: trumpSuit ?? this.trumpSuit,
      phase: phase ?? this.phase,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      scores: scores ?? this.scores,
      tricks: tricks ?? this.tricks,
      currentTrick: currentTrick ?? this.currentTrick,
      turnedCard: turnedCard ?? this.turnedCard,
      hasDealtFinalCards: hasDealtFinalCards ?? this.hasDealtFinalCards,
      taker: taker ?? this.taker,
      chosenSuit: chosenSuit ?? this.chosenSuit,
      contractingTeam: contractingTeam ?? this.contractingTeam,
      currentTrickCards: currentTrickCards ?? this.currentTrickCards,
      botPlayers: botPlayers ?? this.botPlayers,
      beloteStarted: beloteStarted ?? this.beloteStarted,
      beloteBonuses: beloteBonuses ?? this.beloteBonuses,
    );
  }
  
  /// Check if this is the last trick (trick 8)
  bool get isLastTrick => currentTrick >= 8;
  
  /// Check if a player is a bot
  bool isBot(PlayerPosition position) => botPlayers.contains(position);
}

/// Trick model
class Trick {
  final Map<PlayerPosition, PlayingCard> cards;
  final PlayerPosition leader;
  final Team? winner;

  Trick({
    required this.cards,
    required this.leader,
    this.winner,
  });

  Trick copyWith({
    Map<PlayerPosition, PlayingCard>? cards,
    PlayerPosition? leader,
    Team? winner,
  }) {
    return Trick(
      cards: cards ?? this.cards,
      leader: leader ?? this.leader,
      winner: winner ?? this.winner,
    );
  }
}
