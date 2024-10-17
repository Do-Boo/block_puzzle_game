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
    final baseColor = Constants.getColor(1); // Constants의 색상 사용

    final gradient = ui.Gradient.radial(
      rect.center,
      rect.width / 2,
      [
        baseColor.withOpacity(0.2),
      ],
      [0.0],
    );

    // 셀
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), Paint()..shader = gradient);

    // 테두리
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1; // 부드러운 테두리
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), borderPaint);

    // 하이라이트
    final highlightPaint = Paint()
      ..color = const Color(0xFFFDF5E6).withOpacity(0.5) // 밝은 노란색 하이라이트
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(5)), highlightPaint);
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

    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), Paint()..shader = gradient);

    // 테두리
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), borderPaint);

    // 하이라이트
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(5)), highlightPaint);

    // 추가 하이라이트 (볼록한 느낌 강화)
    final highlightGradient = ui.Gradient.linear(
      rect.topLeft,
      rect.bottomRight,
      [Colors.white.withOpacity(0.4), Colors.transparent],
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(4), const Radius.circular(8)),
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
