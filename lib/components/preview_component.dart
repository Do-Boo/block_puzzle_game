import 'package:block_puzzle_game/utils/constants.dart';
import 'package:block_puzzle_game/utils/game_state.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'dart:ui' as ui;

class PreviewComponent extends PositionComponent {
  final Vector2 cellSize;
  final Vector2 gridPosition;
  List<List<int>>? previewPiece;
  int? previewRow;
  int? previewCol;
  late GameState gameState;

  PreviewComponent({required this.cellSize, required this.gridPosition, required this.gameState});

  @override
  void render(Canvas canvas) {
    developer.log('Rendering PreviewComponent');
    developer.log('previewPiece: $previewPiece, previewRow: $previewRow, previewCol: $previewCol');

    if (previewPiece != null && previewRow != null && previewCol != null) {
      final rowsToHighlight = <int>{};
      final colsToHighlight = <int>{};

      // 기본 미리보기 그리기 및 완성 가능한 행/열 체크
      for (int i = 0; i < previewPiece!.length; i++) {
        for (int j = 0; j < previewPiece![i].length; j++) {
          if (previewPiece![i][j] != 0) {
            final rect = Rect.fromLTWH(
              gridPosition.x + (previewCol! + j) * cellSize.x,
              gridPosition.y + (previewRow! + i) * cellSize.y,
              cellSize.x,
              cellSize.y,
            );
            _drawPreviewCell(canvas, rect);
            developer.log('Drawing preview cell at row ${previewRow! + i}, col ${previewCol! + j}');

            if (canCompleteRow(previewRow! + i, previewPiece!)) {
              rowsToHighlight.add(previewRow! + i);
            }
            if (canCompleteCol(previewCol! + j, previewPiece!, i)) {
              colsToHighlight.add(previewCol! + j);
            }
          }
        }
      }

      // 완성될 행 강조
      for (int row in rowsToHighlight) {
        final lineRect = Rect.fromLTWH(
          gridPosition.x,
          gridPosition.y + row * cellSize.y,
          Constants.COLS * cellSize.x,
          cellSize.y,
        );
        _drawLineHighlight(canvas, lineRect);
        developer.log('Drawing row highlight for row $row');
      }

      // 완성될 열 강조
      for (int col in colsToHighlight) {
        final lineRect = Rect.fromLTWH(
          gridPosition.x + col * cellSize.x,
          gridPosition.y,
          cellSize.x,
          Constants.ROWS * cellSize.y,
        );
        _drawLineHighlight(canvas, lineRect);
        developer.log('Drawing column highlight for column $col');
      }
    } else {
      developer.log('Preview data is null');
    }
  }

  bool canCompleteRow(int row, List<List<int>> piece) {
    if (row < 0 || row >= Constants.ROWS) return false;

    List<int> currentRow = List.from(gameState.grid[row]);
    bool rowChanged = false;

    for (int j = 0; j < piece[0].length; j++) {
      int col = previewCol! + j;
      if (col < 0 || col >= Constants.COLS) continue;

      if (piece[row - previewRow!][j] != 0) {
        currentRow[col] = 1;
        rowChanged = true;
      }
    }

    bool canComplete = rowChanged && !currentRow.contains(0);
    developer.log('Row $row: rowChanged=$rowChanged, canComplete=$canComplete');
    return canComplete;
  }

  bool canCompleteCol(int col, List<List<int>> piece, int pieceRow) {
    if (col < 0 || col >= Constants.COLS) return false;

    List<int> currentColumn = List.generate(Constants.ROWS, (row) => gameState.grid[row][col]);
    for (int i = 0; i < piece.length; i++) {
      if (pieceRow + i < Constants.ROWS && piece[i][col - previewCol!] != 0) {
        currentColumn[previewRow! + i] = 1;
      }
    }
    bool canComplete = !currentColumn.contains(0);
    developer.log('Column $col: canComplete=$canComplete');
    return canComplete;
  }

  void _drawPreviewCell(Canvas canvas, Rect rect) {
    final previewPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, previewPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(rect, borderPaint);
  }

  void _drawLineHighlight(Canvas canvas, Rect rect) {
    // 네온 색상 정의
    const neonColor = Colors.cyan;

    // 외부 글로우
    final outerGlowPaint = Paint()
      ..color = neonColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRect(rect.inflate(6), outerGlowPaint);

    // 중간 글로우
    final middleGlowPaint = Paint()
      ..color = neonColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRect(rect.inflate(4), middleGlowPaint);

    // 내부 밝은 선
    final innerLinePaint = Paint()
      ..color = neonColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRect(rect.inflate(2), innerLinePaint);

    // 가장 밝은 중심선
    final centerLinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(rect, centerLinePaint);
  }

  void updatePreview(int row, int col, List<List<int>> piece) {
    previewRow = row;
    previewCol = col;
    previewPiece = piece;
    developer.log('Preview updated: row=$row, col=$col, piece=$piece');
  }

  void clearPreview() {
    previewPiece = null;
    previewRow = null;
    previewCol = null;
    // 추가적으로 필요한 초기화 작업
  }

  void reset() {
    gameState = GameState();
    clearPreview();
  }
}
