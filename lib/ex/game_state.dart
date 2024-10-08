import 'package:flutter/material.dart';
import 'dart:math';

class GameState extends ChangeNotifier {
  static const int boardWidth = 10;
  static const int boardHeight = 20;

  List<List<Color?>> board = List.generate(
    boardHeight,
    (_) => List.filled(boardWidth, null),
  );

  List<List<List<bool>>> nextPieces = [];
  List<List<bool>>? currentPiece;
  Color? currentPieceColor;
  int score = 0;
  bool gameOver = false;

  final List<List<List<bool>>> shapes = [
    [
      [true, true],
      [true, true]
    ], // Square
    [
      [true, true, true],
      [false, true, false]
    ], // T
    [
      [true, true, true, true]
    ], // I
    [
      [true, true, false],
      [false, true, true]
    ], // Z
    [
      [false, true, true],
      [true, true, false]
    ], // S
    [
      [true, false, false],
      [true, true, true]
    ], // L
    [
      [false, false, true],
      [true, true, true]
    ], // J
  ];

  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  void startGame() {
    board = List.generate(
      boardHeight,
      (_) => List.filled(boardWidth, null),
    );
    nextPieces = List.generate(3, (_) => _generatePiece());
    currentPiece = null;
    currentPieceColor = null;
    score = 0;
    gameOver = false;
    _getNextPiece();
    notifyListeners();
  }

  List<List<bool>> _generatePiece() {
    return shapes[Random().nextInt(shapes.length)];
  }

  void _getNextPiece() {
    currentPiece = nextPieces.removeAt(0);
    currentPieceColor = colors[Random().nextInt(colors.length)];
    nextPieces.add(_generatePiece());
    notifyListeners();
  }

  bool canPlacePiece(int x, int y) {
    if (currentPiece == null) return false;
    for (int py = 0; py < currentPiece!.length; py++) {
      for (int px = 0; px < currentPiece![py].length; px++) {
        if (currentPiece![py][px]) {
          if (y + py >= boardHeight || x + px < 0 || x + px >= boardWidth || board[y + py][x + px] != null) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void placePiece(int x, int y) {
    if (currentPiece == null || !canPlacePiece(x, y)) return;

    for (int py = 0; py < currentPiece!.length; py++) {
      for (int px = 0; px < currentPiece![py].length; px++) {
        if (currentPiece![py][px]) {
          board[y + py][x + px] = currentPieceColor;
        }
      }
    }

    _checkLines();
    _getNextPiece();

    if (!canPlacePiece(boardWidth ~/ 2 - currentPiece![0].length ~/ 2, 0)) {
      gameOver = true;
    }

    notifyListeners();
  }

  void _checkLines() {
    int linesCleared = 0;
    for (int y = boardHeight - 1; y >= 0; y--) {
      if (board[y].every((cell) => cell != null)) {
        board.removeAt(y);
        board.insert(0, List.filled(boardWidth, null));
        linesCleared++;
      }
    }
    score += linesCleared * 100;
  }
}
