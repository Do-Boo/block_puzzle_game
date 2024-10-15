import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../utils/game_state.dart';
import '../utils/constants.dart';

class GridComponent extends PositionComponent {
  final Vector2 cellSize;
  late GameState gameState;
  late ui.Image? _cachedBackgroundImage;

  GridComponent({required Vector2 position, required this.cellSize, required this.gameState}) : super(position: position) {
    size = Vector2((Constants.COLS + 2) * cellSize.x, (Constants.ROWS + 2) * cellSize.y);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _generateAndCacheBackground();
  }

  Future<void> _generateAndCacheBackground() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    // final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    // 전체 배경 (테두리 포함)
    // final bgGradient = ui.Gradient.linear(
    //   Offset.zero,
    //   Offset(size.x, size.y),
    //   [const Color(0xFF4D3E34), const Color(0xFF3D2E24)],
    // );
    // canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(20)), Paint()..shader = bgGradient);

    // 그리드 배경
    final gridBgGradient = ui.Gradient.linear(
      Offset(cellSize.x, cellSize.y),
      Offset(size.x - cellSize.x, size.y - cellSize.y),
      [const Color(0xFF3A2E27), const Color(0xFF2A1E17)],
    );
    final gridRect = Rect.fromLTWH(0, 0, Constants.COLS * cellSize.x, Constants.ROWS * cellSize.y);
    canvas.drawRRect(RRect.fromRectAndRadius(gridRect, const Radius.circular(10)), Paint()..shader = gridBgGradient);

    // 그리드 셀
    for (int row = 0; row < Constants.ROWS; row++) {
      for (int col = 0; col < Constants.COLS; col++) {
        final cellRect = Rect.fromLTWH(col * cellSize.x, row * cellSize.y, cellSize.x, cellSize.y);
        _drawCell(canvas, cellRect, row, col);
      }
    }

    final picture = recorder.endRecording();
    _cachedBackgroundImage = await picture.toImage(size.x.toInt(), size.y.toInt());
  }

  void _drawCell(Canvas canvas, Rect rect, int row, int col) {
    final random = Random(row * Constants.COLS + col);
    final baseColor = Color.lerp(const Color(0xFF231813), const Color(0xFF2A1E17), random.nextDouble())!;

    final gradient = ui.Gradient.radial(
      rect.center,
      rect.width / 2,
      [
        baseColor.withOpacity(0.9), // 더 진한 색상
        baseColor,
        baseColor.withOpacity(1.0),
      ],
      [0.0, 0.7, 1.0],
    );

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.5) // 더 진한 그림자
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    // 그림자
    canvas.drawRRect(RRect.fromRectAndRadius(rect.translate(3, 3), const Radius.circular(8)), shadowPaint);

    // 셀
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), Paint()..shader = gradient);

    // 테두리
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3; // 더 두꺼운 테두리
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), borderPaint);

    // 하이라이트
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.2) // 더 밝은 하이라이트
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(6)), highlightPaint);

    // 추가 하이라이트 (볼록한 느낌 강화)
    final highlightGradient = ui.Gradient.linear(
      rect.topLeft,
      rect.bottomRight,
      [Colors.white.withOpacity(0.4), Colors.white.withOpacity(0.0)], // 더 강한 하이라이트
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(4), const Radius.circular(4)),
      Paint()..shader = highlightGradient,
    );
  }

  @override
  void render(Canvas canvas) {
    if (_cachedBackgroundImage != null) {
      canvas.drawImage(_cachedBackgroundImage!, Offset.zero, Paint());
    }
    _drawBlocks(canvas);
  }

  void _drawBlocks(Canvas canvas) {
    for (int row = 0; row < Constants.ROWS; row++) {
      for (int col = 0; col < Constants.COLS; col++) {
        final cellValue = gameState.grid[row][col];
        if (cellValue != 0) {
          final rect = Rect.fromLTWH(col * cellSize.x, row * cellSize.y, cellSize.x, cellSize.y);
          _drawBlock(canvas, rect, cellValue);
        }
      }
    }
  }

  void _drawBlock(Canvas canvas, Rect rect, int value) {
    final color = Constants.getColor(value);
    final gradient = ui.Gradient.radial(
      rect.center,
      rect.width / 2,
      [
        color.withOpacity(0.9), // 더 진한 색상
        color,
        color.withOpacity(1.0),
      ],
      [0.0, 0.7, 1.0],
    );

    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(4), const Radius.circular(6)), Paint()..shader = gradient);

    // 테두리
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3; // 더 두꺼운 테두리
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(4), const Radius.circular(6)), borderPaint);

    // 하이라이트
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4) // 더 밝은 하이라이트
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(6), const Radius.circular(4)), highlightPaint);

    // 추가 하이라이트 (볼록한 느낌 강화)
    final highlightGradient = ui.Gradient.linear(
      rect.topLeft,
      rect.bottomRight,
      [Colors.white.withOpacity(0.4), Colors.white.withOpacity(0.0)], // 더 강한 하이라이트
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(8), const Radius.circular(2)),
      Paint()..shader = highlightGradient,
    );
  }

  void resetGrid() {
    gameState.clearGrid();
  }

  void updateGrid() {
    // 그리드 업데이트 로직
  }
}
