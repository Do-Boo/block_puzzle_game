import 'dart:math';
import 'constants.dart';

class PieceGenerator {
  final Random _random = Random();

  List<List<int>> generatePiece() {
    final tetromino = Constants.TETROMINOS[_random.nextInt(Constants.TETROMINOS.length)];
    final color = _random.nextInt(5) + 1;
    return tetromino.map((row) => row.map((cell) => cell * color).toList()).toList();
  }
}
