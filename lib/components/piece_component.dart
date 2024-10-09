import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../game/block_puzzle_game.dart';
import '../utils/constants.dart';

class PieceComponent extends PositionComponent with DragCallbacks {
  final List<List<int>> piece;
  final Vector2 cellSize;
  final Vector2 gridPosition;
  final BlockPuzzleGame game;
  Vector2 dragDelta = Vector2.zero();
  late Vector2 originalPosition;

  PieceComponent({
    required this.piece,
    required this.cellSize,
    required Vector2 position,
    required this.gridPosition,
    required this.game,
  }) : super(position: position) {
    size = Vector2(piece[0].length * cellSize.x, piece.length * cellSize.y);
    originalPosition = position.clone(); // 초기 위치를 저장
  }

  @override
  void render(Canvas canvas) {
    for (int row = 0; row < piece.length; row++) {
      for (int col = 0; col < piece[row].length; col++) {
        if (piece[row][col] != 0) {
          final rect = Rect.fromLTWH(col * cellSize.x, row * cellSize.y, cellSize.x, cellSize.y);
          canvas.drawRect(rect, Paint()..color = Constants.getColor(piece[row][col]));
          canvas.drawRect(
              rect,
              Paint()
                ..color = Colors.black
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1);
        }
      }
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    dragDelta = event.localPosition;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position = event.canvasPosition - dragDelta;
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
    game.placePiece(row, col, piece);
  }
}
