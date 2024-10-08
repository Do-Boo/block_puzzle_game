import 'package:block_puzzle_game/utils/game_state.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class GridComponent extends PositionComponent {
  final Vector2 cellSize;
  final GameState gameState;

  GridComponent({required Vector2 position, required this.cellSize, required this.gameState}) : super(position: position);

  @override
  void render(Canvas canvas) {
    for (int row = 0; row < Constants.ROWS; row++) {
      for (int col = 0; col < Constants.COLS; col++) {
        final rect = Rect.fromLTWH(col * cellSize.x, row * cellSize.y, cellSize.x, cellSize.y);
        final cellValue = gameState.grid[row][col];
        final color = cellValue == 0 ? Colors.grey.withOpacity(0.3) : Constants.getColor(cellValue);
        canvas.drawRect(rect, Paint()..color = color);
        canvas.drawRect(
            rect,
            Paint()
              ..color = Colors.black
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1);
      }
    }
  }

  void updateGrid() {
    // This method triggers a re-render of the grid
    // It's called after a piece is placed
    // No need to do anything here, as the render method
    // will use the updated gameState
  }
}
