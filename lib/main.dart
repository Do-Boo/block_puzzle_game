import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flame/game.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'game/block_puzzle_game.dart';
import 'utils/localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLocalizations.loadCurrentLocale(const Locale('ko', ''));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Block Puzzle',
      theme: ThemeData(primarySwatch: Colors.blue),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en', ''),
      home: SafeArea(
        child: GameWidget<BlockPuzzleGame>(
          game: BlockPuzzleGame(),
          overlayBuilderMap: {
            'gameOver': (_, game) => GameOverOverlay(game: game),
          },
          initialActiveOverlays: const [],
        ),
      ),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  final BlockPuzzleGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.black.withOpacity(0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.current.gameOver,
              style: const TextStyle(color: Colors.white, fontSize: 30),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                game.reset(); // 게임을 다시 시작
              },
              child: Text(AppLocalizations.current.restart),
            ),
          ],
        ),
      ),
    );
  }
}
