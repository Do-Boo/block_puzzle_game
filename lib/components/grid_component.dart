import 'package:block_puzzle_game/utils/block_3d.dart';
import 'package:block_puzzle_game/utils/game_state.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class GridComponent extends PositionComponent {
  final Vector2 cellSize;
  late GameState gameState;

  GridComponent({required Vector2 position, required this.cellSize, required this.gameState}) : super(position: position) {
    priority = -1;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    print('Rendering GridComponent'); // 로그 추가
    _drawGrid(canvas);
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
          // 빈 셀 그리기 (카툰 스타일)
          canvas.drawRect(rect, Paint()..color = Colors.grey.withOpacity(0.1));
          canvas.drawRect(
              rect,
              Paint()
                ..color = Colors.black.withOpacity(0.3)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2);
        }
      }
    }
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
