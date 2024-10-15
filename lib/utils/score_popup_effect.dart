import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class ScorePopup extends PositionComponent {
  final int score;
  late TextComponent _textComponent;
  late TextComponent _outlineComponent;
  double _opacity = 1.0;
  double _age = 0.0;

  ScorePopup({required Vector2 position, required this.score}) : super(position: position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    const outlineStyle = TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(offset: Offset(-1, -1), color: Colors.black),
        Shadow(offset: Offset(1, -1), color: Colors.black),
        Shadow(offset: Offset(1, 1), color: Colors.black),
        Shadow(offset: Offset(-1, 1), color: Colors.black),
      ],
    );

    _outlineComponent = TextComponent(
      text: '+$score',
      textRenderer: TextPaint(style: outlineStyle),
    );
    _textComponent = TextComponent(
      text: '+$score',
      textRenderer: TextPaint(style: textStyle),
    );

    add(_outlineComponent);
    add(_textComponent);

    final random = math.Random();
    final angle = (random.nextDouble() - 0.5) * 0.5; // -0.25 to 0.25 radians

    add(
      MoveEffect.by(
        Vector2(0, -30),
        EffectController(duration: 0.5, curve: Curves.easeOutQuad),
      ),
    );

    add(
      RotateEffect.by(
        angle,
        EffectController(duration: 0.5, curve: Curves.easeOutQuad),
      ),
    );

    add(
      ScaleEffect.by(
        Vector2.all(1.5),
        EffectController(duration: 0.1, reverseDuration: 0.1),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age > 0.3) {
      _opacity = math.max(0, _opacity - dt * 2);
      if (_opacity <= 0) {
        removeFromParent();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(width / 2, height / 2);
    canvas.scale(_opacity);
    canvas.translate(-width / 2, -height / 2);

    _outlineComponent.render(canvas);
    _textComponent.render(canvas);

    canvas.restore();
  }
}
