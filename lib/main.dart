import 'package:block_puzzle_game/s_game_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() => runApp(const BlockPuzzleApp());

class BlockPuzzleApp extends StatelessWidget {
  const BlockPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Block Puzzle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C2C2C),
          elevation: 0,
        ),
      ),
      home: const GameScreen(),
    );
  }
}
