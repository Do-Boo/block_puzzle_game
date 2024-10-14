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
  final Color shadowColor = const Color(0xFF1E1410);
  final Color highlightColor = const Color(0xFF5A4640);

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

    // 그리드 배경
    final gridPaint = Paint()..color = gridColor;
    canvas.drawRect(rect, gridPaint);

    // 그리드 테두리 (음각 효과)
    final borderPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRect(rect.deflate(2), borderPaint);

    // 내부 하이라이트
    final highlightPaint = Paint()
      ..color = highlightColor.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(rect.deflate(4), highlightPaint);
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
    final cellRect = rect.deflate(1);

    // 셀 배경
    final cellPaint = Paint()..color = cellColor;
    canvas.drawRect(cellRect, cellPaint);

    // 셀 테두리 (음각 효과)
    final borderPaint = Paint()
      ..color = shadowColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(cellRect, borderPaint);
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
