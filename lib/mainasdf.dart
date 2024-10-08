import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

void main() => runApp(const BlockPuzzleApp());

class BlockPuzzleApp extends StatelessWidget {
  const BlockPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Block Puzzle',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GameScreen(),
    );
  }
}

class GameController extends GetxController {
  static const int ROWS = 8;
  static const int COLS = 8;

  final grid = List.generate(ROWS, (_) => List.filled(COLS, 0).obs).obs;
  final puzzlePieces = <List<List<int>>>[].obs;
  final score = 0.obs;

  final draggedPiece = Rxn<List<List<int>>>();
  final previewPiece = Rxn<List<List<int>>>();
  final previewRow = RxnInt();
  final previewCol = RxnInt();

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
  void onInit() {
    super.onInit();
    generateNewPuzzlePieces();
    print('Game initialized');
  }

  void generateNewPuzzlePieces() {
    final random = Random();
    puzzlePieces.value = List.generate(3, (_) {
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

  void checkLines() {
    int linesCleared = 0;

    // Check rows
    for (int row = 0; row < ROWS; row++) {
      if (grid[row].every((cell) => cell != 0)) {
        linesCleared++;
        grid[row] = List.filled(COLS, 0).obs;
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
      print('$linesCleared lines cleared. New score: ${score.value}');
    }
  }

  Color getCellColor(int row, int col) {
    if (previewPiece.value != null &&
        row >= previewRow.value! &&
        row < previewRow.value! + previewPiece.value!.length &&
        col >= previewCol.value! &&
        col < previewCol.value! + previewPiece.value![0].length) {
      int pieceRow = row - previewRow.value!;
      int pieceCol = col - previewCol.value!;
      if (pieceRow >= 0 &&
          pieceRow < previewPiece.value!.length &&
          pieceCol >= 0 &&
          pieceCol < previewPiece.value![0].length &&
          previewPiece.value![pieceRow][pieceCol] != 0) {
        return getColor(previewPiece.value![pieceRow][pieceCol]).withOpacity(0.5);
      }
    }
    return getColor(grid[row][col]);
  }

  Color getColor(int value) {
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

class GameScreen extends GetView<GameController> {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameController = Get.put(GameController());
    double cellSize = MediaQuery.of(context).size.width / GameController.COLS;
    double previewCellSize = cellSize * 0.6;

    return Scaffold(
      appBar: AppBar(title: const Text('Block Puzzle')),
      body: Column(
        children: [
          Obx(() => Text('Score: ${gameController.score}', style: const TextStyle(fontSize: 24))),
          Expanded(
            child: DragTarget<List<List<int>>>(
              onWillAcceptWithDetails: (data) => true,
              onAcceptWithDetails: (data) {
                if (gameController.previewRow.value != null && gameController.previewCol.value != null) {
                  gameController.placePiece(gameController.previewRow.value!, gameController.previewCol.value!, data.data);
                }
              },
              builder: (context, candidateData, rejectedData) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: GameController.COLS,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: GameController.ROWS * GameController.COLS,
                  itemBuilder: (context, index) {
                    int row = index ~/ GameController.COLS;
                    int col = index % GameController.COLS;
                    return Container(
                      decoration: BoxDecoration(
                        color: gameController.getCellColor(row, col),
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
            child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: gameController.puzzlePieces
                      .map((piece) => Draggable<List<List<int>>>(
                            data: piece,
                            feedback: Transform.translate(
                              offset: Offset(-piece[0].length.toDouble() * cellSize / 2, -150),
                              child: PieceWidget(piece: piece, cellSize: cellSize),
                            ),
                            childWhenDragging: Container(),
                            onDragStarted: () {
                              gameController.draggedPiece.value = piece;
                            },
                            onDragUpdate: (details) {
                              final RenderBox renderBox = context.findRenderObject() as RenderBox;
                              final localPosition = renderBox.globalToLocal(details.globalPosition);
                              int pieceRows = gameController.draggedPiece.value!.length;
                              int pieceCols = gameController.draggedPiece.value![0].length;
                              gameController.previewRow.value = ((localPosition.dy - 300) / cellSize).floor();
                              gameController.previewCol.value = ((localPosition.dx - (pieceCols * cellSize) / 2) / cellSize).floor();
                              gameController.previewPiece.value = gameController.draggedPiece.value;
                            },
                            onDragEnd: (details) {
                              gameController.draggedPiece.value = null;
                              gameController.previewPiece.value = null;
                              gameController.previewRow.value = null;
                              gameController.previewCol.value = null;
                            },
                            child: PieceWidget(piece: piece, cellSize: previewCellSize),
                          ))
                      .toList(),
                )),
          ),
        ],
      ),
    );
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
                              color: cell != 0 ? Get.find<GameController>().getColor(cell) : Colors.transparent,
                              border: cell != 0 ? Border.all(color: Colors.black) : null,
                            ),
                          ))
                      .toList(),
                ))
            .toList(),
      ),
    );
  }
}
