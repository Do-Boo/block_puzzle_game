import 'package:block_puzzle_game/utils/g_getX_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController gameController = Get.put(GameController());
    double cellSize = MediaQuery.of(context).size.width / GameController.COLS;
    double previewCellSize = cellSize * 0.6;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Block Puzzle', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Obx(() => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Score: ${gameController.score}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              )),
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
                    return Obx(() {
                      Color cellColor = _getCellColor(gameController, row, col);
                      bool hasColor = cellColor != gameController.getColor(0);
                      bool isPreview = _isPreviewCell(gameController, row, col);
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: cellColor,
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: hasColor
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        offset: const Offset(2, 2),
                                        blurRadius: 2,
                                      )
                                    ]
                                  : null,
                            ),
                          ),
                          if (isPreview)
                            Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                        ],
                      );
                    });
                  },
                );
              },
            ),
          ),
          SizedBox(
            height: previewCellSize * 4,
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: gameController.puzzlePieces
                    .map((piece) => Draggable<List<List<int>>>(
                          data: piece,
                          feedback: Transform.translate(
                            offset: Offset(
                              gameController.piecePositions.value.dx - (cellSize * piece[0].length.toDouble() / 2),
                              gameController.piecePositions.value.dy - (cellSize * piece.length.toDouble() + cellSize * 2),
                            ),
                            child: PieceWidget(piece: piece, cellSize: cellSize, gameController: gameController),
                          ),
                          childWhenDragging: Container(),
                          onDragStarted: () => {
                            gameController.draggedPiece.value = piece,
                          },
                          onDragUpdate: (details) {
                            final RenderBox renderBox = context.findRenderObject() as RenderBox;
                            final localPosition = renderBox.globalToLocal(details.globalPosition);
                            int pieceRows = gameController.draggedPiece.value!.length;
                            int pieceCols = gameController.draggedPiece.value![0].length;
                            gameController.previewRow.value = ((localPosition.dy - (pieceRows * cellSize)) / cellSize - 4).floor();
                            gameController.previewCol.value = ((localPosition.dx - (pieceCols * cellSize) / 2) / cellSize).floor();
                            gameController.previewPiece.value = gameController.draggedPiece.value;
                          },
                          onDragEnd: (details) {
                            gameController.draggedPiece.value = null;
                            gameController.previewPiece.value = null;
                            gameController.previewRow.value = null;
                            gameController.previewCol.value = null;
                          },
                          child: PieceWidget(piece: piece, cellSize: previewCellSize, gameController: gameController),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 72),
        ],
      ),
    );
  }

  bool _isPreviewCell(GameController gameController, int row, int col) {
    if (gameController.previewPiece.value != null && gameController.previewRow.value != null && gameController.previewCol.value != null) {
      int pieceRow = row - gameController.previewRow.value!;
      int pieceCol = col - gameController.previewCol.value!;
      if (pieceRow >= 0 && pieceRow < gameController.previewPiece.value!.length && pieceCol >= 0 && pieceCol < gameController.previewPiece.value![0].length) {
        return gameController.previewPiece.value![pieceRow][pieceCol] != 0;
      }
    }
    return false;
  }

  Color _getCellColor(GameController gameController, int row, int col) {
    return gameController.getColor(gameController.grid[row][col]);
  }
}

// PieceWidget class remains unchanged
class PieceWidget extends StatelessWidget {
  final List<List<int>> piece;
  final double cellSize;
  final GameController gameController;

  const PieceWidget({super.key, required this.piece, required this.cellSize, required this.gameController});

  @override
  Widget build(BuildContext context) {
    int rows = piece.length;
    int cols = piece[0].length;
    return GestureDetector(
      onTapDown: (details) {
        RenderBox renderBox = context.findRenderObject() as RenderBox;
        Offset localPosition = renderBox.globalToLocal(details.globalPosition);

        // 0.6 스케일 팩터를 고려하여 실제 그리드 위치 계산
        double scaledX = localPosition.dx / 0.6;
        double scaledY = localPosition.dy / 0.6;

        int touchedRow = (scaledY / cellSize).floor();
        int touchedCol = (scaledX / cellSize).floor();

        // previewPiece 위치 업데이트
        gameController.updatePreviewPiecePosition(touchedRow, touchedCol);

        debugPrint('Touched cell: row $touchedRow, col $touchedCol');
        debugPrint('Positions (X, Y): $scaledX, $scaledY');
        debugPrint('Positions (X, Y): ${localPosition.dx}, $scaledY');

        gameController.piecePositions.value = Offset(localPosition.dx / 0.6, localPosition.dy);
      },
      child: Container(
        width: cellSize * cols,
        height: cellSize * rows,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
                                color: cell != 0 ? gameController.getColor(cell) : Colors.transparent,
                                border: cell != 0 ? Border.all(color: Colors.black26) : null,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: cell != 0
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          offset: const Offset(2, 2),
                                          blurRadius: 2,
                                        )
                                      ]
                                    : null,
                              ),
                            ))
                        .toList(),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
