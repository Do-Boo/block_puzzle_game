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
  ];

  static Color getColor(int value) {
    switch (value) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      case 4:
        return Colors.yellow;
      case 5:
        return Colors.purple;
      default:
        return Colors.white;
    }
  }
}
