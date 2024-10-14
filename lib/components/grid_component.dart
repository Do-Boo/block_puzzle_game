import 'package:block_puzzle_game/utils/block_3d.dart';
import 'package:block_puzzle_game/utils/game_state.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class GridComponent extends PositionComponent {
  final Vector2 cellSize;
  late GameState gameState;

  final Color backgroundColor = const Color(0xFF392A25);
  final Color gridColor = const Color(0xFF2D1F1B);
  final Color cellColor = const Color(0xFF4A362F);

  GridComponent({required Vector2 position, required this.cellSize, required this.gameState}) : super(position: position) {
    priority = -1;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _drawBackground(canvas);
    _drawInsetGrid(canvas);
    _drawGrid(canvas);
  }

  void _drawBackground(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, cellSize.x * Constants.COLS, cellSize.y * Constants.ROWS);
    final paint = Paint()..color = backgroundColor;
    canvas.drawRect(rect, paint);
  }

  void _drawInsetGrid(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, cellSize.x * Constants.COLS, cellSize.y * Constants.ROWS);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    // 음각 효과를 위한 그라데이션
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.black.withOpacity(0.3),
        Colors.white.withOpacity(0.1),
      ],
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRRect(rrect, paint);

    // 안쪽 테두리
    final innerRect = rect.deflate(4);
    final innerRRect = RRect.fromRectAndRadius(innerRect, const Radius.circular(8));
    final innerPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(innerRRect, innerPaint);
  }

  void _drawGrid(Canvas canvas) {
    for (int row = 0; row < Constants.ROWS; row++) {
      for (int col = 0; col < Constants.COLS; col++) {
        final rect = Rect.fromLTWH(col * cellSize.x, row * cellSize.y, cellSize.x, cellSize.y);
        final cellValue = gameState.grid[row][col];
        if (cellValue != 0) {
          final color = Constants.getColor(cellValue);
          CartoonBlockPainter.paintBlock(canvas, rect, color);
        } else {
          _drawEmptyCell(canvas, rect);
        }
      }
    }
  }

  void _drawEmptyCell(Canvas canvas, Rect rect) {
    final rrect = RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(6));

    // 셀 그림자 (음각 효과)
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 2);
    canvas.drawRRect(rrect, shadowPaint);

    // 셀 하이라이트 (아래쪽과 오른쪽)
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(rect.bottomLeft, rect.bottomRight, highlightPaint);
    canvas.drawLine(rect.topRight, rect.bottomRight, highlightPaint);
  }

  void resetGrid() {
    print('Resetting grid');
    gameState.clearGrid();
    updateGrid();
  }

  void updateGrid() {
    print('Updating grid');
    print('Grid state in GridComponent: ${gameState.grid}');
  }
}
