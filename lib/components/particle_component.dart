import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class BlockParticle extends ParticleSystemComponent {
  BlockParticle({
    required Vector2 position,
    required Color color,
  }) : super(
          position: position,
          particle: Particle.generate(
            count: 15,
            lifespan: 0.8,
            generator: (i) => AcceleratedParticle(
              acceleration: Vector2(0, 50),
              speed: Vector2(Random().nextDouble() * 100 - 50, Random().nextDouble() * -50 - 50),
              position: Vector2.zero(),
              child: RotatingParticle(
                to: Random().nextDouble() * pi,
                child: ComposedParticle(
                  children: [
                    CircleParticle(
                      radius: 2,
                      paint: Paint()..color = color,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
}
