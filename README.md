# 🎴 Belote Royale - Mauritanian Belote

A Flutter multiplayer card game application with real-money options for iOS and Android.

## 📱 Features

- **Multiplayer Card Game**: Play Mauritanian Belote with 4 players
- **Real-time Gameplay**: Socket.io integration for live multiplayer
- **Wallet System**: Real-money games with 30% platform commission
- **Social Login**: Google and Facebook authentication
- **Profile & Stats**: Track your games, wins, and level progression
- **Beautiful UI**: Custom design system with gold accents and dark theme

## 🎨 Design System

### Colors
- **Background**: Dark blue-purple (#1A1F3A)
- **Accent**: Indigo (#6366F1)
- **Gold**: Highlight color (#FFD700)
- **Table**: Green poker table (#0F5132)

### Typography
- **Headers**: Bebas Neue (Bold, Uppercase)
- **Numbers**: Rajdhani (SemiBold)
- **Body**: Barlow (Regular)
- **Fun Numbers**: Luckiest Guy

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── models/          # Game models (Card, Player, GameState)
│   ├── providers/       # Riverpod state management
│   ├── routing/         # GoRouter configuration
│   ├── services/        # API & Socket.io services
│   ├── theme/           # Colors, typography, spacing
│   └── widgets/         # Reusable components
├── features/
│   ├── auth/            # Login & SignUp screens
│   ├── chat/            # Chat functionality
│   ├── game/            # Game screen (landscape)
│   ├── home/            # Home screen with lobbies
│   ├── lobby/           # Lobby screen
│   └── profile/         # Profile & stats screen
└── main.dart            # App entry point
```

## 🃏 Game Rules

### Deck
- 32 cards (7, 8, 9, 10, J, Q, K, A × 4 suits)
- 4 suits: Spades, Hearts, Diamonds, Clubs
- 8 cards per player (4 players)

### Card Values (Non-Trump)
- 7, 8, 9: 0 points
- J: 2 points
- Q: 3 points
- K: 4 points
- 10: 10 points
- A: 11 points

### Card Values (Trump Suit)
- 7, 8: 0 points
- 9: 14 points
- J: 20 points
- Q: 3 points
- K: 4 points
- 10: 10 points
- A: 11 points

### Game Flow
1. **Bidding Phase**: Minimum bid 80 points
2. **Playing Phase**: 8 tricks, must follow suit
3. **Scoring**: First team to 1000 points wins
4. **Last Trick Bonus**: +10 points

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.10.4 or higher)
- Dart SDK
- iOS/Android development environment

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd mr_belote
```

2. Install dependencies:
```bash
flutter pub get
```

3. Add assets:
   - Place SVG card images in `assets/svg-cards/`
   - Place avatar images in `assets/avatars/`
   - Place logo/images in `assets/images/`

4. Configure backend URLs:
   - Update `lib/core/services/socket_service.dart` with your Socket.io server URL
   - Update `lib/core/services/api_service.dart` with your REST API URL

5. Run the app:
```bash
flutter run
```

## 📦 Dependencies

- **State Management**: `flutter_riverpod`
- **Navigation**: `go_router`
- **Networking**: `socket_io_client`, `dio`
- **UI**: `flutter_svg`, `google_fonts`, `flutter_animate`
- **Auth**: `google_sign_in`, `flutter_facebook_auth`
- **Storage**: `shared_preferences`
- **Forms**: `flutter_form_builder`

## 🎮 Screens

1. **Home Screen**: Header with wallet, promotional carousel, active lobbies
2. **Game Screen**: Landscape orientation with poker table, 4 players, cards
3. **Profile Screen**: Avatar, stats, level progress, store section
4. **Login/SignUp**: Social authentication (Google, Facebook)
5. **Lobby Screen**: Join/create game rooms
6. **Chat Screen**: In-game chat functionality

## 🔌 Backend Integration

### Socket.io Events
- `user_connected`: User connects to server
- `join_room`: Join a game room
- `play_card`: Play a card
- `chat_message`: Send chat message
- `game_state_update`: Receive game state updates

### REST API Endpoints
- `POST /auth/google`: Google sign in
- `POST /auth/facebook`: Facebook sign in
- `GET /users/:id`: Get user profile
- `GET /wallet/:id/balance`: Get wallet balance
- `GET /lobbies/active`: Get active lobbies
- `POST /lobbies`: Create new lobby
- `POST /lobbies/:id/join`: Join a lobby

## 💰 Wallet System

- 30% platform commission on money games
- 70% distribution to winners
- Balance locked during active games
- Transaction tracking

## 📱 Platform Support

- ✅ iOS
- ✅ Android
- ⚠️ Web (partial support)
- ⚠️ Desktop (not optimized)

## 🎯 Next Steps

1. Add SVG card assets to `assets/svg-cards/`
2. Add avatar assets to `assets/avatars/`
3. Configure backend URLs in service files
4. Implement Google/Facebook authentication
5. Add real-time game logic with Socket.io
6. Implement wallet transactions
7. Add animations and polish

## 📄 License

[Add your license here]

## 👥 Contributors

[Add contributors here]
