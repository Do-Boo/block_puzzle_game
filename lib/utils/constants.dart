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
    [
      [1, 0, 0],
      [1, 0, 0],
      [1, 1, 1]
    ], // Z
    [
      [0, 0, 1],
      [0, 0, 1],
      [1, 1, 1]
    ], // Z
  ];

  static const Color lightBlue = Color(0xFFA0D8EF); // 밝은 하늘색
  static const Color pastelYellow = Color(0xFFFDF5E6); // 밝은 노란색
  static const Color white = Color(0xFFFFFFFF); // 흰색
  static const Color lightGreen = Color(0xFF98FB98); // 밝은 녹색
  static const Color lightCoral = Color(0xFFF08080); // 밝은 코랄색
  static const Color lightPink = Color(0xFFFFB6C1); // 밝은 핑크색
  static const Color lightPurple = Color(0xFFDDA0DD); // 밝은 보라색

  static Color getColor(int value) {
    switch (value) {
      case 1:
        return lightBlue;
      case 2:
        return pastelYellow;
      case 3:
        return lightGreen;
      case 4:
        return lightCoral;
      case 5:
        return lightPink;
      case 6:
        return lightPurple;
      default:
        return white;
    }
  }
}
