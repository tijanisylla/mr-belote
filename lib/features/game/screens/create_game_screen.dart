import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/floating_particles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/universal_back_button.dart';

class CreateGameScreen extends ConsumerStatefulWidget {
  const CreateGameScreen({super.key});

  @override
  ConsumerState<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends ConsumerState<CreateGameScreen> {
  bool? _selectedMode; // null = not selected, true = free, false = money
  double _minBet = 100;
  int _maxPlayers = 4;
  final TextEditingController _roomNameController = TextEditingController();
  String _roomId = '';

  @override
  void initState() {
    super.initState();
    _generateRoomId();
  }

  String _generateRoomId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = math.Random();
    _roomId = List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
    return _roomId;
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  void _createGame() {
    if (_selectedMode == null) return;
    
    // Navigate to lobby with game settings
    context.push('/lobby', extra: {
      'isNewGame': true,
      'isFree': _selectedMode!,
      'minBet': _selectedMode! ? null : _minBet.toInt(),
      'maxPlayers': _maxPlayers,
      'roomName': _roomNameController.text.isEmpty 
          ? (_selectedMode! ? 'FREE GAME ROOM' : 'MONEY GAME ROOM')
          : _roomNameController.text,
      'gameMode': 'CLASSIC BELOTE',
      'roomId': _roomId,
    });
  }

  void _shareRoomId() {
    Clipboard.setData(ClipboardData(text: _roomId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room ID copied to clipboard: $_roomId'),
        backgroundColor: AppColors.accentPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            const Positioned.fill(
              child: FloatingParticles(
                numberOfParticles: 30,
                particleColor: Colors.white24,
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.m),
                    // Back button
                    const UniversalBackButton(),
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Title
                    Text(
                      'CREATE GAME',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: -0.2, end: 0, duration: 400.ms),
                    
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      'Choose your game mode',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 400.ms),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Room ID Display
                    _buildRoomIdCard()
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideY(begin: -0.2, end: 0, duration: 400.ms),
                    
                    const SizedBox(height: AppSpacing.l),
                    
                    // Mode Selection
                    _buildModeSelection()
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, duration: 400.ms),
                    
                    const SizedBox(height: AppSpacing.l),
                    
                    // Game Settings (only show if mode selected)
                    if (_selectedMode != null) ...[
                      _buildGameSettings()
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.2, end: 0, duration: 400.ms),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    
                    // Create Button
                    if (_selectedMode != null)
                      _buildCreateButton()
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 400.ms)
                          .scale(delay: 300.ms, duration: 400.ms, begin: const Offset(0.9, 0.9)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomIdCard() {
    return GlassCard(
      padding: EdgeInsets.all(AppSpacing.m),
      opacity: 0.25,
      blurIntensity: 15.0,
      borderColor: AppColors.goldPrimary,
      borderWidth: 2,
      child: Column(
        children: [
          Text(
            'ROOM ID',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.goldPrimary, AppColors.goldSecondary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _roomId,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              GestureDetector(
                onTap: _shareRoomId,
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: AppColors.accentPrimary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accentPrimary, width: 2),
                  ),
                  child: Icon(
                    Icons.share,
                    color: AppColors.accentPrimary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Share this ID with friends to join',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelection() {
    return Column(
      children: [
        // Free Game Option
        GestureDetector(
          onTap: () => setState(() => _selectedMode = true),
          child: GlassCard(
            padding: EdgeInsets.all(AppSpacing.l),
            opacity: 0.25,
            blurIntensity: 15.0,
            borderColor: _selectedMode == true ? AppColors.accentPrimary : AppColors.cardBorder,
            borderWidth: _selectedMode == true ? 3 : 1,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accentPrimary, AppColors.accentLight],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.card_giftcard,
                    color: AppColors.textPrimary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                Text(
                  'PLAY FOR FREE',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Practice with virtual chips',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 16, color: AppColors.accentPrimary),
                    const SizedBox(width: 4),
                    Text(
                      'No real money',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: AppSpacing.m),
        
        // Money Game Option
        GestureDetector(
          onTap: () => setState(() => _selectedMode = false),
          child: GlassCard(
            padding: EdgeInsets.all(AppSpacing.l),
            opacity: 0.25,
            blurIntensity: 15.0,
            borderColor: _selectedMode == false ? AppColors.goldPrimary : AppColors.cardBorder,
            borderWidth: _selectedMode == false ? 3 : 1,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.goldPrimary, AppColors.goldSecondary],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.textPrimary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'PLAY FOR REAL',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'PREMIUM',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.background,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Win real MRU prizes',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified, size: 16, color: AppColors.goldPrimary),
                    const SizedBox(width: 4),
                    Text(
                      'Real money rewards',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameSettings() {
    return GlassCard(
      padding: EdgeInsets.all(AppSpacing.l),
      opacity: 0.25,
      blurIntensity: 15.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GAME SETTINGS',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          
          // Room Name
          Text(
            'Room Name (Optional)',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _roomNameController,
            style: GoogleFonts.poppins(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter room name...',
              hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.cardBackground.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.accentPrimary, width: 2),
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.l),
          
          // Min Bet (only for money games)
          if (!_selectedMode!) ...[
            Text(
              'Minimum Bet: ${_minBet.toStringAsFixed(0)} MRU',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Slider(
              value: _minBet,
              min: 50,
              max: 1000,
              divisions: 19,
              activeColor: AppColors.goldPrimary,
              onChanged: (value) => setState(() => _minBet = value),
            ),
            const SizedBox(height: AppSpacing.l),
          ],
          
          // Max Players
          Text(
            'Max Players: $_maxPlayers',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _buildPlayerOption(2, '2/2 Players'),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: _buildPlayerOption(4, '4/4 Players'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerOption(int players, String label) {
    final isSelected = _maxPlayers == players;
    return GestureDetector(
      onTap: () => setState(() => _maxPlayers = players),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.accentPrimary.withValues(alpha: 0.3)
              : AppColors.cardBackground.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accentPrimary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return GestureDetector(
      onTap: _createGame,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _selectedMode!
                ? [AppColors.accentPrimary, AppColors.accentLight]
                : [AppColors.goldPrimary, AppColors.goldSecondary],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (_selectedMode! ? AppColors.accentPrimary : AppColors.goldPrimary)
                  .withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_filled,
              color: AppColors.textPrimary,
              size: 28,
            ),
            const SizedBox(width: AppSpacing.s),
            Text(
              'CREATE GAME',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

