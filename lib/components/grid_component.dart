import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:block_puzzle_game/utils/block_3d.dart';
import 'package:block_puzzle_game/utils/game_state.dart';

import '../utils/constants.dart';

class GridComponent extends PositionComponent with HasGameRef {
  final Vector2 cellSize;
  late GameState gameState;
  final Color grassDarkColor = const Color(0xFF4CAF50);
  final Color grassLightColor = const Color(0xFF8BC34A);
  final Color stoneColor = const Color(0xFF808080);
  final Color sandColor = const Color(0xFFF4A460);
  final math.Random random = math.Random(42);
  late List<List<_CellDecoration>> cellDecorations;
  ui.Image? _cachedBackgroundImage;
  final Map<Color, ui.Image?> _noiseTextures = {};
  bool _isGeneratingBackground = false;
  final bool _disposed = false;

  GridComponent({required Vector2 position, required this.cellSize, required this.gameState}) : super(position: position) {
    priority = -1;
    size = Vector2(Constants.COLS * cellSize.x, Constants.ROWS * cellSize.y);
    _generateCellDecorations();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _generateCellDecorations();
    await _generateNoiseTextures();
    await _generateAndCacheBackground();
  }

  void _generateCellDecorations() {
    cellDecorations = List.generate(
      Constants.ROWS,
      (row) => List.generate(
        Constants.COLS,
        (col) => _generateCellDecoration(row, col),
      ),
    );
  }

  Future<void> _generateNoiseTextures() async {
    final baseColors = [grassDarkColor, grassLightColor];
    for (final color in baseColors) {
      _noiseTextures[color] = await _generateNoiseTexture(Vector2(cellSize.x, cellSize.y), color);
    }
  }

  Future<ui.Image?> _generateNoiseTexture(Vector2 size, Color baseColor) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    final paint = Paint()..color = baseColor;
    canvas.drawRect(rect, paint);

