/// Lobby model for game rooms
class LobbyModel {
  final String id;
  final String roomId; // Shareable room ID (e.g., "ABC123")
  final String name;
  final bool isFree; // true for free games, false for money games
  final double? minBet; // null for free games, amount for money games
  final int currentPlayers;
  final int maxPlayers;
  final bool isActive;
  final String? hostName;
  final int? hostLevel;
  final String gameMode; // e.g., "CLASSIC BELOTE", "TOURNAMENT"

  LobbyModel({
    required this.id,
    required this.roomId,
    required this.name,
    required this.isFree,
    this.minBet,
    required this.currentPlayers,
    required this.maxPlayers,
    required this.isActive,
    this.hostName,
    this.hostLevel,
    this.gameMode = 'CLASSIC BELOTE',
  });

  bool get isFull => currentPlayers >= maxPlayers;
  bool get canJoin => isActive && !isFull;

  factory LobbyModel.fromJson(Map<String, dynamic> json) {
    return LobbyModel(
      id: json['id'] as String,
      roomId: json['roomId'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      isFree: json['isFree'] as bool? ?? true,
      minBet: json['minBet'] != null ? (json['minBet'] as num).toDouble() : null,
      currentPlayers: json['currentPlayers'] as int? ?? 0,
      maxPlayers: json['maxPlayers'] as int? ?? 4,
      isActive: json['isActive'] as bool? ?? true,
      hostName: json['hostName'] as String?,
      hostLevel: json['hostLevel'] as int?,
      gameMode: json['gameMode'] as String? ?? 'CLASSIC BELOTE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'name': name,
      'isFree': isFree,
      'minBet': minBet,
      'currentPlayers': currentPlayers,
      'maxPlayers': maxPlayers,
      'isActive': isActive,
      'hostName': hostName,
      'hostLevel': hostLevel,
      'gameMode': gameMode,
    };
  }
}

