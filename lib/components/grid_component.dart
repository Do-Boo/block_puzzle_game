import 'dart:math' as math;
import 'package:block_puzzle_game/utils/block_3d.dart';
import 'package:block_puzzle_game/utils/game_state.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class GridComponent extends PositionComponent {
  final Vector2 cellSize;
  late GameState gameState;
  final Color grassDarkColor = const Color(0xFF4CAF50);
  final Color grassLightColor = const Color(0xFF8BC34A);
  final math.Random random = math.Random(42);
  late List<List<List<_CartoonGrass>>> grassPatterns;

  GridComponent({required Vector2 position, required this.cellSize, required this.gameState}) : super(position: position) {
    priority = -1;
    size = Vector2(Constants.COLS * cellSize.x, Constants.ROWS * cellSize.y);
    _generateGrassPatterns();
  }

  void _generateGrassPatterns() {
    grassPatterns = List.generate(
      Constants.ROWS,
      (row) => List.generate(
        Constants.COLS,
        (col) => _generateGrassForCell(row, col),
      ),
    );
  }

  List<_CartoonGrass> _generateGrassForCell(int row, int col) {
    final grassCount = 2 + random.nextInt(2); // 2-3개의 풀
    final baseColor = ((row + col) % 2 == 0) ? grassDarkColor : grassLightColor;
    return List.generate(grassCount, (_) => _CartoonGrass(random, baseColor));
  }

  @override
  void render(Canvas canvas) {
    _drawGridBackground(canvas);
    _drawGrassPatterns(canvas);
    _drawBlocks(canvas);
  }

  void _drawGridBackground(Canvas canvas) {
    for (int row = 0; row < Constants.ROWS; row++) {
      for (int col = 0; col < Constants.COLS; col++) {
        final rect = Rect.fromLTWH(col * cellSize.x, row * cellSize.y, cellSize.x, cellSize.y);
        final color = ((row + col) % 2 == 0) ? grassDarkColor : grassLightColor;
        canvas.drawRect(rect, Paint()..color = color);
      }
    }
  }

  void _drawGrassPatterns(Canvas canvas) {
    for (int row = 0; row < Constants.ROWS; row++) {
      for (int col = 0; col < Constants.COLS; col++) {
        final cellRect = Rect.fromLTWH(col * cellSize.x, row * cellSize.y, cellSize.x, cellSize.y);
        _drawGrassInCell(canvas, cellRect, grassPatterns[row][col]);
      }
    }
  }

  void _drawGrassInCell(Canvas canvas, Rect cellRect, List<_CartoonGrass> grasses) {
    for (var grass in grasses) {
      grass.draw(canvas, cellRect);
    }
  }

  void _drawBlocks(Canvas canvas) {
    for (int row = 0; row < Constants.ROWS; row++) {
      for (int col = 0; col < Constants.COLS; col++) {
        final cellValue = gameState.grid[row][col];
        if (cellValue != 0) {
          final rect = Rect.fromLTWH(col * cellSize.x, row * cellSize.y, cellSize.x, cellSize.y);
          final color = Constants.getColor(cellValue);
          CartoonBlockPainter.paintBlock(canvas, rect, color);
        }
      }
    }
  }

  // ... 기존의 resetGrid와 updateGrid 메서드 유지
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

class _CartoonGrass {
  final double x;
  final double height;
  final Color color;
  final int leafCount;

  _CartoonGrass(math.Random random, Color baseColor)
      : x = random.nextDouble(),
        height = 0.2 + random.nextDouble() * 0.3, // 셀 높이의 20-50%
        color = baseColor.withOpacity(0.8 + random.nextDouble() * 0.2),
        leafCount = 2 + random.nextInt(2); // 2-3개의 잎

  void draw(Canvas canvas, Rect cellRect) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final stemWidth = cellRect.width * 0.05;
    final stemHeight = cellRect.height * height;
    final stemRect = Rect.fromLTWH(cellRect.left + x * cellRect.width - stemWidth / 2, cellRect.bottom - stemHeight, stemWidth, stemHeight);

    // 줄기 그리기
    canvas.drawRect(stemRect, paint);

    // 잎 그리기
    for (int i = 0; i < leafCount; i++) {
      final leafHeight = stemHeight * (0.3 + 0.2 * i);
      final leafWidth = cellRect.width * 0.15;
      final leafY = cellRect.bottom - leafHeight;

      final path = Path()
        ..moveTo(stemRect.left, leafY)
        ..quadraticBezierTo(stemRect.left - leafWidth, leafY - leafWidth / 2, stemRect.left, leafY - leafWidth)
        ..quadraticBezierTo(stemRect.left + leafWidth / 4, leafY - leafWidth / 2, stemRect.left, leafY);

      canvas.drawPath(path, paint);

      // 반대쪽 잎
      path.reset();
      path.moveTo(stemRect.right, leafY);
      path.quadraticBezierTo(stemRect.right + leafWidth, leafY - leafWidth / 2, stemRect.right, leafY - leafWidth);
      path.quadraticBezierTo(stemRect.right - leafWidth / 4, leafY - leafWidth / 2, stemRect.right, leafY);

      canvas.drawPath(path, paint);
    }
  }
}
