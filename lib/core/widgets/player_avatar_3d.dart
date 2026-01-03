import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class PlayerAvatar3D extends StatelessWidget {
  final String name;
  final String avatarPath;
  final bool isActive;
  final bool isDealer;
  final bool isMuted;
  final bool isSpeaking;
  final double size;

  const PlayerAvatar3D({
    super.key,
    required this.name,
    required this.avatarPath,
    this.isActive = false,
    this.isDealer = false,
    this.isMuted = false,
    this.isSpeaking = false,
    this.size = 70.0,
  });

  @override
  Widget build(BuildContext context) {
    final containerWidth = size * 1.4;
    return SizedBox(
      width: containerWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        // Avatar with 3D ring
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // 3D circular ring with gradient
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isActive
                      ? [
                          const Color(0xFFFFD700), // Gold
                          const Color(0xFFFFA500), // Orange gold
                          const Color(0xFFB8860B), // Dark goldenrod
                        ]
                      : [
                          const Color(0xFF3A4556),
                          const Color(0xFF2C3646),
                          const Color(0xFF1E2530),
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                  if (isActive)
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                ],
              ),
              padding: EdgeInsets.all(size * 0.067),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2C3646),
                  border: Border.all(
                    color: isActive 
                        ? const Color(0xFF1A1F28)
                        : const Color(0xFF1E2530),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: avatarPath.endsWith('.svg')
                      ? SvgPicture.asset(
                          avatarPath,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          avatarPath,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),

            // Dealer badge
            if (isDealer)
              Positioned(
                left: -4,
                top: -2,
                child: Container(
                  width: size * 0.4,
                  height: size * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFD700),
                    border: Border.all(
                      color: const Color(0xFF1A1F28),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'D',
                      style: GoogleFonts.poppins(
                        fontSize: size * 0.2,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1F28),
                      ),
                    ),
                  ),
                ),
              ),

            // Mic indicator badge
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: size * 0.4,
                height: size * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isMuted 
                      ? const Color(0xFF2C3646)
                      : const Color(0xFF3A4556),
                  border: Border.all(
                    color: const Color(0xFF1A1F28),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  size: size * 0.2,
                  color: isMuted 
                      ? Colors.grey[600]
                      : Colors.grey[400],
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: size * 0.08),

        // Name plate
        Container(
          padding: EdgeInsets.symmetric(horizontal: size * 0.17, vertical: size * 0.08),
          decoration: BoxDecoration(
            color: const Color(0xFF0B0F14).withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? const Color(0xFFFFD700).withOpacity(0.8)
                  : Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: size * 0.17,
              fontWeight: FontWeight.bold,
              color: isActive 
                  ? const Color(0xFFFFD700)
                  : Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
      ),
    );
  }
}

