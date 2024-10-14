import 'package:flutter/material.dart';

extension ColorExtension on Color {
  Color brighten(int amount) {
    return Color.fromARGB(
      alpha,
      (red + amount).clamp(0, 255),
      (green + amount).clamp(0, 255),
      (blue + amount).clamp(0, 255),
    );
  }

  Color darken(int amount) {
    return Color.fromARGB(
      alpha,
      (red - amount).clamp(0, 255),
      (green - amount).clamp(0, 255),
      (blue - amount).clamp(0, 255),
    );
  }
}

class ColorPalette {
  static const Color background = Color(0xFF2C3E50);
  static const Color gridBackground = Color(0xFF34495E);
  static const Color emptyCell = Color(0xFF445566);
  static const Color shadow = Color(0xFF1A2530);
  static const Color highlight = Color(0xFF4A6A8A);

  static const List<Color> blockColors = [
    Color(0xFFE74C3C), // Red
    Color(0xFF3498DB), // Blue
    Color(0xFF2ECC71), // Green
    Color(0xFFF1C40F), // Yellow
    Color(0xFF9B59B6), // Purple
    Color(0xFFE67E22), // Orange
  ];
}
