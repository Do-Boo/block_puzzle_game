import 'dart:math';
import 'package:block_puzzle_game/utils/constants.dart';
import 'package:block_puzzle_game/utils/game_state.dart';

class PieceGenerator {
  final Random _random = Random();

  List<List<List<int>>> generatePieces(GameState gameState) {
    List<List<List<int>>> pieces = [];
    int attempts = 0;
    while (pieces.length < 3 && attempts < 100) {
      final piece = _generateSinglePiece();
      if (_canPlacePieceAnywhere(gameState, piece)) {
        pieces.add(piece);
      }
      attempts++;
    }
    return pieces;
  }

  List<List<int>> _generateSinglePiece() {
    final tetromino = Constants.TETROMINOS[_random.nextInt(Constants.TETROMINOS.length)];
    final color = _random.nextInt(5) + 1; // 1 to 5
    List<List<int>> piece = tetromino.map((row) => row.map((cell) => cell * color).toList()).toList();

    // 무작위로 회전 적용
    final rotations = _random.nextInt(4);
    for (int i = 0; i < rotations; i++) {
      piece = _rotatePiece(piece);
    }

    return piece;
  }

  bool _canPlacePieceAnywhere(GameState gameState, List<List<int>> piece) {
    for (int row = 0; row <= Constants.ROWS - piece.length; row++) {
      for (int col = 0; col <= Constants.COLS - piece[0].length; col++) {
        if (gameState.canPlacePiece(row, col, piece)) {
          return true;
        }
      }
    }
    return false;
  }

  List<List<int>> _rotatePiece(List<List<int>> piece) {
    final int n = piece.length;
    final int m = piece[0].length;
    List<List<int>> rotated = List.generate(m, (_) => List.filled(n, 0));

    for (int i = 0; i < n; i++) {
      for (int j = 0; j < m; j++) {
        rotated[j][n - i - 1] = piece[i][j];
      }
    }
    return rotated;
  }
}
