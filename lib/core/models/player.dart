import 'game_state.dart';

/// Player model
class Player {
  final String id;
  final String username;
  final String? avatarPath;
  final String? gender;
  final int? age;
  final double walletBalance;
  final int level;
  final int experience;
  final int gamesPlayed;
  final int gamesWon;
  final PlayerPosition? position;
  final bool hasCompletedSetup;

  Player({
    required this.id,
    required this.username,
    this.avatarPath,
    this.gender,
    this.age,
    this.walletBalance = 0.0,
    this.level = 1,
    this.experience = 0,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.position,
    this.hasCompletedSetup = false,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarPath: json['avatarPath'] as String?,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      level: json['level'] as int? ?? 1,
      experience: json['experience'] as int? ?? 0,
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      gamesWon: json['gamesWon'] as int? ?? 0,
      position: json['position'] != null
          ? PlayerPosition.values.firstWhere(
              (p) => p.name == json['position'],
            )
          : null,
      hasCompletedSetup: json['hasCompletedSetup'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatarPath': avatarPath,
      'gender': gender,
      'age': age,
      'walletBalance': walletBalance,
      'level': level,
      'experience': experience,
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'position': position?.name,
      'hasCompletedSetup': hasCompletedSetup,
    };
  }

  Player copyWith({
    String? id,
    String? username,
    String? avatarPath,
    String? gender,
    int? age,
    double? walletBalance,
    int? level,
    int? experience,
    int? gamesPlayed,
    int? gamesWon,
    PlayerPosition? position,
    bool? hasCompletedSetup,
  }) {
    return Player(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarPath: avatarPath ?? this.avatarPath,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      walletBalance: walletBalance ?? this.walletBalance,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      position: position ?? this.position,
      hasCompletedSetup: hasCompletedSetup ?? this.hasCompletedSetup,
    );
  }
}

