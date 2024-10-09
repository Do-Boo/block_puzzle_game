import 'constants.dart';

class GameState {
  final List<List<int>> _grid;
  final List<List<List<int>>> _pieces;
  int _score;

  GameState()
      : _grid = List.generate(Constants.ROWS, (_) => List.filled(Constants.COLS, 0).toList()), // toList() 사용
        _pieces = [],
        _score = 0;

  List<List<int>> get grid => _grid;
  List<List<List<int>>> get pieces => _pieces;
  int get score => _score;

  void addPiece(List<List<int>> piece) {
    _pieces.add(piece);
  }

  bool canPlacePiece(int row, int col, List<List<int>> piece) {
    for (int i = 0; i < piece.length; i++) {
      for (int j = 0; j < piece[i].length; j++) {
        if (piece[i][j] != 0) {
          int newRow = row + i;
          int newCol = col + j;
          if (newRow < 0 || newRow >= Constants.ROWS || newCol < 0 || newCol >= Constants.COLS || _grid[newRow][newCol] != 0) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void placePiece(int row, int col, List<List<int>> piece) {
    for (int i = 0; i < piece.length; i++) {
      for (int j = 0; j < piece[i].length; j++) {
        if (piece[i][j] != 0) {
          _grid[row + i][col + j] = piece[i][j];
        }
      }
    }
    _pieces.remove(piece);
  }

  int checkLines() {
    int linesCleared = 0;

    // 가로 줄 검사
    for (int row = 0; row < Constants.ROWS; row++) {
      bool isFullRow = true;
      for (int col = 0; col < Constants.COLS; col++) {
        if (_grid[row][col] == 0) {
          isFullRow = false;
          break;
        }
      }
      if (isFullRow) {
        linesCleared++;
        for (int col = 0; col < Constants.COLS; col++) {
          _grid[row][col] = 0; // 해당 줄의 조각들만 0으로 설정
        }
      }
    }

    // 세로 줄 검사
    for (int col = 0; col < Constants.COLS; col++) {
      bool isFullCol = true;
      for (int row = 0; row < Constants.ROWS; row++) {
        if (_grid[row][col] == 0) {
          isFullCol = false;
          break;
        }
      }
      if (isFullCol) {
        linesCleared++;
        for (int row = 0; row < Constants.ROWS; row++) {
          _grid[row][col] = 0; // 해당 줄의 조각들만 0으로 설정
        }
      }
    }

    _score += linesCleared * 100;
    return linesCleared;
  }
}
