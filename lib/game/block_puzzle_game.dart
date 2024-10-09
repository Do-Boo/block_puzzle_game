import 'package:flame/game.dart';
import '../components/grid_component.dart';
import '../components/piece_component.dart';
import '../components/preview_component.dart';
import '../components/score_component.dart';
import '../utils/game_state.dart';
import '../utils/piece_generator.dart';
import '../utils/constants.dart';

class BlockPuzzleGame extends FlameGame with HasCollisionDetection {
  late GameState gameState;
  late final PieceGenerator pieceGenerator;
  late final Vector2 gridPosition;
  late final Vector2 cellSize;
  late GridComponent gridComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    cellSize = Vector2(size.x / Constants.COLS, size.x / Constants.COLS);
    gridPosition = Vector2(0, size.y - cellSize.y * Constants.ROWS);

    gameState = GameState();
    pieceGenerator = PieceGenerator();

    await _addComponents();
    spawnPieces();
  }

  Future<void> _addComponents() async {
    gridComponent = GridComponent(position: gridPosition, cellSize: cellSize, gameState: gameState);
    add(gridComponent);
    add(PreviewComponent(cellSize: cellSize, gridPosition: gridPosition));
    add(ScoreComponent(position: Vector2(10, 10)));
  }

  void spawnPieces() {
    children.whereType<PieceComponent>().forEach((component) => component.removeFromParent());
    for (var i = 0; i < 3; i++) {
      final piece = pieceGenerator.generatePiece();
      gameState.addPiece(piece);
      final pieceComponent = PieceComponent(
        piece: piece,
        cellSize: cellSize,
        position: Vector2(i * (size.x / 3), 0),
        gridPosition: gridPosition,
        game: this,
      );
      add(pieceComponent);
    }
  }

  Future<void> placePiece(int row, int col, List<List<int>> piece) async {
    if (gameState.canPlacePiece(row, col, piece)) {
      gameState.placePiece(row, col, piece);
      children.whereType<PreviewComponent>().forEach((component) => component.clearPreview());
      if (gameState.checkLines() > 0) {
        // Handle line clearing (maybe add score, play sound, etc.)
      }
      gridComponent.updateGrid();
      children.whereType<PieceComponent>().firstWhere((component) => component.piece == piece).removeFromParent();
      if (gameState.pieces.isEmpty) {
        spawnPieces();
      }
    }
  }

  void updatePreview(int row, int col, List<List<int>> piece) {
    children.whereType<PreviewComponent>().forEach((component) => component.updatePreview(row, col, piece));
  }
}
