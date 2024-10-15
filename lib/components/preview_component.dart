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
      final rowsToHighlight = <int>{};
      final colsToHighlight = <int>{};

      for (int i = 0; i < previewPiece!.length; i++) {
        for (int j = 0; j < previewPiece![i].length; j++) {
          if (previewPiece![i][j] != 0) {
            final rect = Rect.fromLTWH(
              gridPosition.x + (previewCol! + j) * (cellSize.x),
              gridPosition.y + (previewRow! + i) * (cellSize.y),
              cellSize.x,
              cellSize.y,
            );

            // 그림자 효과
            final shadowPaint = Paint()
              ..color = Colors.black.withOpacity(0.1)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
            canvas.drawRRect(RRect.fromRectAndRadius(rect.translate(2, 2), const Radius.circular(6)), shadowPaint);

            // 미리보기 셀
            final previewPaint = Paint()
              ..color = Colors.white.withOpacity(0.2)
              ..style = PaintingStyle.fill;
            canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), previewPaint);

            // 테두리
            final borderPaint = Paint()
              ..color = Colors.white.withOpacity(0.3)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1;
            canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), borderPaint);

            // 라인 완성 가능성 체크
            if (isRowComplete(previewRow! + i)) {
              rowsToHighlight.add(previewRow! + i);
            }
            if (isColComplete(previewCol! + j)) {
              colsToHighlight.add(previewCol! + j);
            }
          }
        }
      }

      // 완성될 가능성이 있는 라인 강조
      for (int row in rowsToHighlight) {
        final lineRect = Rect.fromLTWH(
          gridPosition.x,
          gridPosition.y + row * (cellSize.y),
          Constants.COLS * (cellSize.x),
          cellSize.y,
        );
        _drawLineHighlight(canvas, lineRect);
      }

      for (int col in colsToHighlight) {
        final lineRect = Rect.fromLTWH(
          gridPosition.x + col * (cellSize.x),
          gridPosition.y,
          cellSize.x,
          Constants.ROWS * (cellSize.y),
        );
        _drawLineHighlight(canvas, lineRect);
      }
    }
  }

  bool isRowComplete(int row) {
    // 여기에 로직을 추가하여 해당 행이 완성될 수 있는지 확인합니다.
    // 예를 들어, 모든 셀이 채워질 수 있는지 확인하는 로직을 구현합니다.
    return true; // 임시로 true 반환
  }

  bool isColComplete(int col) {
    // 여기에 로직을 추가하여 해당 열이 완성될 수 있는지 확인합니다.
    return true; // 임시로 true 반환
  }

  void _drawLineHighlight(Canvas canvas, Rect rect) {
    final highlightPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.5) // 카툰 스타일의 강조 색상
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4; // 두꺼운 테두리
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), highlightPaint);
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
