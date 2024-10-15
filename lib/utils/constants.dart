import 'package:flutter/material.dart';

class Constants {
  static const int ROWS = 8;
  static const int COLS = 8;

  static const List<List<List<int>>> TETROMINOS = [
    [
      [1, 1],
      [1, 1]
    ], // O
    [
      [1, 0],
      [0, 1]
    ], // O
    [
      [0, 1],
      [1, 0]
    ], // O
    [
      [0, 1],
      [1, 1]
    ], // O
    [
      [1, 0],
      [1, 1]
    ], // O
    [
      [1, 1, 1, 1, 1]
    ], // I
    [
      [1, 1, 1, 1]
    ], // I
    [
      [1, 1, 1]
    ], // I
    [
      [1, 1]
    ], // I
    [
      [1, 1, 1],
      [0, 1, 0]
    ], // T
    [
      [1, 1, 1],
      [1, 1, 1]
    ], // T
    [
      [1, 1, 1],
      [1, 0, 0]
    ], // L
    [
      [1, 1, 1],
      [0, 0, 1]
    ], // J
    [
      [1, 1, 0],
      [0, 1, 1]
    ], // S
    [
      [0, 1, 1],
      [1, 1, 0]
    ], // Z
    [
      [1, 1, 1],
      [1, 1, 1],
      [1, 1, 1]
    ], // Z
  ];

  static Color getColor(int value) {
    switch (value) {
      case 1:
        return const Color(0xFF8D6E63); // 갈색 돌
      case 2:
        return const Color(0xFF90A4AE); // 회색 돌
      case 3:
        return const Color(0xFFFFCC80); // 밝은 갈색 돌
      case 4:
        return const Color(0xFFBCAAA4); // 베이지색 돌
      case 5:
        return const Color(0xFF78909C); // 청회색 돌
      default:
        return Colors.white;
    }
  }
}
