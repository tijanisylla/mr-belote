import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full splash screen image
          Image.asset(
            'assets/images/SplashScreen_img.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFF0F1419),
                child: Center(
                  child: Icon(
                    Icons.casino,
                    size: 100,
                    color: AppColors.goldPrimary,
                  ),
                ),
              );
            },
          )
              .animate()
              .fadeIn(duration: 600.ms),
          
          // Loading indicator overlay
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
                strokeWidth: 3,
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 600.ms),
            ),
          ),
        ],
      ),
    );
  }
}

