import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/floating_particles.dart';
import '../../../core/widgets/glass_card.dart';
import '../models/chat_models.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String _selectedFilter = 'ALL';
  final TextEditingController _searchController = TextEditingController();

  // Mock messages data
  final List<ChatMessage> _allMessages = [
    ChatMessage(
      id: '1',
      name: 'VIP Room #247',
      type: ChatType.lobby,
      avatar: Icons.casino,
      lastMessage: 'Ahmed: Good game everyone!',
      timestamp: '2m ago',
      unreadCount: 3,
      participants: 4, // Full lobby - can spectate
      isOnline: false,
    ),
    ChatMessage(
      id: '2',
      name: 'Fatima',
      type: ChatType.friend,
      avatar: Icons.person,
      lastMessage: 'Want to play another round?',
      timestamp: '5m ago',
      unreadCount: 1,
      participants: null,
      isOnline: true,
    ),
    ChatMessage(
      id: '3',
      name: 'Mauritanian Belote Players',
      type: ChatType.room,
      avatar: Icons.sports_esports,
      lastMessage: 'Hassan: Anyone for a tournament?',
      timestamp: '15m ago',
      unreadCount: 0,
      participants: 2, // Full room (2/2) - can spectate
      isOnline: false,
    ),
    ChatMessage(
      id: '4',
      name: 'Ahmed',
      type: ChatType.friend,
      avatar: Icons.person,
      lastMessage: 'Thanks for the game!',
      timestamp: '1h ago',
      unreadCount: 0,
      participants: null,
      isOnline: true,
    ),
    ChatMessage(
      id: '5',
      name: 'High Rollers Club',
      type: ChatType.room,
      avatar: Icons.workspace_premium,
      lastMessage: 'Omar: Big tournament tonight!',
      timestamp: '2h ago',
      unreadCount: 5,
      participants: 45,
      isOnline: false,
    ),
    ChatMessage(
      id: '6',
      name: 'Mariam',
      type: ChatType.friend,
      avatar: Icons.person,
      lastMessage: 'Great moves today!',
      timestamp: '3h ago',
      unreadCount: 0,
      participants: null,
      isOnline: false,
    ),
    ChatMessage(
      id: '7',
      name: 'Classic Belote Lobby',
      type: ChatType.lobby,
      avatar: Icons.casino,
      lastMessage: 'Welcome to the lobby!',
      timestamp: '4h ago',
      unreadCount: 0,
      participants: 8,
      isOnline: false,
    ),
  ];

  List<ChatMessage> get _filteredMessages {
    if (_selectedFilter == 'ALL') return _allMessages;
    return _allMessages.where((msg) {
      switch (_selectedFilter) {
        case 'LOBBIES':
          return msg.type == ChatType.lobby;
        case 'FRIENDS':
          return msg.type == ChatType.friend;
        case 'ROOMS':
          return msg.type == ChatType.room;
        default:
          return true;
      }
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                  // Header Section
                  _buildHeader(),
                  
                  // Filter Tabs
                  _buildFilterTabs(),
                  
                  // Messages List
                  Expanded(
                    child: _buildMessagesList(),
                  ),
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
          // Title
          Text(
            'MESSAGES',
            style: AppTypography.h1(context).copyWith(
              color: AppColors.goldPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          // Search Bar
          Expanded(
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.cardBackground.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.cardBorder,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.body(context).copyWith(
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search messages...',
                        hintStyle: AppTypography.body(context).copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          // Add Friend Button
          IconButton(
            icon: Icon(
              Icons.person_add,
              color: AppColors.textPrimary,
              size: 24,
            ),
            onPressed: () {
              // TODO: Open add friend dialog
            },
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.2, end: 0, duration: 300.ms);
  }

  Widget _buildFilterTabs() {
    final filters = ['ALL', 'LOBBIES', 'FRIENDS', 'ROOMS'];
    
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          
          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.s),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedFilter = filter);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: AppSpacing.s,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [
                            AppColors.accentPrimary,
                            AppColors.accentLight,
                          ],
                        )
                      : null,
                  color: isSelected ? null : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentLight
                        : AppColors.cardBorder,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: AppTypography.body(context).copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 300.ms)
        .slideX(begin: -0.2, end: 0, duration: 300.ms);
  }

  Widget _buildMessagesList() {
    final messages = _filteredMessages;
    
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'No messages found',
          style: AppTypography.body(context).copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.m),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageCard(message)
            .animate()
            .fadeIn(delay: (index * 50).ms, duration: 300.ms)
            .slideX(begin: -0.1, end: 0, duration: 300.ms);
      },
    );
  }

  Widget _buildMessageCard(ChatMessage message) {
    final isFull = message.participants != null && 
                   ((message.type == ChatType.lobby && message.participants == 4) ||
                    (message.type == ChatType.room && message.participants == 2));
    
    return GestureDetector(
      onTap: () {
        if (isFull && message.type != ChatType.friend) {
          // Navigate to spectator mode for full rooms/lobbies
          context.push('/spectate/${message.id}');
        } else {
          // Navigate to chat detail
          context.push('/chat/${message.id}', extra: {
            'name': message.name,
            'type': message.type,
            'participants': message.participants,
            'isFull': isFull,
          });
        }
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.m),
        child: GlassCard(
          padding: EdgeInsets.all(AppSpacing.m),
          opacity: 0.25,
          blurIntensity: 12.0,
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
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
                      message.avatar,
                      color: AppColors.textPrimary,
                      size: 30,
                    ),
                  ),
                  // Unread Badge
                  if (message.unreadCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Center(
                          child: Text(
                            '${message.unreadCount}',
                            style: AppTypography.bodySmall(context).copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Online Status (for friends)
                  if (message.isOnline && message.type == ChatType.friend)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.background,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.m),
              // Message Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message.name,
                            style: AppTypography.body(context).copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Type Tag
                        if (message.type != ChatType.friend)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            margin: EdgeInsets.only(left: AppSpacing.xs),
                            decoration: BoxDecoration(
                              gradient: message.type == ChatType.lobby
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.goldPrimary,
                                        AppColors.goldSecondary,
                                      ],
                                    )
                                  : LinearGradient(
                                      colors: [
                                        AppColors.accentPrimary,
                                        AppColors.accentLight,
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              message.type == ChatType.lobby ? 'LOBBY' : 'ROOM',
                              style: AppTypography.bodySmall(context).copyWith(
                                color: AppColors.background,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.lastMessage,
                      style: AppTypography.bodySmall(context).copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Timestamp & Participants
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.timestamp,
                    style: AppTypography.bodySmall(context).copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                  if (message.participants != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people,
                          color: AppColors.textSecondary,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${message.participants}',
                          style: AppTypography.bodySmall(context).copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

