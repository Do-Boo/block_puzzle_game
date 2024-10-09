import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/block_puzzle_game.dart';
import '../utils/localization.dart';

class ScoreComponent extends PositionComponent with HasGameRef<BlockPuzzleGame> {
  late TextPainter _painter;
  late TextStyle _textStyle;
  String _text = '';

  ScoreComponent({required Vector2 position}) : super(position: position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _textStyle = const TextStyle(color: Colors.white, fontSize: 24);
    _painter = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.ltr);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _text = '${AppLocalizations.current.score}: ${gameRef.gameState.score}';
    _painter.text = TextSpan(text: _text, style: _textStyle);
    _painter.layout();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _painter.paint(canvas, Offset.zero);
  }
}
