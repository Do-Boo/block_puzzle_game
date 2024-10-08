import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

void main() => runApp(const BlockPuzzleApp());

class GameConfig {
  static const int ROWS = 8;
  static const int COLS = 8;
  static const Map<int, Color> COLOR_MAP = {
    0: Colors.white,
    1: Colors.red,
    2: Colors.blue,
    3: Colors.green,
    4: Colors.yellow,
    5: Colors.purple,
  };
}

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

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GameController());
    return Scaffold(
      appBar: AppBar(title: const Text('Block Puzzle')),
      body: Column(
        children: [
          Obx(() => Text('Score: ${controller.score}', style: const TextStyle(fontSize: 24))),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: GameConfig.COLS,
                childAspectRatio: 1.0,
              ),
              itemCount: GameConfig.ROWS * GameConfig.COLS,
              itemBuilder: (context, index) {
                int row = index ~/ GameConfig.COLS;
                int col = index % GameConfig.COLS;
                return Obx(() => GridCell(value: controller.grid[row][col]));
              },
            ),
          ),
          SizedBox(
            height: 100,
            child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: controller.puzzlePieces
                      .map((piece) => DraggablePiece(
                            piece: piece,
                            onDragStarted: () => controller.onDragStarted(piece),
                            onDragUpdate: (details) => controller.onDragUpdate(details, context),
                            onDragEnd: (details) => controller.onDragEnd(details, context),
                          ))
                      .toList(),
                )),
          ),
        ],
      ),
    );
  }
}

class GameController extends GetxController {
  var grid = List.generate(GameConfig.ROWS, (_) => RxList<int>.filled(GameConfig.COLS, 0)).obs;
  var score = 0.obs;
  var puzzlePieces = <List<List<int>>>[].obs;

  Rx<List<List<int>>?> draggedPiece = Rx<List<List<int>>?>(null);
  Rx<int?> previewRow = Rx<int?>(null);
  Rx<int?> previewCol = Rx<int?>(null);

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
  }

  void generateNewPuzzlePieces() {
    final random = Random();
    puzzlePieces.value = List.generate(3, (_) {
      final tetromino = TETROMINOS[random.nextInt(TETROMINOS.length)];
      final color = random.nextInt(5) + 1;
      return tetromino.map((row) => row.map((cell) => cell * color).toList()).toList();
    });
  }

  bool canPlacePiece(int row, int col, List<List<int>> piece) {
    for (int i = 0; i < piece.length; i++) {
      for (int j = 0; j < piece[i].length; j++) {
        if (piece[i][j] != 0) {
          int newRow = row + i;
          int newCol = col + j;
          if (newRow < 0 || newRow >= GameConfig.ROWS || newCol < 0 || newCol >= GameConfig.COLS || grid[newRow][newCol] != 0) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void placePiece(int row, int col, List<List<int>> piece) {
    if (!canPlacePiece(row, col, piece)) {
      return;
    }

    for (int i = 0; i < piece.length; i++) {
      for (int j = 0; j < piece[i].length; j++) {
        if (piece[i][j] != 0) {
          grid[row + i][col + j] = piece[i][j];
        }
      }
    }
    grid.refresh();

    puzzlePieces.remove(piece);
    if (puzzlePieces.isEmpty) {
      generateNewPuzzlePieces();
    }

    checkLines();
  }

  void checkLines() {
    int linesCleared = 0;

    // Check rows
    for (int row = 0; row < GameConfig.ROWS; row++) {
      if (grid[row].every((cell) => cell != 0)) {
        linesCleared++;
        grid[row] = RxList<int>.filled(GameConfig.COLS, 0);
      }
    }

    // Check columns
    for (int col = 0; col < GameConfig.COLS; col++) {
      if (grid.every((row) => row[col] != 0)) {
        linesCleared++;
        for (int row = 0; row < GameConfig.ROWS; row++) {
          grid[row][col] = 0;
        }
      }
    }

    if (linesCleared > 0) {
      score.value += linesCleared * 100;
    }

    grid.refresh();
  }

  void onDragStarted(List<List<int>> piece) {
    draggedPiece.value = piece;
  }

  void onDragUpdate(DragUpdateDetails details, BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    int row = ((localPosition.dy - 150) / (renderBox.size.width / GameConfig.COLS)).floor();
    int col = (localPosition.dx / (renderBox.size.width / GameConfig.COLS)).floor();

    previewRow.value = row;
    previewCol.value = col;

    // Update grid with preview
    updateGridWithPreview();
  }

  void onDragEnd(DraggableDetails details, BuildContext context) {
    if (previewRow.value != null && previewCol.value != null && draggedPiece.value != null) {
      placePiece(previewRow.value!, previewCol.value!, draggedPiece.value!);
    }
    draggedPiece.value = null;
    previewRow.value = null;
    previewCol.value = null;
    clearPreview();
  }

  void updateGridWithPreview() {
    if (previewRow.value != null && previewCol.value != null && draggedPiece.value != null) {
      clearPreview();
      for (int i = 0; i < draggedPiece.value!.length; i++) {
        for (int j = 0; j < draggedPiece.value![i].length; j++) {
          if (draggedPiece.value![i][j] != 0) {
            int newRow = previewRow.value! + i;
            int newCol = previewCol.value! + j;
            if (newRow >= 0 && newRow < GameConfig.ROWS && newCol >= 0 && newCol < GameConfig.COLS && grid[newRow][newCol] == 0) {
              grid[newRow][newCol] = -draggedPiece.value![i][j]; // Negative value for preview
            }
          }
        }
      }
      grid.refresh();
    }
  }

  void clearPreview() {
    for (int i = 0; i < GameConfig.ROWS; i++) {
      for (int j = 0; j < GameConfig.COLS; j++) {
        if (grid[i][j] < 0) {
          grid[i][j] = 0;
        }
      }
    }
    grid.refresh();
  }
}

class GridCell extends StatelessWidget {
  final int value;

  const GridCell({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    Color cellColor = GameConfig.COLOR_MAP[value.abs()] ?? Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: value < 0 ? cellColor.withOpacity(0.5) : cellColor,
        border: Border.all(color: Colors.black),
      ),
    );
  }
}

class DraggablePiece extends StatelessWidget {
  final List<List<int>> piece;
  final VoidCallback onDragStarted;
  final void Function(DragUpdateDetails) onDragUpdate;
  final void Function(DraggableDetails) onDragEnd;

  const DraggablePiece({
    super.key,
    required this.piece,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<List<List<int>>>(
      data: piece,
      feedback: Transform.translate(
        offset: const Offset(-30, -30),
        child: PieceWidget(piece: piece, cellSize: 30),
      ),
      childWhenDragging: Container(),
      onDragStarted: onDragStarted,
      onDragUpdate: onDragUpdate,
      onDragEnd: onDragEnd,
      child: PieceWidget(piece: piece, cellSize: 20),
    );
  }
}

class PieceWidget extends StatelessWidget {
  final List<List<int>> piece;
  final double cellSize;

  const PieceWidget({super.key, required this.piece, required this.cellSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: piece
          .map((row) => Row(
                mainAxisSize: MainAxisSize.min,
                children: row
                    .map((cell) => Container(
                          width: cellSize,
                          height: cellSize,
                          decoration: BoxDecoration(
                            color: cell != 0 ? GameConfig.COLOR_MAP[cell] : Colors.transparent,
                            border: cell != 0 ? Border.all(color: Colors.black) : null,
                          ),
                        ))
                    .toList(),
              ))
          .toList(),
    );
  }
}
