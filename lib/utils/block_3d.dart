import 'package:flutter/material.dart';
import 'dart:math' as math;

class CartoonBlockPainter {
  static void paintBlock(Canvas canvas, Rect rect, Color color) {
    final paint = Paint();

    // 블록의 기본 색상
    paint.color = color;
    canvas.drawRect(rect, paint);

    // 텍스처 추가 (랜덤한 작은 원들)
    final random = math.Random(color.value);
    paint.color = color.darken(20).withOpacity(0.3);
    for (int i = 0; i < 10; i++) {
      final x = rect.left + random.nextDouble() * rect.width;
      final y = rect.top + random.nextDouble() * rect.height;
      canvas.drawCircle(Offset(x, y), rect.width * 0.05, paint);
    }

    // 하이라이트 (블록 상단에 불규칙한 형태의 밝은 부분)
    final highlightPath = Path();
    highlightPath.moveTo(rect.left, rect.top);
    for (int i = 0; i < 5; i++) {
      final x = rect.left + (rect.width / 5) * i;
      final y = rect.top + random.nextDouble() * rect.height * 0.2;
      highlightPath.lineTo(x, y);
    }
    highlightPath.lineTo(rect.right, rect.top);
    highlightPath.close();

    paint.color = color.brighten(30).withOpacity(0.5);
    canvas.drawPath(highlightPath, paint);

    // 과장된 윤곽선
    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(rect, outlinePaint);

    // 카툰 스타일의 그림자 (단순한 사선 패턴)
    final shadowPath = Path();
    for (int i = 0; i < 3; i++) {
      shadowPath.moveTo(rect.right - i * 5, rect.bottom);
      shadowPath.lineTo(rect.right, rect.bottom - i * 5);
    }
    canvas.drawPath(
        shadowPath,
        Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }
}

extension ColorExtension on Color {
  Color brighten(int amount) {
    return Color.fromARGB(
      alpha,
      (red + amount).clamp(0, 255),
      (green + amount).clamp(0, 255),
      (blue + amount).clamp(0, 255),
    );
  }

  Color darken(int amount) {
    return Color.fromARGB(
      alpha,
      (red - amount).clamp(0, 255),
      (green - amount).clamp(0, 255),
      (blue - amount).clamp(0, 255),
    );
  }
}
