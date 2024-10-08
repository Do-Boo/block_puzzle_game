import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

class GameController extends GetxController {
  static const int ROWS = 8;
  static const int COLS = 8;

  var grid = List.generate(ROWS, (_) => List.filled(COLS, 0)).obs;
  var puzzlePieces = <List<List<int>>>[].obs;
  var score = 0.obs;

  var draggedPiece = Rx<List<List<int>>?>(null);
  var previewPiece = Rx<List<List<int>>?>(null);
  var piecePositions = Rx<Offset>(Offset.zero);
  var previewRow = Rx<int?>(null);
  var previewCol = Rx<int?>(null);

  static const List<List<List<int>>> TETROMINOS = [
    [
      [1, 1],
      [1, 1]
    ], // O
    [
      [1, 1, 1, 1]
    ], // I
    [
      [1, 1, 1, 1]
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
    [
      [1],
      [1],
      [1],
      [1],
    ], // Z
  ];

  @override
  void onInit() {
    super.onInit();
    generateNewPuzzlePieces();
    print('Game initialized');
  }

  void generateNewPuzzlePieces() {
    final random = Random();
    puzzlePieces.value = List.generate(3, (_) {
      final tetromino = TETROMINOS[random.nextInt(TETROMINOS.length)];
      final color = random.nextInt(TETROMINOS.length) + 1;
      return tetromino.map((row) => row.map((cell) => cell * color).toList()).toList();
    });
    print('새로운 퍼즐 조각 생성: $puzzlePieces');
  }

  bool canPlacePiece(int row, int col, List<List<int>> piece) {
    for (int i = 0; i < piece.length; i++) {
      for (int j = 0; j < piece[i].length; j++) {
        if (piece[i][j] != 0) {
          int newRow = row + i;
          int newCol = col + j;
          if (newRow < 0 || newRow >= ROWS || newCol < 0 || newCol >= COLS || grid[newRow][newCol] != 0) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void placePiece(int row, int col, List<List<int>> piece) {
    if (!canPlacePiece(row, col, piece)) {
      print('$row 행, $col 열에 조각을 놓을 수 없습니다');
      return;
    }

    for (int i = 0; i < piece.length; i++) {
      for (int j = 0; j < piece[i].length; j++) {
        if (piece[i][j] != 0) {
          grid[row + i][col + j] = piece[i][j];
        }
      }
    }
    print('$row 행, $col 열에 조각을 놓았습니다');
    puzzlePieces.remove(piece);
    if (puzzlePieces.isEmpty) {
      generateNewPuzzlePieces();
    }
    checkLines();
    update();
  }

  void updatePreviewPiecePosition(int touchedRow, int touchedCol) {
    previewRow.value = touchedRow;
    previewCol.value = touchedCol;
    update();
  }

  void checkLines() {
    int linesCleared = 0;

    // Check rows
    for (int row = 0; row < ROWS; row++) {
      if (grid[row].every((cell) => cell != 0)) {
        linesCleared++;
        grid[row] = List.filled(COLS, 0);
      }
    }

    // Check columns
    for (int col = 0; col < COLS; col++) {
      if (grid.every((row) => row[col] != 0)) {
        linesCleared++;
        for (int row = 0; row < ROWS; row++) {
          grid[row][col] = 0;
        }
      }
    }

    if (linesCleared > 0) {
      score.value += linesCleared * 100;
      print('$linesCleared lines cleared. New score: $score');
    }
  }

  Color getColor(int value) {
    switch (value) {
      case 1:
        return const Color(0xFFFF4136); // Red
      case 2:
        return const Color(0xFF0074D9); // Blue
      case 3:
        return const Color(0xFF2ECC40); // Green
      case 4:
        return const Color(0xFFFFDC00); // Yellow
      case 5:
        return const Color(0xFFB10DC9); // Purple
      default:
        return const Color(0xFFFFFFFF); // White
    }
  }
}
