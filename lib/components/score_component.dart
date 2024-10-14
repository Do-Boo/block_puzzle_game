import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/block_puzzle_game.dart';
import '../utils/localization.dart';

class ScoreComponent extends TextComponent with HasGameRef<BlockPuzzleGame> {
  ScoreComponent({required Vector2 position})
      : super(
          position: position,
          text: '',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

  @override
  void update(double dt) {
    super.update(dt);
    text = '${AppLocalizations.current.score}: ${gameRef.gameState.score}';
  }
}
