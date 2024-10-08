import 'package:block_puzzle_game/ex/game_borad.dart';
import 'package:block_puzzle_game/ex/game_instructions_dialog.dart';
import 'package:block_puzzle_game/ex/game_over_dialog.dart';
import 'package:block_puzzle_game/ex/game_pieces.dart';
import 'package:block_puzzle_game/ex/score_board.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tetris Puzzle Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
        create: (context) => GameState(),
        child: const GameScreen(),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Consumer<GameState>(
      builder: (context, gameState, child) {
        if (gameState.gameOver) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (BuildContext context) => const GameOverDialog(),
            );
          });
        }
        return const SizedBox.shrink();
      },
    );

    void showInstructions(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) => const InstructionsDialog(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tetris Puzzle Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showInstructions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: GameBoard(),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const NextPieces(),
                      const ScoreBoard(),
                      ElevatedButton(
                        onPressed: () {
                          context.read<GameState>().startGame();
                        },
                        child: const Text('Start Game'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
