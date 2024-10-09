import 'package:block_puzzle_game/utils/constants.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PreviewComponent extends PositionComponent {
  final Vector2 cellSize;
  final Vector2 gridPosition;
  List<List<int>>? previewPiece;
  int? previewRow;
  int? previewCol;

  PreviewComponent({required this.cellSize, required this.gridPosition});

  @override
  void render(Canvas canvas) {
    if (previewPiece != null && previewRow != null && previewCol != null) {
      for (int i = 0; i < previewPiece!.length; i++) {
        for (int j = 0; j < previewPiece![i].length; j++) {
          if (previewPiece![i][j] != 0) {
            final rect = Rect.fromLTWH(
              gridPosition.x + (previewCol! + j) * cellSize.x,
              gridPosition.y + (previewRow! + i) * cellSize.y,
              cellSize.x,
              cellSize.y,
            );
            canvas.drawRect(rect, Paint()..color = Colors.white.withOpacity(0.5));
          }
        }
      }
    }
  }

  void updatePreview(int row, int col, List<List<int>> piece) {
    if (row < 0 || col < 0 || row + piece.length > Constants.ROWS || col + piece[0].length > Constants.COLS) {
      clearPreview();
    } else {
      previewPiece = piece;
      previewRow = row;
      previewCol = col;
    }
  }

  void clearPreview() {
    previewPiece = null;
    previewRow = null;
    previewCol = null;
  }
}