    final noisePaint = Paint()..color = Colors.black.withOpacity(0.1);
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.x;
      final y = random.nextDouble() * size.y;
      canvas.drawCircle(Offset(x, y), 1, noisePaint);
    }

    final picture = recorder.endRecording();
    return await picture.toImage(size.x.toInt(), size.y.toInt());
  }

  _CellDecoration _generateCellDecoration(int row, int col) {
    final baseColor = ((row + col) % 2 == 0) ? grassDarkColor : grassLightColor;
    final grassCount = 2 + random.nextInt(2);
    final hasStone = random.nextDouble() < 0.1;
    final hasSand = random.nextDouble() < 0.05;
    final grassDensity = random.nextDouble();
    final height = 0.8 + random.nextDouble() * 0.4; // 0.8에서 1.2 사이의 랜덤 높이

    return _CellDecoration(
      baseColor: baseColor,
      grasses: List.generate(grassCount, (_) => _CartoonGrass(random, baseColor)),
      hasStone: hasStone,
      hasSand: hasSand,
      grassDensity: grassDensity,
      height: height,
    );
  }

  Future<void> _generateAndCacheBackground() async {
    if (_isGeneratingBackground || _disposed) return;
    _isGeneratingBackground = true;

    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final rect = Rect.fromLTWH(0, 0, size.x, size.y);

      _drawGridBackgroundSafe(canvas);
      drawCellDecorations(canvas);

      final picture = recorder.endRecording();
      final image = await picture.toImage(size.x.toInt(), size.y.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (!_disposed && byteData != null) {
        _cachedBackgroundImage = await decodeImageFromList(byteData.buffer.asUint8List());
      }
    } catch (e) {
      print('Error generating background: $e');
    } finally {
      _isGeneratingBackground = false;
    }
  }

  void _drawGridBackgroundSafe(Canvas canvas) {
    try {
      _drawGridBackground(canvas);
    } catch (e) {
      print('Error drawing grid background: $e');
    }
  }

  void _drawCellDecorationsSafe(Canvas canvas) {
    try {
      drawCellDecorations(canvas);
    } catch (e) {
      print('Error drawing cell decorations: $e');
    }
  }

  @override
  void render(Canvas canvas) {
    if (_disposed) return;

    if (_cachedBackgroundImage != null) {
      try {
        canvas.drawImage(_cachedBackgroundImage!, Offset.zero, Paint());
      } catch (e) {
        print('Error drawing cached background: $e');
        _cachedBackgroundImage = null;
        _drawGridBackgroundSafe(canvas);
        _drawCellDecorationsSafe(canvas);
      }
    } else {
      _drawGridBackgroundSafe(canvas);
      _drawCellDecorationsSafe(canvas);
    }
    _drawBlocksSafe(canvas);
  }

  void _drawBlocksSafe(Canvas canvas) {
    try {
      drawBlocks(canvas);
    } catch (e) {
      print('Error drawing blocks: $e');
    }
  }

  @override
  void update(double dt) {
    if (_disposed) return;
    super.update(dt);
    if (_cachedBackgroundImage == null && !_isGeneratingBackground) {
      _generateAndCacheBackground();
    }
  }

  @override
  void onRemove() {
    for (final texture in _noiseTextures.values) {
      texture?.dispose();
    }
    _noiseTextures.clear();
    _cachedBackgroundImage?.dispose();
    _cachedBackgroundImage = null;
    super.onRemove();
  }

  void _drawGridBackground(Canvas canvas) {
    for (int row = 0; row < Constants.ROWS; row++) {
      for (int col = 0; col < Constants.COLS; col++) {
        final rect = Rect.fromLTWH(col * cellSize.x, row * cellSize.y, cellSize.x, cellSize.y);
        final decoration = cellDecorations[row][col];

        // 셀의 높이에 따른 그림자 효과
        final shadowRect = Rect.fromLTWH(rect.left, rect.top + cellSize.y * (1 - decoration.height), cellSize.x, cellSize.y * decoration.height);
        canvas.drawRect(shadowRect, Paint()..color = Colors.black.withOpacity(0.1 * (decoration.height - 0.8) / 0.4));

        // 셀의 높이에 따른 메인 색상 그리기
        final mainRect = Rect.fromLTWH(rect.left, rect.top + cellSize.y * (1 - decoration.height), cellSize.x, cellSize.y * decoration.height);
        final noiseTexture = _noiseTextures[decoration.baseColor];
        if (noiseTexture != null) {
          final shader = ImageShader(
            noiseTexture,
            TileMode.repeated,
            TileMode.repeated,
            Matrix4.identity().storage,
          );
          canvas.drawRect(mainRect, Paint()..shader = shader);
        } else {
          canvas.drawRect(mainRect, Paint()..color = decoration.baseColor);
        }

        // 셀 테두리 효과
        final borderPaint = Paint()
          ..color = Colors.black.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        canvas.drawRect(mainRect, borderPaint);

        // 셀 상단 하이라이트 효과
        final highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        canvas.drawLine(mainRect.topLeft, mainRect.topRight, highlightPaint);
        canvas.drawLine(mainRect.topLeft, mainRect.bottomLeft, highlightPaint);

        // 모래 그리기 (입체감 추가)
        if (decoration.hasSand) {
          final sandPaint = Paint()..color = sandColor.withOpacity(0.3);
          canvas.drawRect(rect, sandPaint);

          // 모래 그림자
          final sandShadowPaint = Paint()
            ..color = Colors.black.withOpacity(0.1)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
          canvas.drawLine(rect.bottomLeft.translate(0, -2), rect.bottomRight.translate(0, -2), sandShadowPaint);
          canvas.drawLine(rect.topRight.translate(-2, 0), rect.bottomRight.translate(-2, 0), sandShadowPaint);
        }

        // 돌 그리기 (입체감 강화)
        if (decoration.hasStone) {
          final stoneRect = Rect.fromCenter(
            center: rect.center,
            width: rect.width * 0.6,
            height: rect.height * 0.6,
          );

          // 돌 그림자 (더 강하게)
          canvas.drawOval(
            stoneRect.translate(4, 4),
            Paint()..color = Colors.black.withOpacity(0.3),
          );

          // 돌
          final stonePaint = Paint()..color = stoneColor;
          canvas.drawOval(stoneRect, stonePaint);

          // 돌 하이라이트
          final stoneHighlightPaint = Paint()
            ..color = Colors.white.withOpacity(0.2)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
          canvas.drawArc(stoneRect, -0.5, 1.5, false, stoneHighlightPaint);
        }
      }
    }
  }

  Future<ui.Image> generateNoiseTexture(Size size, Color baseColor) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final paint = Paint()..color = baseColor;
    canvas.drawRect(rect, paint);

    final noisePaint = Paint()..color = Colors.black.withOpacity(0.1);
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 1, noisePaint);
    }

    final picture = recorder.endRecording();
    return picture.toImage(size.width.toInt(), size.height.toInt());
  }

  void drawCellDecorations(Canvas canvas) {
    for (int row = 0; row < Constants.ROWS; row++) {
      for (int col = 0; col < Constants.COLS; col++) {
        final cellRect = Rect.fromLTWH(col * cellSize.x, row * cellSize.y, cellSize.x, cellSize.y);
        final decoration = cellDecorations[row][col];

        // Apply grass density
        final adjustedColor = decoration.baseColor.withOpacity(0.5 + decoration.grassDensity * 0.5);
        canvas.drawRect(cellRect, Paint()..color = adjustedColor);

        // Draw grass
        for (var grass in decoration.grasses) {
          grass.draw(canvas, cellRect);
        }
      }
    }
  }

  void drawBlocks(Canvas canvas) {
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

class _CellDecoration {
  final Color baseColor;
  final List<_CartoonGrass> grasses;
  final bool hasStone;
  final bool hasSand;
  final double grassDensity;
  final double height; // 새로운 높이 속성 추가

  _CellDecoration({
    required this.baseColor,
    required this.grasses,
    required this.hasStone,
    required this.hasSand,
    required this.grassDensity,
    required this.height, // 생성자에 높이 추가
  });
}

class _CartoonGrass {
  final double x;
  final double height;
  final Color color;
  final int leafCount;
  final double bend;

  _CartoonGrass(math.Random random, Color baseColor)
      : x = random.nextDouble(),
        height = 0.2 + random.nextDouble() * 0.3,
        color = baseColor.withOpacity(0.8 + random.nextDouble() * 0.2),
        leafCount = 2 + random.nextInt(2),
        bend = (random.nextDouble() - 0.5) * 0.2;

  void draw(Canvas canvas, Rect cellRect) {
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.7), color],
      ).createShader(cellRect);

    final stemWidth = cellRect.width * 0.05;
    final stemHeight = cellRect.height * height;
    final stemRect = Rect.fromLTWH(cellRect.left + x * cellRect.width - stemWidth / 2, cellRect.bottom - stemHeight, stemWidth, stemHeight);

    // Draw bent stem
    final path = Path()
      ..moveTo(stemRect.bottomCenter.dx, stemRect.bottomCenter.dy)
      ..quadraticBezierTo(
        stemRect.center.dx + bend * cellRect.width,
        stemRect.center.dy,
        stemRect.topCenter.dx,
        stemRect.topCenter.dy,
      );
    canvas.drawPath(path, gradientPaint); // 여기서 gradientPaint 사용

    // Draw leaves
    for (int i = 0; i < leafCount; i++) {
      final leafHeight = stemHeight * (0.3 + 0.2 * i);
      final leafWidth = cellRect.width * 0.15;
      final leafY = cellRect.bottom - leafHeight;

      final leafPath = Path()
        ..moveTo(stemRect.left, leafY)
        ..quadraticBezierTo(stemRect.left - leafWidth, leafY - leafWidth / 2, stemRect.left, leafY - leafWidth)
        ..quadraticBezierTo(stemRect.left + leafWidth / 4, leafY - leafWidth / 2, stemRect.left, leafY);

      canvas.drawPath(leafPath, gradientPaint); // 여기서도 gradientPaint 사용

      // Opposite leaf
      leafPath.reset();
      leafPath.moveTo(stemRect.right, leafY);
      leafPath.quadraticBezierTo(stemRect.right + leafWidth, leafY - leafWidth / 2, stemRect.right, leafY - leafWidth);
      leafPath.quadraticBezierTo(stemRect.right - leafWidth / 4, leafY - leafWidth / 2, stemRect.right, leafY);

      canvas.drawPath(leafPath, gradientPaint); // 여기서도 gradientPaint 사용
    }
  }
}
