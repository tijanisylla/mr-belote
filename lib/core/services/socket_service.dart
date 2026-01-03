import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Socket.io service for real-time multiplayer
class SocketService {
  IO.Socket? _socket;
  static const String baseUrl = 'https://your-backend-url.com'; // TODO: Update with actual URL

  IO.Socket? get socket => _socket;

  /// Connect to socket server
  void connect(String userId) {
    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      print('Socket connected');
      _socket!.emit('user_connected', {'userId': userId});
    });

    _socket!.onDisconnect((_) {
      print('Socket disconnected');
    });

    _socket!.onError((error) {
      print('Socket error: $error');
    });
  }

  /// Join a game room
  void joinRoom(String roomId) {
    _socket?.emit('join_room', {'roomId': roomId});
  }

  /// Leave a game room
  void leaveRoom(String roomId) {
    _socket?.emit('leave_room', {'roomId': roomId});
  }

  /// Play a card
  void playCard(String roomId, String cardId) {
    _socket?.emit('play_card', {
      'roomId': roomId,
      'cardId': cardId,
    });
  }

  /// Send chat message
  void sendMessage(String roomId, String message) {
    _socket?.emit('chat_message', {
      'roomId': roomId,
      'message': message,
    });
  }

  /// Listen to game state updates
  void onGameStateUpdate(Function(Map<String, dynamic>) callback) {
    _socket?.on('game_state_update', (data) {
      callback(data);
    });
  }

  /// Listen to card played events
  void onCardPlayed(Function(Map<String, dynamic>) callback) {
    _socket?.on('card_played', (data) {
      callback(data);
    });
  }

  /// Listen to chat messages
  void onChatMessage(Function(Map<String, dynamic>) callback) {
    _socket?.on('chat_message', (data) {
      callback(data);
    });
  }

  /// Disconnect from socket
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}



