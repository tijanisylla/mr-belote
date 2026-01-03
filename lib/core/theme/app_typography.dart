import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system for Belote Royale
class AppTypography {
  // Headers - Bebas Neue (Bold, Uppercase)
  static TextStyle h1(BuildContext context) => GoogleFonts.bebasNeue(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.2,
      );
  
  static TextStyle h2(BuildContext context) => GoogleFonts.bebasNeue(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.0,
      );
  
  static TextStyle h3(BuildContext context) => GoogleFonts.bebasNeue(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.8,
      );
  
  // Numbers - Rajdhani
  static TextStyle largeNumber(BuildContext context) => GoogleFonts.rajdhani(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );
  
  static TextStyle mediumNumber(BuildContext context) => GoogleFonts.rajdhani(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );
  
  // Body Text - Barlow
  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.barlow(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      );
  
  static TextStyle body(BuildContext context) => GoogleFonts.barlow(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      );
  
  static TextStyle bodySmall(BuildContext context) => GoogleFonts.barlow(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      );
  
  static TextStyle label(BuildContext context) => GoogleFonts.barlow(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        letterSpacing: 0.5,
      );
  
  // Fun Numbers - Luckiest Guy
  static TextStyle chipCount(BuildContext context) => GoogleFonts.luckiestGuy(
        fontSize: 24,
        color: Colors.white,
      );
}



