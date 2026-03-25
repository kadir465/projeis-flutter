import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget customButton({
  required String buttonText,
  required Function() onTap,
  Color startColor = const Color(0xFF6A11CB),
  Color endColor = const Color(0xFF2575FC),
  double borderRadius = 15.0,
  EdgeInsets margin = const EdgeInsets.all(12),
  EdgeInsets padding = const EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 16,
  ),
  double fontSize = 16.0,
  FontWeight fontWeight = FontWeight.bold,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          buttonText,
          style: GoogleFonts.golosText(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: fontWeight,
            letterSpacing: 0.5,
          ),
        ),
      ),
    ),
  );
}
