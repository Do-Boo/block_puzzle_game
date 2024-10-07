import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const BlockPuzzleApp());

class BlockPuzzleApp extends StatelessWidget {
  const BlockPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Block Puzzle',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int ROWS = 8;
  static const int COLS = 8;
  List<List<int>> grid = List.generate(ROWS, (_) => List.filled(COLS, 0));
  List<List<List<int>>> puzzlePieces = [];
  int score = 0;

  // 드래그 중인 조각 정보를 저장하는 변수 추가
  List<List<int>>? draggedPiece;
  int? draggedRow;
  int? draggedCol;

  // 미리보기 조각 정보를 저장하는 변수 추가
  List<List<int>>? previewPiece;
  int? previewRow;
  int? previewCol;

  // 테트리스 조각 모양 정의
  static const List<List<List<int>>> TETROMINOS = [
    [
      [1, 1],
      [1, 1]
    ], // O
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
  ];

  @override
  void initState() {
    super.initState();
    generateNewPuzzlePieces();
    print('Game initialized');
  }

  void generateNewPuzzlePieces() {
    final random = Random();
    puzzlePieces = List.generate(3, (_) {
      final tetromino = TETROMINOS[random.nextInt(TETROMINOS.length)];
      final color = random.nextInt(5) + 1;
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

    setState(() {
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
    });
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
      score += linesCleared * 100;
      print('$linesCleared lines cleared. New score: $score');
    }
  }

  @override
  Widget build(BuildContext context) {
    double cellSize = MediaQuery.of(context).size.width / COLS;
    double previewCellSize = cellSize * 0.6;
    double dragOffsetY = 150; // 드래그된 조각의 상단 오프셋

    return Scaffold(
      appBar: AppBar(title: const Text('Block Puzzle')),
      body: Column(
        children: [
          Text('Score: $score', style: const TextStyle(fontSize: 24)),
          Expanded(
            child: DragTarget<List<List<int>>>(
              onWillAcceptWithDetails: (data) => true,
              onAcceptWithDetails: (data) {
                if (previewRow != null && previewCol != null) {
                  placePiece(previewRow!, previewCol!, data.data);
                }
              },
              builder: (context, candidateData, rejectedData) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: COLS,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: ROWS * COLS,
                  itemBuilder: (context, index) {
                    int row = index ~/ COLS;
                    int col = index % COLS;
                    return Container(
                      decoration: BoxDecoration(
                        color: _getCellColor(row, col),
                        border: Border.all(color: Colors.black),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(
            height: previewCellSize * 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: puzzlePieces
                  .map((piece) => Draggable<List<List<int>>>(
                        data: piece,
                        feedback: Transform.translate(
                          offset: Offset(-piece[0].length.toDouble() * cellSize / 2, -150),
                          child: PieceWidget(piece: piece, cellSize: cellSize),
                        ),
                        childWhenDragging: Container(),
                        onDragStarted: () {
                          setState(() {
                            draggedPiece = piece;
                          });
                        },
                        onDragUpdate: (details) {
                          final RenderBox renderBox = context.findRenderObject() as RenderBox;
                          final localPosition = renderBox.globalToLocal(details.globalPosition);
                          setState(() {
                            // 그리드 상의 행과 열 계산
                            int pieceRows = draggedPiece!.length;
                            int pieceCols = draggedPiece![0].length;
                            previewRow = ((localPosition.dy - 300) / cellSize).floor();
                            previewCol = ((localPosition.dx - (pieceCols * cellSize) / 2) / cellSize).floor();
                            previewPiece = draggedPiece;
                          });
                        },
                        onDragEnd: (details) {
                          setState(() {
                            draggedPiece = null;
                            previewPiece = null;
                            previewRow = null;
                            previewCol = null;
                          });
                        },
                        child: PieceWidget(piece: piece, cellSize: previewCellSize),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCellColor(int row, int col) {
    if (previewPiece != null &&
        row >= previewRow! &&
        row < previewRow! + previewPiece!.length &&
        col >= previewCol! &&
        col < previewCol! + previewPiece![0].length) {
      int pieceRow = row - previewRow!;
      int pieceCol = col - previewCol!;
      if (pieceRow >= 0 && pieceRow < previewPiece!.length && pieceCol >= 0 && pieceCol < previewPiece![0].length && previewPiece![pieceRow][pieceCol] != 0) {
        return _getColor(previewPiece![pieceRow][pieceCol]).withOpacity(0.5);
      }
    }
    return _getColor(grid[row][col]);
  }

  Color _getColor(int value) {
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

class PieceWidget extends StatelessWidget {
  final List<List<int>> piece;
  final double cellSize;

  const PieceWidget({super.key, required this.piece, required this.cellSize});

  @override
  Widget build(BuildContext context) {
    int rows = piece.length;
    int cols = piece[0].length;
    return SizedBox(
      width: cellSize * cols,
      height: cellSize * rows,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: piece
            .map((row) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row
                      .map((cell) => Container(
                            width: cellSize,
                            height: cellSize,
                            decoration: BoxDecoration(
                              color: cell != 0 ? _getColor(cell) : Colors.transparent,
                              border: cell != 0 ? Border.all(color: Colors.black) : null,
                            ),
                          ))
                      .toList(),
                ))
            .toList(),
      ),
    );
  }

  Color _getColor(int value) {
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
