import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class BlockCrushEffect extends PositionComponent {
  final Color color;

  BlockCrushEffect({required Vector2 position, required this.color, required Vector2 size}) : super(position: position) {
    this.size = size;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final crushEffect = SequenceEffect(
      [
        MoveEffect.by(
          Vector2(size.x / 4, size.y / 4),
          EffectController(duration: 0.1),
        ),
        ScaleEffect.by(
          Vector2(0.5, 0.5),
          EffectController(duration: 0.1),
        ),
      ],
      alternate: true,
    );

    final fadeEffect = OpacityEffect.fadeOut(
      EffectController(duration: 0.2),
    );

    add(crushEffect);
    add(fadeEffect);
    add(RemoveEffect(delay: 0.2));
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    final paint = Paint()..color = color;
    canvas.drawRect(rect, paint);

    // 블록 내부 라인 그리기
    final linePaint = Paint()
      ..color = color.darken()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(Offset(size.x / 3, 0), Offset(size.x / 3, size.y), linePaint);
    canvas.drawLine(Offset(size.x * 2 / 3, 0), Offset(size.x * 2 / 3, size.y), linePaint);
    canvas.drawLine(Offset(0, size.y / 3), Offset(size.x, size.y / 3), linePaint);
    canvas.drawLine(Offset(0, size.y * 2 / 3), Offset(size.x, size.y * 2 / 3), linePaint);
  }
}

extension ColorExtension on Color {
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
