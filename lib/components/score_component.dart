import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../game/block_puzzle_game.dart';
import '../utils/localization.dart';
import '../utils/preferences_manager.dart';

class ScoreComponent extends PositionComponent with HasGameRef<BlockPuzzleGame> {
  late TextComponent highScoreText;
  late TextComponent currentScoreText;
  late TextComponent comboText;
  late RectangleComponent highScoreBackground;
  int combo = 0;

  ScoreComponent({required Vector2 position}) : super(position: position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 최고 점수 배경
    highScoreBackground = RectangleComponent(
      size: Vector2(200, 40),
      paint: Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..style = PaintingStyle.fill,
    );
    add(highScoreBackground);

    highScoreText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF392A25), // 어두운 갈색
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
    );
    add(highScoreText);

    currentScoreText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 3,
              color: Color(0xFF392A25),
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
    );
    add(currentScoreText);

    comboText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 60,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 3,
              color: Colors.red,
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
    );
    add(comboText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateScores();

    // 현재 점수 텍스트 위치 조정
    currentScoreText.position = Vector2(
      gameRef.size.x / 2,
      gameRef.gridPosition.y - 60,
    );

    // 최고 점수 배경 및 텍스트 위치 조정
    highScoreBackground.position = Vector2(10, 10);
    highScoreText.position = Vector2(110, 30); // 배경의 중앙

    comboText.position = Vector2(
      gameRef.size.x / 2,
      gameRef.gridPosition.y + gameRef.size.y / 2,
    );
  }

  void _updateScores() async {
    int highScore = await PreferencesManager.getHighScore();
    highScoreText.text = '${AppLocalizations.current.highScore}: $highScore';
    currentScoreText.text = '${gameRef.gameState.score}';

    if (gameRef.gameState.score > highScore) {
      await PreferencesManager.setHighScore(gameRef.gameState.score);
    }
  }

  void addScore(int linesCleared) {
    int baseScore = linesCleared * 100;
    int bonusScore = linesCleared > 1 ? (linesCleared - 1) * 50 : 0;
    int comboBonus = combo * 10;

    int totalScore = baseScore + bonusScore + comboBonus;
    gameRef.gameState.addScore(totalScore);

    combo++;
    _showComboEffect();
  }

  void resetCombo() {
    combo = 0;
    comboText.text = '';
  }

  void _showComboEffect() {
    if (combo > 1) {
      comboText.text = '${combo}x 콤보!';
      comboText.add(
        ScaleEffect.by(
          Vector2.all(1.5),
          EffectController(duration: 0.5, reverseDuration: 0.5),
        ),
      );
      comboText.add(
        MoveEffect.by(
          Vector2(0, -50),
          EffectController(duration: 0.5, reverseDuration: 0.5),
        ),
      );
    }
  }
}
