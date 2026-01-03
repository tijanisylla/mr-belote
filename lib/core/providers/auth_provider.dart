import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';

/// Auth state
class AuthState {
  final Player? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    Player? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Auth provider
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState();
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    // TODO: Implement Google Sign In
    await Future.delayed(const Duration(seconds: 1));
    // Mock user for now - new users haven't completed setup
    state = state.copyWith(
      user: Player(
        id: '1',
        username: 'Player1',
        walletBalance: 1000.0,
        hasCompletedSetup: false, // New users need to complete setup
      ),
      isLoading: false,
    );
  }

  Future<void> signInWithFacebook() async {
    state = state.copyWith(isLoading: true, error: null);
    // TODO: Implement Facebook Sign In
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(
      user: Player(
        id: '1',
        username: 'Player1',
        walletBalance: 1000.0,
        hasCompletedSetup: false, // New users need to complete setup
      ),
      isLoading: false,
    );
  }

  Future<void> signOut() async {
    state = AuthState();
  }

  void updateUserProfile({
    String? username,
    String? avatarPath,
    String? gender,
    int? age,
    bool? hasCompletedSetup,
  }) {
    if (state.user != null) {
      state = state.copyWith(
        user: state.user!.copyWith(
          username: username ?? state.user!.username,
          avatarPath: avatarPath ?? state.user!.avatarPath,
          gender: gender ?? state.user!.gender,
          age: age ?? state.user!.age,
          hasCompletedSetup: hasCompletedSetup ?? state.user!.hasCompletedSetup,
        ),
      );
    }
  }

  void createUserWithSetup({
    required String username,
    String? avatarPath,
    String? gender,
    int? age,
    bool hasCompletedSetup = false,
  }) {
    state = state.copyWith(
      user: Player(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        avatarPath: avatarPath,
        gender: gender,
        age: age,
        walletBalance: 10000.0, // Starting balance for free play
        hasCompletedSetup: hasCompletedSetup,
      ),
    );
  }

  Future<void> signInWithEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    // TODO: Implement email sign in
    await Future.delayed(const Duration(seconds: 1));
    // Mock user - in real app, fetch from backend
    // For now, assume existing users have completed setup
    state = state.copyWith(
      user: Player(
        id: '1',
        username: 'Player1',
        walletBalance: 1000.0,
        hasCompletedSetup: true, // Existing users have completed setup
      ),
      isLoading: false,
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});



