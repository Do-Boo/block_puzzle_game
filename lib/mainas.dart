import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const PuzzleBlockGame());

class PuzzleBlockGame extends StatelessWidget {
  const PuzzleBlockGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puzzle Block Game',
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

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  static const int ROWS = 10;
  static const int COLS = 10;
  static const double DRAG_OFFSET = 50.0;

  List<List<int>> board = List.generate(ROWS, (_) => List.filled(COLS, 0));
  List<PuzzlePiece> availablePieces = [];
  int score = 0;
  PuzzlePiece? draggedPiece;
  Offset? dragPosition;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    generateNewPieces();
  }

  void generateNewPieces() {
    availablePieces = List.generate(3, (_) => PuzzlePiece.random());
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이 위치에 조각을 놓을 수 없습니다.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('조각이 성공적으로 배치되었습니다!'),
            duration: Duration(seconds: 1),
          ),
        );
      });
    });
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
      score += linesCleared * 100;
      setState(() {}); // 화면 갱신
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('게임 오버'),
            content: Text('최종 점수: $score'),
            actions: <Widget>[
              TextButton(
                child: const Text('다시 시작'),
                onPressed: () {
                  Navigator.of(context).pop();
                  resetGame();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void resetGame() {
    setState(() {
      board = List.generate(ROWS, (_) => List.filled(COLS, 0));
      score = 0;
      generateNewPieces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final boardSize = Size(screenSize.width, screenSize.width * ROWS / COLS);
    final cellSize = boardSize.width / COLS;

    return Scaffold(
      appBar: AppBar(title: Text('Score: $score')),
      body: Column(
        children: [
          SizedBox(
            width: boardSize.width,
            height: boardSize.height,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  dragPosition = details.localPosition;
                });
              },
              child: DragTarget<PuzzlePiece>(
                builder: (context, candidateData, rejectedData) {
                  return CustomPaint(
                    painter: BoardPainter(board, draggedPiece, dragPosition, DRAG_OFFSET, boardSize, ROWS, COLS, _animation.value),
                    size: boardSize,
                  );
                },
                onAcceptWithDetails: (details) {
                  final RenderBox renderBox = context.findRenderObject() as RenderBox;
                  final localPosition = renderBox.globalToLocal(details.offset);
                  int row = (localPosition.dy / cellSize).floor();
                  int col = (localPosition.dx / cellSize).floor();
                  placePiece(row, col, details.data);
                },
                onLeave: (piece) {
                  setState(() {
                    draggedPiece = null;
                    dragPosition = null;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: availablePieces
                  .map((piece) => DraggablePuzzlePiece(
                        piece: piece,
                        onDragStarted: () {
                          setState(() {
                            draggedPiece = piece;
                          });
                        },
                        cellSize: cellSize,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
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
      [
        [1, 1, 1],
        [0, 1, 0]
      ],
      [
        [1, 1, 1]
      ],
      [
        [1, 1],
        [1, 0]
      ],
      [
        [1, 1, 1, 1]
      ],
    ];
    return PuzzlePiece(
      shapes[Random().nextInt(shapes.length)],
      Random().nextInt(5) + 1,
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
      feedback: PuzzlePieceWidget(piece: piece, cellSize: cellSize),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: PuzzlePieceWidget(piece: piece, cellSize: cellSize * 0.6),
      ),
      onDragStarted: onDragStarted,
      onDragUpdate: (details) {
        final gameScreen = context.findAncestorStateOfType<_GameScreenState>();
        if (gameScreen != null) {
          gameScreen.setState(() {
            gameScreen.dragPosition = details.globalPosition;
          });
        }
      },
      onDragEnd: (details) {
        final gameScreen = context.findAncestorStateOfType<_GameScreenState>();
        if (gameScreen != null) {
          gameScreen.setState(() {
            gameScreen.draggedPiece = null;
            gameScreen.dragPosition = null;
          });
        }
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
  final double dragOffset;
  final Size boardSize;
  final int ROWS;
  final int COLS;
  final double animationValue;

  BoardPainter(this.board, this.draggedPiece, this.dragPosition, this.dragOffset, this.boardSize, this.ROWS, this.COLS, this.animationValue);

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
    if (draggedPiece != null && dragPosition != null) {
      final row = (dragPosition!.dy / cellHeight).floor();
      final col = (dragPosition!.dx / cellWidth).floor();

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
