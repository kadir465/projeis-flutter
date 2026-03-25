import 'package:flutter/material.dart';

const String arka_renk = "3E4050";

class AppColors extends Color {
  static int _donustur(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  AppColors(final String renk_kodu) : super(_donustur(renk_kodu));
  
  static const Color primary = Color(0xFF24D876);
  static const Color secondary = Color(0xFF1D1E33);
  static const Color background = Color(0xFF0A0E21);
  static const Color error = Color(0xFFEB1555);
}
