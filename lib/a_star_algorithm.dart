import 'package:meta/meta.dart';

typedef ValueChanged<T> = void Function(T value);

/// Class responsible for calculating the best route using the A* algorithm.
class AStar {
  AStar({
    required this.rows,
    required this.columns,
    required this.start,
    required this.end,
    required this.barriers,
    this.withDiagonal = true,
  }) : grid = _createGrid(rows, columns, barriers);

  final int rows;
  final int columns;
  final (int, int) start;
  final (int, int) end;
  final List<(int, int)> barriers;
  final bool withDiagonal;

  late final List<List<Tile>> grid;

  final _doneList = <Tile>[];
  final _waitList = <Tile>[];

  /// Finds the shortest path between the [start] and [end] points.
  Iterable<(int, int)> findThePath({
    ValueChanged<List<(int, int)>>? doneList,
  }) {
    _doneList.clear();
    _waitList.clear();

    if (barriers.contains(end)) {
      return [];
    }

    _addNeighbors(grid);

    final startTile = grid[start.y][start.x];
    final endTile = grid[end.y][end.x];
    final winner = _getTileWinner(startTile, endTile);
    final path = [end];

    if (winner != null) {
      var parent = winner.parent;
      for (var i = 0; i < winner.costFromStart - 1; i++) {
        path.add(parent!.position);
        parent = parent.parent;
      }
    }
    path.add(start);
    doneList?.call(_doneList.map((e) => e.position).toList());

    if (winner == null && !start.isNeighbour(end, withDiagonal: withDiagonal)) {
      path.clear();
    }
    return path.reversed;
  }

  /// Method that create the grid
  static List<List<Tile>> _createGrid(
    int rows,
    int columns,
    List<(int, int)> barriers,
  ) {
    final grid = <List<Tile>>[];
    for (var y = 0; y < rows; y++) {
      final rowList = <Tile>[];
      for (var x = 0; x < columns; x++) {
        final offset = (x, y);
        rowList.add(
          Tile(
            offset,
            [],
            isBarrier: barriers.contains(offset),
          ),
        );
      }
      grid.add(rowList);
    }
    return grid;
  }

  /// Adds neighbors to tiles.
  void _addNeighbors(List<List<Tile>> grid) {
    for (var y = 0; y < grid.length; y++) {
      for (var x = 0; x < grid[0].length; x++) {
        final element = grid[y][x];

        for (final direction in _directions) {
          final newX = x + direction.x;
          final newY = y + direction.y;
          if (newX >= 0 &&
              newX < grid.first.length &&
              newY >= 0 &&
              newY < grid.length) {
            final t = grid[newY][newX];
            if (!t.isBarrier) {
              element.neighbors.add(t);
            }
          }
        }

        if (withDiagonal) {
          for (final direction in _diagonalDirections) {
            final newX = x + direction.x;
            final newY = y + direction.y;
            if (newX >= 0 &&
                newX < grid.first.length &&
                newY >= 0 &&
                newY < grid.length) {
              final t = grid[newY][newX];
              final adjacent1 = grid[newY][x];
              final adjacent2 = grid[y][newX];
              if (!t.isBarrier &&
                  !adjacent1.isBarrier &&
                  !adjacent2.isBarrier) {
                element.neighbors.add(t);
              }
            }
          }
        }
      }
    }
  }

  Tile? _getTileWinner(Tile start, Tile end) {
    _waitList.add(start);

    while (_waitList.isNotEmpty) {
      _waitList.sort((a, b) => a.totalCost.compareTo(b.totalCost));
      final current = _waitList.removeAt(0);

      if (current == end) {
        return current;
      }

      _doneList.add(current);

      for (final neighbor in current.neighbors) {
        if (!_doneList.contains(neighbor)) {
          _analyzeDistance(neighbor, end, parent: current);
          if (!_waitList.contains(neighbor)) {
            _waitList.add(neighbor);
          }
        }
      }
    }

    return null;
  }

  /// Calculates the distance costFromStart and heuristicCostToEnd.
  void _analyzeDistance(Tile current, Tile end, {Tile? parent}) {
    if (current.parent == null) {
      current.parent = parent;
      current.costFromStart = (current.parent?.costFromStart ?? 0) + 1;

      current.heuristicCostToEnd = _distance(current, end);
    }
  }

  /// Calculates the distance between two tiles.
  int _distance(Tile tile1, Tile tile2) {
    return (tile1.position.x - tile2.position.x).abs() +
        (tile1.position.y - tile2.position.y).abs();
  }

  /// Resume path
  /// Example:
  /// [(1,2),(1,3),(1,4),(1,5)] = [(1,2),(1,5)]
  static List<(int, int)> simplifyPath(Iterable<(int, int)> path) {
    var newPath = path.toList();
    for (final type in TypeResumeDirection.values) {
      newPath = simplifyDirection(newPath, type);
    }
    return newPath;
  }

  @visibleForTesting
  static List<(int, int)> simplifyDirection(
    List<(int, int)> path,
    TypeResumeDirection type,
  ) {
    if (path.isEmpty) {
      return [];
    }

    final newPath = <(int, int)>[];
    final segments = <List<(int, int)>>[];
    var currentX = path.first.x;
    var currentY = path.first.y;

    for (final element in path) {
      final shouldAdd = switch (type) {
        TypeResumeDirection.axisX => element.x == currentX,
        TypeResumeDirection.axisY => element.y == currentY,
        _ => (element.x - currentX).abs() == 1 &&
            (element.y - currentY).abs() == 1,
      };

      if (shouldAdd && segments.isNotEmpty) {
        segments.last.add(element);
      } else {
        segments.add([element]);
      }

      currentX = element.x;
      currentY = element.y;
    }

    for (final segment in segments) {
      newPath.add(segment.first);
      if (segment.length > 1) {
        newPath.add(segment.last);
      }
    }

    return newPath;
  }
}

/// Represents a tile/cell in the grid.
class Tile {
  Tile(
    this.position,
    this.neighbors, {
    this.parent,
    this.isBarrier = false,
  });

  final (int, int) position;
  Tile? parent;
  final List<Tile> neighbors;
  final bool isBarrier;
  int costFromStart = 0;
  int heuristicCostToEnd = 0;

  int get totalCost => costFromStart + heuristicCostToEnd;
}

@visibleForTesting
enum TypeResumeDirection {
  axisX,
  axisY,
  topLeft,
  bottomLeft,
  topRight,
  bottomRight,
}

extension on (int, int) {
  int get x => $1;
  int get y => $2;

  bool isNeighbour((int, int) other, {bool withDiagonal = true}) {
    if (this == other) {
      return false;
    }

    if (withDiagonal) {
      return (x - other.x).abs() <= 1 && (y - other.y).abs() <= 1;
    }

    return (x - other.x).abs() <= 1 && y == other.y ||
        x == other.x && (y - other.y).abs() <= 1;
  }
}

const _directions = [
  (0, -1), // top
  (0, 1), // bottom
  (-1, 0), // left
  (1, 0), // right
];

const _diagonalDirections = [
  (-1, -1), // top-left
  (1, -1), // top-right
  (-1, 1), // bottom-left
  (1, 1), // bottom-right
];
