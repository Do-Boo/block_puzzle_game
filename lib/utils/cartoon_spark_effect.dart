import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class CartoonSparkEffect extends ParticleSystemComponent {
  CartoonSparkEffect({required Vector2 position, required Color color})
      : super(
          position: position,
          particle: Particle.generate(
            count: 12,
            lifespan: 0.8,
            generator: (i) => _createPuzzlePiece(color, i),
          ),
        );

  static Particle _createPuzzlePiece(Color color, int index) {
    final random = Random();
    final speed = random.nextDouble() * 100 + 50;
    final direction = Vector2(cos(index * pi / 6), sin(index * pi / 6));

    return MovingParticle(
      curve: Curves.easeOutQuad,
      from: Vector2.zero(),
      to: direction * speed,
      child: RotatingParticle(
        to: random.nextDouble() * 2 * pi,
        child: ScalingParticle(
          lifespan: 0.8,
          child: _PuzzlePieceParticle(color: color.withOpacity(0.5), index: index), // 투명도 조절
        ),
      ),
    );
  }
}

class _PuzzlePieceParticle extends Particle {
  final Color color;
  final int index;
  final Paint _paint;
  final Path _path;

  _PuzzlePieceParticle({required this.color, required this.index})
      : _paint = Paint()..color = color,
        _path = _createPuzzlePiecePath(index);

  static Path _createPuzzlePiecePath(int index) {
    final path = Path();
    final random = Random(index); // 각 조각마다 고유한 형태를 가지도록 함

    path.moveTo(0, 0);
    for (int i = 0; i < 5; i++) {
      final x = random.nextDouble() * 10;
      final y = random.nextDouble() * 10;
      path.lineTo(x, y);
    }
    path.close();

    return path;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPath(_path, _paint);
  }
}
