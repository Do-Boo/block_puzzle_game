import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_state.dart';

class NextPieces extends StatelessWidget {
  const NextPieces({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    return Column(
      children: [
        const Text('Next Pieces', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...gameState.nextPieces.map((piece) => _buildPiecePreview(piece)),
      ],
    );
  }

  Widget _buildPiecePreview(List<List<bool>> piece) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: 60,
      height: 60,
      child: CustomPaint(
        painter: PiecePainter(piece),
      ),
    );
  }
}

class PiecePainter extends CustomPainter {
  final List<List<bool>> piece;

  PiecePainter(this.piece);

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 4;
    for (int y = 0; y < piece.length; y++) {
      for (int x = 0; x < piece[y].length; x++) {
        if (piece[y][x]) {
          final rect = Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize);
          canvas.drawRect(rect, Paint()..color = Colors.blue);
          canvas.drawRect(
              rect,
              Paint()
                ..color = Colors.black
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.0);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
