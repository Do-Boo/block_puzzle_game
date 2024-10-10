import 'dart:math';
import 'constants.dart';

class PieceGenerator {
  final Random _random = Random();

  List<List<int>> generatePiece() {
    final tetromino = Constants.TETROMINOS[_random.nextInt(Constants.TETROMINOS.length)];
    final color = _random.nextInt(5) + 1;
    List<List<int>> piece = tetromino.map((row) => row.map((cell) => cell * color).toList()).toList();

    // 무작위로 회전 각도를 선택합니다: 0, 90, 180, 270도
    final rotations = _random.nextInt(4);
    for (int i = 0; i < rotations; i++) {
      piece = rotatePiece(piece);
    }

    return piece;
  }

  List<List<int>> rotatePiece(List<List<int>> piece) {
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
