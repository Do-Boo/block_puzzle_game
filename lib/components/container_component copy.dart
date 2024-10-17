import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../utils/game_state.dart';
import '../utils/constants.dart';

class ContainerComponent extends PositionComponent {
  final Vector2 cellSize;
  late GameState gameState;
  late ui.Image? _cachedPiecesImage;

  ContainerComponent({required Vector2 position, required this.cellSize, required this.gameState}) : super(position: position) {
    size = Vector2((Constants.COLS + 2) * cellSize.x, (Constants.ROWS + 2) * cellSize.y);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _generateAndCachePiecesImage();
  }

  Future<void> _generateAndCachePiecesImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    final piecesBgGradient = ui.Gradient.linear(
      Offset(cellSize.x, cellSize.y),
      Offset(size.x - cellSize.x, size.y - cellSize.y),
      [const ui.Color.fromARGB(236, 58, 46, 39), const ui.Color.fromARGB(236, 58, 46, 39)],
    );
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(10)), Paint()..shader = piecesBgGradient);

    final picture = recorder.endRecording();
    _cachedPiecesImage = await picture.toImage(size.x.toInt(), size.y.toInt());
  }

  @override
  void render(Canvas canvas) {
    if (_cachedPiecesImage != null) {
      canvas.drawImage(_cachedPiecesImage!, Offset.zero, Paint());
    }
  }

  void resetGrid() {
    gameState.clearGrid();
  }

  void updateGrid() {
    // 그리드 업데이트 로직
  }
}
