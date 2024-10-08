import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

void main() => runApp(const PuzzleBlockGame());

class PuzzleBlockGame extends StatelessWidget {
  const PuzzleBlockGame({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Puzzle Block Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final boardSize = Size(screenSize.width, screenSize.width * GameController.ROWS / GameController.COLS);
    final cellSize = boardSize.width / GameController.COLS;

    final controller = Get.put(GameController(boardSize));

    return Scaffold(
      appBar: AppBar(title: Obx(() => Text('Score: ${controller.score}'))),
      body: Column(
        children: [
          SizedBox(
            width: boardSize.width,
            height: boardSize.height,
            child: GestureDetector(
              onPanUpdate: (details) {
                final RenderBox renderBox = context.findRenderObject() as RenderBox;
                final localPosition = renderBox.globalToLocal(details.globalPosition);
                controller.updateDragPosition(localPosition);
              },
              child: DragTarget<PuzzlePiece>(
                builder: (context, candidateData, rejectedData) {
                  return GetBuilder<GameController>(
                    builder: (controller) => CustomPaint(
                      painter: BoardPainter(
                        controller.board,
                        controller.draggedPiece.value,
                        controller.dragPosition.value,
                        controller.boardDragPosition.value,
                        boardSize,
                        GameController.ROWS,
                        GameController.COLS,
                        controller.animationValue,
                      ),
                      size: boardSize,
                    ),
                  );
                },
                onAcceptWithDetails: (details) {
                  if (controller.boardDragPosition.value != null) {
                    controller.placePiece(controller.boardDragPosition.value!, details.data);
                  }
                },
                onLeave: (piece) {
                  controller.clearDraggedPiece();
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: controller.availablePieces
                      .map((piece) => DraggablePuzzlePiece(
                            piece: piece,
                            onDragStarted: () => controller.setDraggedPiece(piece),
                            cellSize: cellSize,
                          ))
                      .toList(),
                )),
          ),
        ],
      ),
    );
  }
}

class GameController extends GetxController with GetSingleTickerProviderStateMixin {
  static const int ROWS = 8;
  static const int COLS = 8;
  static const double VERTICAL_OFFSET = 100.0; // 수정: 수직 오프셋 값 증가
  static const int ROW_OFFSET = 2;

  late Size boardSize; // 추가: boardSize 변수

  final RxList<List<int>> board = List.generate(ROWS, (_) => List.filled(COLS, 0)).obs;
  final RxList<PuzzlePiece> availablePieces = <PuzzlePiece>[].obs;
  final RxInt score = 0.obs;
  final Rx<PuzzlePiece?> draggedPiece = Rx<PuzzlePiece?>(null);
  final Rx<Offset?> boardDragPosition = Rx<Offset?>(null); // 추가: 보드 상의 드래그 위치
  final Rx<Offset?> dragPosition = Rx<Offset?>(null);

  late AnimationController _animationController;
  late Animation<double> _animation;

  double get animationValue => _animation.value;

  GameController(this.boardSize);

  @override
  void onInit() {
    super.onInit();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animation.addListener(() => update());
    generateNewPieces();
  }

  // 수정: 오프셋을 계산하는 메서드
  Offset calculateOffset(Offset position) {
    return Offset(position.dx, position.dy - VERTICAL_OFFSET);
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

  // 수정: placePiece 메서드
  void placePiece(Offset position, PuzzlePiece piece) {
    double cellWidth = boardSize.width / COLS;
    double cellHeight = boardSize.height / ROWS;

    int col = (position.dx / cellWidth).floor();
    int row = (position.dy / cellHeight).floor() - ROW_OFFSET;

    // 보드 경계 체크
    if (row < 0 || row + piece.shape.length > ROWS || col < 0 || col + piece.shape[0].length > COLS) {
      Get.snackbar('실패', '보드 경계를 벗어났습니다.', duration: const Duration(seconds: 1));
      return;
    }

    if (!canPlacePiece(row, col, piece)) {
      Get.snackbar('실패', '이 위치에 조각을 놓을 수 없습니다.', duration: const Duration(seconds: 1));
      return;
    }

    for (int i = 0; i < piece.shape.length; i++) {
      for (int j = 0; j < piece.shape[i].length; j++) {
        if (piece.shape[i][j] != 0) {
          board[row + i][col + j] = piece.color;
        }
      }
    }
    availablePieces.remove(piece);
    if (availablePieces.isEmpty) {
      generateNewPieces();
    }
    checkLines();
    checkGameOver();

    _animationController.forward(from: 0.0).then((_) {
      Get.snackbar('성공', '조각이 성공적으로 배치되었습니다!', duration: const Duration(seconds: 1));
    });

    update();
  }

  void checkLines() {
    int linesCleared = 0;

    // Check rows
    for (int row = 0; row < ROWS; row++) {
      if (board[row].every((cell) => cell != 0)) {
        linesCleared++;
        board[row] = List.filled(COLS, 0);
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
      Get.dialog(
        AlertDialog(
          title: const Text('게임 오버'),
          content: Text('최종 점수: ${score.value}'),
          actions: <Widget>[
            TextButton(
              child: const Text('다시 시작'),
              onPressed: () {
                Get.back();
                resetGame();
              },
            ),
          ],
        ),
      );
    }
  }

  void resetGame() {
    board.value = List.generate(ROWS, (_) => List.filled(COLS, 0));
    score.value = 0;
    generateNewPieces();
    update();
  }

  void setDraggedPiece(PuzzlePiece piece) {
    draggedPiece.value = piece;
  }

  // 수정: updateDragPosition 메서드
  void updateDragPosition(Offset position) {
    dragPosition.value = position;

    double cellWidth = boardSize.width / COLS;
    double cellHeight = boardSize.height / ROWS;

    Offset adjustedPosition = calculateOffset(position);
    double col = (adjustedPosition.dx / cellWidth);
    double row = (adjustedPosition.dy / cellHeight);

    // 보드 경계를 벗어나도 boardDragPosition을 업데이트합니다.
    boardDragPosition.value = Offset(col * cellWidth, row * cellHeight);

    update();
  }

  void clearDraggedPiece() {
    draggedPiece.value = null;
    dragPosition.value = null;
    update();
  }

  @override
  void onClose() {
    _animationController.dispose();
    super.onClose();
  }
}

class PuzzlePiece {
  final List<List<int>> shape;
  final int color;

  PuzzlePiece(this.shape, this.color);

  factory PuzzlePiece.random() {
    final shapes = [
      [
        [1, 1],
        [1, 1]
      ],
      // [
      //   [1, 1, 1],
      //   [0, 1, 0]
      // ],
      [
        [1, 1, 1]
      ],
      // [
      //   [1, 1],
      //   [1, 0]
      // ],
      [
        [1, 1, 1, 1]
      ],
      [
        [1],
        [1],
        [1],
        [1]
      ],
    ];
    return PuzzlePiece(
      shapes[Random().nextInt(shapes.length)],
      Random().nextInt(shapes.length) + 1,
    );
  }
}

class DraggablePuzzlePiece extends StatelessWidget {
  final PuzzlePiece piece;
  final VoidCallback onDragStarted;
  final double cellSize;

  const DraggablePuzzlePiece({
    super.key,
    required this.piece,
    required this.onDragStarted,
    required this.cellSize,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<PuzzlePiece>(
      data: piece,
      feedback: Transform.translate(
        offset: const Offset(0, -GameController.VERTICAL_OFFSET), // 수정: 선택된 조각 위치 조정
        child: PuzzlePieceWidget(piece: piece, cellSize: cellSize),
      ),
      childWhenDragging: const SizedBox(),
      onDragStarted: onDragStarted,
      onDragUpdate: (details) {
        Get.find<GameController>().updateDragPosition(details.globalPosition);
      },
      onDragEnd: (details) {
        Get.find<GameController>().clearDraggedPiece();
      },
      child: PuzzlePieceWidget(piece: piece, cellSize: cellSize * 0.6),
    );
  }
}

class PuzzlePieceWidget extends StatelessWidget {
  final PuzzlePiece piece;
  final double cellSize;

  const PuzzlePieceWidget({super.key, required this.piece, required this.cellSize});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PiecePainter(piece),
      size: Size(cellSize * piece.shape[0].length, cellSize * piece.shape.length),
    );
  }
}

class BoardPainter extends CustomPainter {
  final List<List<int>> board;
  final PuzzlePiece? draggedPiece;
  final Offset? dragPosition;
  final Offset? boardDragPosition; // 추가: 보드 상의 드래그 위치
  final Size boardSize;
  final int ROWS;
  final int COLS;
  final double animationValue;

  BoardPainter(this.board, this.draggedPiece, this.dragPosition, this.boardDragPosition, this.boardSize, this.ROWS, this.COLS, this.animationValue);

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

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = boardSize.width / COLS;
    final cellHeight = boardSize.height / ROWS;

    // 보드 그리기
    for (int i = 0; i < ROWS; i++) {
      for (int j = 0; j < COLS; j++) {
        final rect = Rect.fromLTWH(j * cellWidth, i * cellHeight, cellWidth, cellHeight);
        final color = _getColor(board[i][j]);
        final animatedColor = Color.lerp(Colors.white, color, animationValue)!;
        canvas.drawRect(rect, Paint()..color = animatedColor);
        canvas.drawRect(
            rect,
            Paint()
              ..color = Colors.black
              ..style = PaintingStyle.stroke);
      }
    }

    // 드래그 중인 조각 미리보기 그리기
    if (draggedPiece != null && boardDragPosition != null) {
      final row = (boardDragPosition!.dy / cellHeight).floor() - GameController.ROW_OFFSET;
      final col = (boardDragPosition!.dx / cellWidth).floor();

      // 보드 내부에 있을 때만 미리보기를 그립니다.
      if (row >= 0 && row < ROWS && col >= 0 && col < COLS) {
        final canPlace = canPlacePiece(row, col, draggedPiece!);
        final previewColor = canPlace ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2);
        final borderColor = canPlace ? Colors.green : Colors.red;

        for (int i = 0; i < draggedPiece!.shape.length; i++) {
          for (int j = 0; j < draggedPiece!.shape[i].length; j++) {
            if (draggedPiece!.shape[i][j] != 0) {
              final rect = Rect.fromLTWH(
                (col + j) * cellWidth,
                (row + i) * cellHeight,
                cellWidth,
                cellHeight,
              );
              canvas.drawRect(rect, Paint()..color = previewColor);
              canvas.drawRect(
                  rect,
                  Paint()
                    ..color = borderColor
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2);
            }
          }
        }
      }
    }

    // 실제 드래그 위치 표시 (디버깅용, 필요 없으면 제거)
    if (dragPosition != null) {
      canvas.drawCircle(dragPosition!, 5, Paint()..color = Colors.red);
    }

    // 보드 상의 드래그 위치 표시 (디버깅용)
    if (boardDragPosition != null) {
      canvas.drawCircle(boardDragPosition!, 5, Paint()..color = Colors.blue);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

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

class PiecePainter extends CustomPainter {
  final PuzzlePiece piece;

  PiecePainter(this.piece);

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / piece.shape[0].length;
    final cellHeight = size.height / piece.shape.length;

    for (int i = 0; i < piece.shape.length; i++) {
      for (int j = 0; j < piece.shape[i].length; j++) {
        if (piece.shape[i][j] != 0) {
          final rect = Rect.fromLTWH(j * cellWidth, i * cellHeight, cellWidth, cellHeight);
          canvas.drawRect(rect, Paint()..color = getColor(piece.color));
          canvas.drawRect(
              rect,
              Paint()
                ..color = Colors.black
                ..style = PaintingStyle.stroke);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

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
        return Colors.grey;
    }
  }
}
