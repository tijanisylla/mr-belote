import 'package:dio/dio.dart';
import '../models/player.dart';

/// REST API service
class ApiService {
  late final Dio _dio;
  static const String baseUrl = 'https://your-api-url.com/api'; // TODO: Update with actual URL

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors for auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // TODO: Add auth token to headers
          // final token = getAuthToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
          handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors
          handler.next(error);
        },
      ),
    );
  }

  /// Sign in with Google
  Future<Player> signInWithGoogle(String idToken) async {
    try {
      final response = await _dio.post(
        '/auth/google',
        data: {'idToken': idToken},
      );
      return Player.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  /// Sign in with Facebook
  Future<Player> signInWithFacebook(String accessToken) async {
    try {
      final response = await _dio.post(
        '/auth/facebook',
        data: {'accessToken': accessToken},
      );
      return Player.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to sign in with Facebook: $e');
    }
  }

  /// Get user profile
  Future<Player> getUserProfile(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      return Player.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Get wallet balance
  Future<double> getWalletBalance(String userId) async {
    try {
      final response = await _dio.get('/wallet/$userId/balance');
      return (response.data['balance'] as num).toDouble();
    } catch (e) {
      throw Exception('Failed to get wallet balance: $e');
    }
  }

  /// Get active lobbies
  Future<List<Map<String, dynamic>>> getActiveLobbies() async {
    try {
      final response = await _dio.get('/lobbies/active');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to get active lobbies: $e');
    }
  }

  /// Create a new lobby
  Future<Map<String, dynamic>> createLobby({
    required String hostId,
    required double buyIn,
    required int maxPlayers,
  }) async {
    try {
      final response = await _dio.post(
        '/lobbies',
        data: {
          'hostId': hostId,
          'buyIn': buyIn,
          'maxPlayers': maxPlayers,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to create lobby: $e');
    }
  }

  /// Join a lobby
  Future<void> joinLobby(String lobbyId, String userId) async {
    try {
      await _dio.post(
        '/lobbies/$lobbyId/join',
        data: {'userId': userId},
      );
    } catch (e) {
      throw Exception('Failed to join lobby: $e');
    }
  }
}



