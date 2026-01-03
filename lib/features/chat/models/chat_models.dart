import 'package:flutter/material.dart';

/// Chat Type enum
enum ChatType {
  friend,
  lobby,
  room,
}

/// Chat Message model for list view
class ChatMessage {
  final String id;
  final String name;
  final ChatType type;
  final IconData avatar;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final int? participants;
  final bool isOnline;

  ChatMessage({
    required this.id,
    required this.name,
    required this.type,
    required this.avatar,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
    this.participants,
    this.isOnline = false,
  });
}

/// Chat Message Detail model for chat detail screen
class ChatMessageDetail {
  final String id;
  final String userId;
  final String username;
  final String message;
  final DateTime timestamp;
  final bool isMe;

  ChatMessageDetail({
    required this.id,
    required this.userId,
    required this.username,
    required this.message,
    required this.timestamp,
    this.isMe = false,
  });
}

