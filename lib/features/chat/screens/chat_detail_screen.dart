import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/floating_particles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/universal_back_button.dart';
import '../models/chat_models.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String chatName;
  final ChatType chatType;
  final int? participants;
  final bool isFull;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.chatName,
    required this.chatType,
    this.participants,
    this.isFull = false,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Mock messages
  final List<ChatMessageDetail> _messages = [
    ChatMessageDetail(
      id: '1',
      userId: 'user1',
      username: 'Ahmed',
      message: 'Good game everyone!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      isMe: false,
    ),
    ChatMessageDetail(
      id: '2',
      userId: 'user2',
      username: 'Fatima',
      message: 'Thanks for the game!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      isMe: false,
    ),
    ChatMessageDetail(
      id: '3',
      userId: 'me',
      username: 'You',
      message: 'Great playing with you all!',
      timestamp: DateTime.now(),
      isMe: true,
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessageDetail(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'me',
        username: 'You',
        message: _messageController.text.trim(),
        timestamp: DateTime.now(),
        isMe: true,
      ));
      _messageController.clear();
    });

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.day}/${time.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            // Floating particles layer
            const Positioned.fill(
              child: FloatingParticles(
                numberOfParticles: 25,
                particleColor: Colors.white24,
              ),
            ),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  
                  // Messages List
                  Expanded(
                    child: _buildMessagesList(),
                  ),
                  
                  // Input Area
                  if (!widget.isFull || widget.chatType == ChatType.friend)
                    _buildInputArea(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.m),
      child: Row(
        children: [
          const UniversalBackButton(),
          const SizedBox(width: AppSpacing.m),
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accentLight,
                  AppColors.accentPrimary,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.chatType == ChatType.lobby
                  ? Icons.casino
                  : (widget.chatType == ChatType.room
                      ? Icons.sports_esports
                      : Icons.person),
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          // Title and Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatName,
                  style: AppTypography.body(context).copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (widget.participants != null)
                  Text(
                    '${widget.participants} participants',
                    style: AppTypography.bodySmall(context).copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          // Spectate button if full
          if (widget.isFull && widget.chatType != ChatType.friend)
            TextButton.icon(
              onPressed: () {
                context.push('/spectate/${widget.chatId}');
              },
              icon: Icon(
                Icons.visibility,
                color: AppColors.goldPrimary,
                size: 18,
              ),
              label: Text(
                'Spectate',
                style: AppTypography.bodySmall(context).copyWith(
                  color: AppColors.goldPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.2, end: 0, duration: 300.ms);
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(AppSpacing.m),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message)
            .animate()
            .fadeIn(delay: (index * 50).ms, duration: 300.ms)
            .slideX(begin: message.isMe ? 0.1 : -0.1, end: 0, duration: 300.ms);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessageDetail message) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.m),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            // Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentLight,
                    AppColors.accentPrimary,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
          ],
          // Message bubble
          Flexible(
            child: GlassCard(
              padding: EdgeInsets.all(AppSpacing.m),
              opacity: message.isMe ? 0.3 : 0.25,
              blurIntensity: 12.0,
              borderColor: message.isMe
                  ? AppColors.goldPrimary
                  : AppColors.cardBorder,
              borderWidth: message.isMe ? 1.5 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isMe)
                    Text(
                      message.username,
                      style: AppTypography.bodySmall(context).copyWith(
                        color: AppColors.accentLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  if (!message.isMe) const SizedBox(height: 4),
                  Text(
                    message.message,
                    style: AppTypography.body(context).copyWith(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: AppTypography.bodySmall(context).copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isMe) ...[
            const SizedBox(width: AppSpacing.s),
            // Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.goldPrimary,
                    AppColors.goldSecondary,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: AppColors.background,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: AppTypography.body(context),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: AppTypography.body(context).copyWith(
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.cardBackground.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.accentLight, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: AppSpacing.s,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          IconButton(
            icon: Icon(Icons.send, color: AppColors.accentLight),
            onPressed: _sendMessage,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.3, end: 0, duration: 400.ms);
  }
}


