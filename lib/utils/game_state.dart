import 'constants.dart';

class GameState {
  late List<List<int>> _grid;
  final List<List<List<int>>> _pieces;
  int _score;
  int _consecutiveClears = 0;

  GameState()
      : _grid = List.generate(Constants.ROWS, (_) => List.filled(Constants.COLS, 0).toList()),
        _pieces = [],
        _score = 0,
        _consecutiveClears = 0 {
    initializeGrid();
  }

  List<List<int>> get grid => _grid;
  List<List<List<int>>> get pieces => _pieces;
  int get score => _score;

  void initializeGrid() {
    _grid = List.generate(
      Constants.ROWS,
      (_) => List.filled(Constants.COLS, 0),
    );
  }

  void addPiece(List<List<int>> piece) {
    _pieces.add(piece);
  }

  bool canPlaceAnyPiece() {
    for (var piece in _pieces) {
      for (int row = 0; row <= Constants.ROWS - piece.length; row++) {
        for (int col = 0; col <= Constants.COLS - piece[0].length; col++) {
          if (canPlacePiece(row, col, piece)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool canPlacePiece(int row, int col, List<List<int>> piece) {
    if (row < 0 || col < 0 || row + piece.length > Constants.ROWS || col + piece[0].length > Constants.COLS) {
      return false;
    }
    for (int i = 0; i < piece.length; i++) {
      for (int j = 0; j < piece[i].length; j++) {
        if (piece[i][j] != 0 && _grid[row + i][col + j] != 0) {
          return false;
        }
      }
    }
    return true;
  }

  List<int> getLinesToClear() {
    List<int> linesToClear = [];

    // 가로 줄 체크
    for (int row = 0; row < Constants.ROWS; row++) {
      if (isFullRow(row)) {
        linesToClear.add(row);
      }
    }

    // 세로 줄 체크
    for (int col = 0; col < Constants.COLS; col++) {
      if (isFullColumn(col)) {
        linesToClear.add(Constants.ROWS + col); // 세로 줄은 ROWS를 더해서 구분
      }
    }

    return linesToClear;
  }

  bool isFullRow(int row) {
    if (row < 0 || row >= Constants.ROWS) return false;
    return _grid[row].every((cell) => cell != 0);
  }

  bool isFullColumn(int col) {
    if (col < 0 || col >= Constants.COLS) return false;
    return _grid.every((row) => row[col] != 0);
  }

  int placePiece(int row, int col, List<List<int>> piece) {
    int pieceScore = 0;
    for (int i = 0; i < piece.length; i++) {
      for (int j = 0; j < piece[i].length; j++) {
        if (piece[i][j] != 0) {
          _grid[row + i][col + j] = piece[i][j];
          pieceScore += 20; // 각 블록당 10점
        }
      }
    }
    _score += pieceScore;
    _pieces.remove(piece);
    return pieceScore;
  }

  int checkLines() {
    List<int> linesToClear = getLinesToClear();
    int linesCleared = linesToClear.length;
    int lineScore = 0;

    for (int line in linesToClear) {
      if (line < Constants.ROWS) {
        // 가로 줄 지우기
        for (int col = 0; col < Constants.COLS; col++) {
          _grid[line][col] = 0;
          lineScore += 10; // 한 칸 당 10점
        }
      } else {
        // 세로 줄 지우기
        int col = line - Constants.ROWS;
        for (int row = 0; row < Constants.ROWS; row++) {
          _grid[row][col] = 0;
          lineScore += 10; // 한 칸 당 10점
        }
      }
    }

    if (linesCleared > 0) {
      _consecutiveClears++;
      lineScore += linesCleared * 10 * _consecutiveClears; // 연속 성공 시 추가 점수
    } else {
      _consecutiveClears = 0; // 연속 성공이 끊기면 초기화
    }

    _score += lineScore;
    return linesCleared;
  }

  void clearGrid() {
    for (int row = 0; row < Constants.ROWS; row++) {
      for (int col = 0; col < Constants.COLS; col++) {
        _grid[row][col] = 0;
      }
    }
    print('Grid cleared in GameState. Current grid: $_grid'); // 디버그 로그 추가
  }

  void resetGrid() {
    initializeGrid();
    print('Grid reset in GameState. Current grid: $_grid'); // 디버그 로그
  }
}
