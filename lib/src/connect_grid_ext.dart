import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'models/tile.dart';

extension ConnectGridExt on AStar {
  /// Adds neighbors to cells
  void addNeighbors(List<List<Tile>> grid) {
    for (var row in grid) {
      for (Tile tile in row) {
        _chainNeigbors(tile, grid);
      }
    }
  }

  void _chainNeigbors(Tile tile, List<List<Tile>> grid) {
    int x = tile.position.x;
    int y = tile.position.y;

    /// adds in top
    if (y > 0) {
      final t = grid[x][y - 1];
      if (t.isFree) {
        tile.neighbors.add(t);
      }
    }

    /// adds in bottom
    if (y < (grid.first.length - 1)) {
      final t = grid[x][y + 1];
      if (t.isFree) {
        tile.neighbors.add(t);
      }
    }

    /// adds in left
    if (x > 0) {
      final t = grid[x - 1][y];
      if (t.isFree) {
        tile.neighbors.add(t);
      }
    }

    /// adds in right
    if (x < (grid.length - 1)) {
      final t = grid[x + 1][y];
      if (t.isFree) {
        tile.neighbors.add(t);
      }
    }

    if (withDiagonal) {
      /// adds in top-left
      if (y > 0 && x > 0) {
        final top = grid[x][y - 1];
        final left = grid[x - 1][y];
        final t = grid[x - 1][y - 1];
        if (t.isFree && left.isFree && top.isFree) {
          tile.neighbors.add(t);
        }
      }

      /// adds in top-right
      if (y > 0 && x < (grid.length - 1)) {
        final top = grid[x][y - 1];
        final right = grid[x + 1][y];
        final t = grid[x + 1][y - 1];
        if (t.isFree && top.isFree && right.isFree) {
          tile.neighbors.add(t);
        }
      }

      /// adds in bottom-left
      if (x > 0 && y < (grid.first.length - 1)) {
        final bottom = grid[x][y + 1];
        final left = grid[x - 1][y];
        final t = grid[x - 1][y + 1];
        if (t.isFree && bottom.isFree && left.isFree) {
          tile.neighbors.add(t);
        }
      }

      /// adds in bottom-right
      if (x < (grid.length - 1) && y < (grid.first.length - 1)) {
        final bottom = grid[x][y + 1];
        final right = grid[x + 1][y];
        final t = grid[x + 1][y + 1];
        if (t.isFree && bottom.isFree && right.isFree) {
          tile.neighbors.add(t);
        }
      }
    }
  }

}
