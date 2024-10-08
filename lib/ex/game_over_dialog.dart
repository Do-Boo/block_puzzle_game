import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_state.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    return AlertDialog(
      title: const Text('Game Over'),
      content: Text('Your score: ${gameState.score}'),
      actions: [
        TextButton(
          onPressed: () {
            gameState.startGame();
            Navigator.of(context).pop();
          },
          child: const Text('Play Again'),
        ),
      ],
    );
  }
}
