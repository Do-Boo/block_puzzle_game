import 'package:flutter/material.dart';

class InstructionsDialog extends StatelessWidget {
  const InstructionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('How to Play'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('1. Tap on the board to place the current piece.'),
          Text('2. Complete a row to clear it and score points.'),
          Text('3. The game ends when you can\'t place a new piece.'),
          Text('4. Try to score as many points as possible!'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Got it!'),
        ),
      ],
    );
  }
}
