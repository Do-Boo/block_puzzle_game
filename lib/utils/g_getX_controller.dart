import 'package:block_puzzle_game/mainas.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameController extends GetxController with GetxServiceMixin {
  static const int ROWS = 8;
  static const int COLS = 8;

  var board = List.generate(ROWS, (_) => RxList<int>.filled(COLS, 0)).obs;
  var availablePieces = <PuzzlePiece>[].obs;
  var score = 0.obs;
  var draggedPiece = Rx<PuzzlePiece?>(null);
  var dragPosition = Rx<Offset>(Offset.zero);
  late Size boardSize;

  void setBoardSize(Size size) {
    boardSize = size;
  }

  @override
  void onInit() {
    super.onInit();
    generateNewPieces();
  }

  void updateBoard() {
    board.refresh();
  }

  void generateNewPieces() {
    availablePieces.value = List.generate(3, (_) => PuzzlePiece.random());
  }

  bool canPlacePiece(int row, int col, PuzzlePiece piece) {
    for (int i = 0; i < piece.shape.length; i++) {
      for (int j = 0; j < piece.shape[i].length; j++) {
        if (piece.shape[i][j] != 0) {
          int newRow = row + i;
          int newCol = col + j;
          if (newRow < 0 || newRow >= ROWS || newCol < 0 || newCol >= COLS || board[newRow][newCol] != 0) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void placePiece(int row, int col, PuzzlePiece piece) {
    if (!canPlacePiece(row, col, piece)) {
      Get.snackbar('오류', '이 위치에 조각을 놓을 수 없습니다.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    for (int i = 0; i < piece.shape.length; i++) {
      for (int j = 0; j < piece.shape[i].length; j++) {
        if (piece.shape[i][j] != 0) {
          board[row + i][col + j] = piece.color;
        }
      }
    }
    updateBoard();
    availablePieces.remove(piece);
    if (availablePieces.isEmpty) {
      generateNewPieces();
    }
    checkLines();
    checkGameOver();
    setDraggedPiece(null);
    updateDragPosition(Offset.zero);

    Get.snackbar('성공', '조각이 성공적으로 배치되었습니다!', snackPosition: SnackPosition.BOTTOM);
  }

  void checkLines() {
    int linesCleared = 0;

    // Check rows
    for (int row = 0; row < ROWS; row++) {
      if (board[row].every((cell) => cell != 0)) {
        linesCleared++;
        board[row] = RxList<int>.filled(COLS, 0);
      }
    }

    // Check columns
    for (int col = 0; col < COLS; col++) {
      if (board.every((row) => row[col] != 0)) {
        linesCleared++;
        for (int row = 0; row < ROWS; row++) {
          board[row][col] = 0;
        }
      }
    }

    if (linesCleared > 0) {
      score.value += linesCleared * 100;
      updateBoard();
    }
  }

  bool isGameOver() {
    for (var piece in availablePieces) {
      for (int row = 0; row < ROWS; row++) {
        for (int col = 0; col < COLS; col++) {
          if (canPlacePiece(row, col, piece)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void checkGameOver() {
    if (isGameOver()) {
      Get.defaultDialog(
        title: '게임 오버',
        content: Text('최종 점수: ${score.value}'),
        actions: [
          TextButton(
            child: const Text('다시 시작'),
            onPressed: () {
              Get.back();
              resetGame();
            },
          ),
        ],
      );
    }
  }

  void resetGame() {
    board.value = List.generate(ROWS, (_) => RxList.filled(COLS, 0));
    score.value = 0;
    generateNewPieces();
  }

  void updateDragPosition(Offset position) {
    // AppBar 높이와 보드 위치를 고려하여 보정
    final boardPosition = position - Offset(0, AppBar().preferredSize.height);
    if (boardPosition.dx >= 0 && boardPosition.dx <= boardSize.width && boardPosition.dy >= 0 && boardPosition.dy <= boardSize.height) {
      dragPosition.value = boardPosition;
    }
  }

  void setDraggedPiece(PuzzlePiece? piece) {
    draggedPiece.value = piece;
  }
}
