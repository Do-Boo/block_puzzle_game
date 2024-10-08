import 'package:block_puzzle_game/ex/game_fade_in_piece.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_state.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    return GestureDetector(
      onTapUp: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        final x = (localPosition.dx / (box.size.width / GameState.boardWidth)).floor();
        final y = (localPosition.dy / (box.size.height / GameState.boardHeight)).floor();
        gameState.placePiece(x, y);
      },
      child: AspectRatio(
        aspectRatio: GameState.boardWidth / GameState.boardHeight,
        child: FadeInPiece(
          child: CustomPaint(
            painter: BoardPainter(gameState),
          ),
        ),
      ),
    );
  }
}

class BoardPainter extends CustomPainter {
  final GameState gameState;

  BoardPainter(this.gameState);
  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / GameState.boardWidth;
    final cellHeight = size.height / GameState.boardHeight;

    for (int y = 0; y < GameState.boardHeight; y++) {
      for (int x = 0; x < GameState.boardWidth; x++) {
        final color = gameState.board[y][x] ?? Colors.grey[300];
        final rect = Rect.fromLTWH(x * cellWidth, y * cellHeight, cellWidth, cellHeight);
        canvas.drawRect(rect, Paint()..color = color!);
        canvas.drawRect(
            rect,
            Paint()
              ..color = Colors.black
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0);
      }
    }

    if (gameState.currentPiece != null) {
      final piece = gameState.currentPiece!;
      final color = gameState.currentPieceColor ?? Colors.grey;
      for (int y = 0; y < piece.length; y++) {
        for (int x = 0; x < piece[y].length; x++) {
          if (piece[y][x]) {
            final rect = Rect.fromLTWH(x * cellWidth, y * cellHeight, cellWidth, cellHeight);
            canvas.drawRect(rect, Paint()..color = color.withOpacity(0.5));
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
