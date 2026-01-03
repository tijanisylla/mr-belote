import 'package:go_router/go_router.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/game/screens/game_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/auth/screens/unified_auth_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/chat/screens/chat_detail_screen.dart';
import '../../features/chat/screens/spectator_screen.dart';
import '../../features/chat/models/chat_models.dart';
import '../../features/lobby/screens/lobby_screen.dart' as lobby_module;
import '../../features/welcome/screens/landing_screen.dart';
import '../../features/welcome/screens/mode_selection_screen.dart';
import '../../features/setup/screens/user_setup_screen.dart';
import '../../features/setup/screens/profile_preview_screen.dart';
import '../../features/game/screens/create_game_screen.dart';
import 'app_shell.dart';

// Helper to parse ChatType
ChatType _parseChatType(dynamic type) {
  if (type is ChatType) return type;
  if (type is String) {
    if (type.contains('lobby')) return ChatType.lobby;
    if (type.contains('room')) return ChatType.room;
  }
  return ChatType.friend;
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Landing screen (first screen)
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),
    // Create game screen
    GoRoute(
      path: '/create-game',
      builder: (context, state) => const CreateGameScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const UnifiedAuthScreen(initialTabIsSignUp: false),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const UnifiedAuthScreen(initialTabIsSignUp: true),
    ),
    
    // User setup flow
    GoRoute(
      path: '/setup',
      builder: (context, state) => const UserSetupScreen(),
    ),
    GoRoute(
      path: '/profile-preview',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ProfilePreviewScreen(profileData: extra ?? {});
      },
    ),
    
    // Main app routes with bottom navigation
    ShellRoute(
      builder: (context, state, child) {
        // Determine current index based on route
        int currentIndex = 0;
        final location = state.uri.path;
        if (location == '/home') {
          currentIndex = 0;
        } else if (location == '/chat') {
          currentIndex = 1;
        } else if (location == '/lobby') {
          currentIndex = 2;
        } else if (location == '/profile') {
          currentIndex = 4;
        }
        
        return AppShell(
          currentIndex: currentIndex,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => const ChatScreen(),
        ),
        GoRoute(
          path: '/lobby',
          builder: (context, state) {
            // Store extras for lobby screen to read
            if (state.extra != null && state.extra is Map<String, dynamic>) {
              lobby_module.setLobbyRouteData(state.extra as Map<String, dynamic>);
            }
            return const lobby_module.LobbyScreen();
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    
    // Game route (no bottom nav, full screen)
    GoRoute(
      path: '/game',
      builder: (context, state) => const GameScreen(),
    ),
    
    // Chat detail route
    GoRoute(
      path: '/chat/:chatId',
      builder: (context, state) {
        final chatId = state.pathParameters['chatId']!;
        final extra = state.extra as Map<String, dynamic>?;
        
        return ChatDetailScreen(
          chatId: chatId,
          chatName: extra?['name'] ?? 'Chat',
          chatType: _parseChatType(extra?['type']),
          participants: extra?['participants'] as int?,
          isFull: extra?['isFull'] ?? false,
        );
      },
    ),
    
    // Spectator route
    GoRoute(
      path: '/spectate/:roomId',
      builder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        // In a real app, you'd fetch room details from the backend
        return SpectatorScreen(
          roomId: roomId,
          roomName: 'VIP Room #247',
          participants: 4,
        );
      },
    ),
  ],
);
