import 'dart:math' as math;
import 'package:flutter/material.dart';

class CartoonStonePainter {
  static void paintStone(Canvas canvas, Rect rect, Color color) {
    final random = math.Random(color.value);

    // 돌의 기본 형태
    final stonePath = Path();
    final radius = rect.width / 2;
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final radiusVariation = radius * (0.9 + random.nextDouble() * 0.2);
      final x = rect.center.dx + math.cos(angle) * radiusVariation;
      final y = rect.center.dy + math.sin(angle) * radiusVariation;
      i == 0 ? stonePath.moveTo(x, y) : stonePath.lineTo(x, y);
    }
    stonePath.close();

    // 그림자
    canvas.drawPath(
      stonePath.shift(const Offset(2, 2)),
      Paint()..color = Colors.black.withOpacity(0.3),
    );

    // 돌 본체
    final stonePaint = Paint()..color = color;
    canvas.drawPath(stonePath, stonePaint);

    // 질감 추가
    final texturePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = 0; i < 5; i++) {
      final startX = rect.left + random.nextDouble() * rect.width;
      final startY = rect.top + random.nextDouble() * rect.height;
      final endX = startX + random.nextDouble() * rect.width / 2 - rect.width / 4;
      final endY = startY + random.nextDouble() * rect.height / 2 - rect.height / 4;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), texturePaint);
    }

    // 하이라이트
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(
      rect.deflate(rect.width * 0.1),
      -math.pi / 4,
      math.pi / 2,
      false,
      highlightPaint,
    );
  }
}
