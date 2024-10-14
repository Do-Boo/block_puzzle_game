// import 'package:block_puzzle_game/utils/color_extensions.dart';
import 'package:block_puzzle_game/utils/block_3d.dart';
import 'package:block_puzzle_game/utils/color_extensions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../game/block_puzzle_game.dart';
import '../utils/constants.dart';
import 'dart:math' show pi;

class PieceComponent extends PositionComponent with DragCallbacks {
  final List<List<int>> piece;
  final Vector2 cellSize;
  final Vector2 gridPosition;
  final BlockPuzzleGame game;
  Vector2 dragDelta = Vector2.zero();
  late Vector2 originalPosition;
  static const double initialScale = 0.4; // 초기 크기 비율
  bool isDragging = false; // 드래그 상태를 추적

  PieceComponent({
    required this.piece,
    required this.cellSize,
    required Vector2 position,
    required this.gridPosition,
    required this.game,
  }) : super(position: position) {
    // 터치 범위를 넓히기 위해 size를 조정
    size = Vector2(piece[0].length * cellSize.x, piece.length * cellSize.y) * initialScale * 2;
    originalPosition = position.clone(); // 초기 위치를 저장
    priority = 100; // 우선순위를 더 높게 설정
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    if (!isDragging) {
      canvas.scale(initialScale, initialScale);
    }
    for (int row = 0; row < piece.length; row++) {
      for (int col = 0; col < piece[row].length; col++) {
        if (piece[row][col] != 0) {
          final rect = Rect.fromLTWH(col * cellSize.x, row * cellSize.y, cellSize.x, cellSize.y);
          final color = Constants.getColor(piece[row][col]);
          CartoonBlockPainter.paintBlock(canvas, rect, color);
        }
      }
    }
    canvas.restore();
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    dragDelta = event.localPosition;
    isDragging = true; // 드래그 시작 시 상태 변경

    size = Vector2(piece[0].length * cellSize.x, piece.length * cellSize.y); // 드래그 시작 시 원래 크기로 확장
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position = event.canvasPosition - dragDelta;
    position.x -= size.x - piece[0].length * cellSize.x / 2;
    position.y -= size.y + cellSize.y;
    final row = ((position.y - gridPosition.y) / cellSize.y).floor();
    final col = ((position.x - gridPosition.x) / cellSize.x).floor();
    game.updatePreview(row, col, piece);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    final row = ((position.y - gridPosition.y) / cellSize.y).floor();
    final col = ((position.x - gridPosition.x) / cellSize.x).floor();
    if (!game.gameState.canPlacePiece(row, col, piece)) {
      position = originalPosition.clone();
      game.updatePreview(-1, -1, []);
    } else {
      game.placePiece(row, col, piece);
    }
    isDragging = false; // 드래그 종료 시 상태 변경
    size = Vector2(piece[0].length * cellSize.x, piece.length * cellSize.y) * initialScale * 2; // 드래그 종료 시 다시 축소
  }
}
