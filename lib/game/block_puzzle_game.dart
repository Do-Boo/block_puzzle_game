import 'package:block_puzzle_game/components/particle_component.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../components/grid_component.dart';
import '../components/piece_component.dart';
import '../components/preview_component.dart';
import '../components/score_component.dart';
import '../utils/block_crush_effect.dart';
import '../utils/cartoon_spark_effect.dart';
import '../utils/game_state.dart';
import '../utils/piece_generator.dart';
import '../utils/constants.dart';
import '../utils/score_popup_effect.dart';

class BlockPuzzleGame extends FlameGame with HasCollisionDetection {
  late GameState gameState;
  late final PieceGenerator pieceGenerator;
  late final Vector2 gridPosition;
  late final Vector2 cellSize;
  late GridComponent gridComponent;
  bool isGameOver = false;

  static const Color kBackgroundColor = Color(0xFF533C36);
  static const Color kAccentColor = Color(0xFF392A25);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    cellSize = Vector2(size.x / Constants.COLS, size.x / Constants.COLS);
    gridPosition = Vector2(0, cellSize.y * 2);

    gameState = GameState();
    pieceGenerator = PieceGenerator();

    await _addComponents();
    spawnPieces();
  }

  @override
  void render(Canvas canvas) {
    _drawBackground(canvas);
    super.render(canvas);
  }

  void _drawBackground(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final paint = Paint()..color = kBackgroundColor;
    canvas.drawRect(rect, paint);

    // 배경 패턴 그리기
    final patternPaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..strokeWidth = 1;
    for (int i = 0; i < size.x; i += 20) {
      for (int j = 0; j < size.y; j += 20) {
        canvas.drawLine(
          Offset(i.toDouble(), j.toDouble()),
          Offset((i + 20).toDouble(), (j + 20).toDouble()),
          patternPaint,
        );
      }
    }
  }

  Future<void> _addComponents() async {
    gridComponent = GridComponent(position: gridPosition, cellSize: cellSize, gameState: gameState);
    add(gridComponent);
    add(PreviewComponent(cellSize: cellSize, gridPosition: gridPosition));
    add(ScoreComponent(position: Vector2(10, 10)));
  }

  void spawnPieces() {
    if (isGameOver) return;

    children.whereType<PieceComponent>().forEach((component) => component.removeFromParent());
    final double startX = (size.x - cellSize.x) / 3; // 조각을 화면 중앙에 배치
    final double startY = size.y - cellSize.y * 3; // 화면 하단에 위치
    for (var i = 0; i < 3; i++) {
      final piece = pieceGenerator.generatePiece();
      gameState.addPiece(piece);
      final pieceComponent = PieceComponent(
        piece: piece,
        cellSize: cellSize,
        position: Vector2(startX * i + cellSize.x * 1.2, startY),
        gridPosition: gridPosition,
        game: this,
      );
      add(pieceComponent);
    }

    checkGameOver();
  }

  void checkGameOver() {
    print('Checking game over...'); // 디버그 로그
    if (!gameState.canPlaceAnyPiece()) {
      print('Game over condition met!'); // 디버그 로그
      isGameOver = true;
      overlays.add('gameOver');
    }
  }

  void addBlockParticles(Vector2 position, Color color) {
    final particleComponent = BlockParticle(
      position: position,
      color: color,
    )..priority = 10; // 높은 우선순위 설정
    add(particleComponent);
  }

  Future<void> placePiece(int row, int col, List<List<int>> piece) async {
    if (isGameOver) return;

    if (gameState.canPlacePiece(row, col, piece)) {
      gameState.placePiece(row, col, piece);
      gridComponent.updateGrid();
      print('Grid component updated');
      children.whereType<PreviewComponent>().forEach((component) => component.clearPreview());

      HapticFeedback.lightImpact();

      List<int> linesToClear = gameState.getLinesToClear();
      if (linesToClear.isNotEmpty) {
        for (int line in linesToClear) {
          if (line < Constants.ROWS) {
            // 가로 줄 이펙트
            for (int j = 0; j < Constants.COLS; j++) {
              Vector2 sparkPosition = Vector2(
                gridPosition.x + j * cellSize.x + cellSize.x / 2,
                gridPosition.y + line * cellSize.y + cellSize.y / 2,
              );
              // add(BlockCrushEffect(position: sparkPosition, color: Constants.getColor(gameState.grid[line][j]), size: cellSize));
              add(CartoonSparkEffect(
                position: sparkPosition,
                color: Constants.getColor(gameState.grid[line][j]),
              ));
              add(ScorePopup(
                position: sparkPosition + Vector2(cellSize.x, 0), // 블록의 오른쪽에 표시
                score: 10, // 각 블록당 점수, 필요에 따라 조정
              ));
            }
          } else {
            // 세로 줄 이펙트
            int col = line - Constants.ROWS;
            for (int i = 0; i < Constants.ROWS; i++) {
              Vector2 sparkPosition = Vector2(
                gridPosition.x + col * cellSize.x + cellSize.x / 2,
                gridPosition.y + i * cellSize.y + cellSize.y / 2,
              );
              // add(BlockCrushEffect(position: sparkPosition, color: Constants.getColor(gameState.grid[i][col]), size: cellSize));
              add(CartoonSparkEffect(
                position: sparkPosition,
                color: Constants.getColor(gameState.grid[i][col]),
              ));
              add(ScorePopup(
                position: sparkPosition + Vector2(cellSize.x, 0), // 블록의 오른쪽에 표시
                score: 10, // 각 블록당 점수, 필요에 따라 조정
              ));
            }
          }
        }

        gameState.checkLines();
        gridComponent.updateGrid();
      }

      children.whereType<PieceComponent>().firstWhere((component) => component.piece == piece).removeFromParent();

      children.whereType<PieceComponent>().forEach((component) {
        component.priority = 10;
      });

      if (gameState.pieces.isEmpty) {
        spawnPieces();
      } else {
        checkGameOver();
      }
    } else {
      isGameOver = true;
      overlays.add('gameOver');
    }
  }

  void reset() {
    isGameOver = false;
    gameState = GameState();
    gridComponent.gameState = gameState;
    gridComponent.resetGrid();
    children.whereType<PieceComponent>().forEach((component) => component.removeFromParent());
    spawnPieces();
    overlays.remove('gameOver');
  }

  void addLineParticles(Vector2 startPosition, Vector2 endPosition, Color color) {
    // 줄 전체에 퍼지도록 여러 개의 파티클 생성
    for (double x = startPosition.x; x <= endPosition.x; x += cellSize.x / 4) {
      // 더 촘촘하게 파티클 생성
      final particleComponent = BlockParticle(
        position: Vector2(x, startPosition.y),
        color: color,
      );
      add(particleComponent);
    }
  }

  void updatePreview(int row, int col, List<List<int>> piece) {
    children.whereType<PreviewComponent>().forEach((component) => component.updatePreview(row, col, piece));
  }
}
