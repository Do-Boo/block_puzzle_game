import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class ScorePopup extends TextComponent {
  double elapsedTime = 0.0; // elapsedTime 변수 추가

  ScorePopup({required Vector2 position, required int score})
      : super(
          text: '+$score',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.yellow,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          position: position,
        ) {
    add(MoveByEffect(
      Vector2(0, -20),
      EffectController(duration: 1),
    ));
    add(RemoveEffect(delay: 1));
  }

  @override
  void update(double dt) {
    super.update(dt);
    elapsedTime += dt; // elapsedTime 갱신
    final opacity = (1.0 - (elapsedTime / 0.5)).clamp(0.0, 1.0); // opacity 값을 0과 1 사이로 제한
    textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.yellow.withOpacity(opacity),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
