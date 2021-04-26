library a_star_algorithm;

import 'package:flutter/cupertino.dart';

class AStar {
  final int rows;
  final int columns;
  final Offset start;
  final Offset end;
  final List<Offset> barriers;
  List<Tile> _doneList = [];

  late List<List<Tile>> grid;

  AStar({
    required this.rows,
    required this.columns,
    required this.start,
    required this.end,
    required this.barriers,
  }) {
    grid = _createGrid(rows, columns, barriers);
  }

  List<Offset> findThePath({ValueChanged<List<Offset>>? doneList}) {
    _doneList.clear();

    _addNeighbors(grid);

    Tile startTile = grid[start.dx.toInt()][start.dy.toInt()];
    Tile endTile = grid[end.dx.toInt()][end.dy.toInt()];

    Tile first = _getFirstTileToStart(startTile, endTile);

    Tile? winner = _getTileWinner(
      first,
      endTile,
    );

    List<Offset> path = [];

    if (winner != null) {
      Tile? tileAux = winner.parent;
      for (int i = 0; i < winner.g - 1; i++) {
        path.add(tileAux!.position);
        tileAux = tileAux.parent;
      }
    }
    doneList?.call(_doneList.map((e) => e.position).toList());
    return path;
  }

  static List<List<Tile>> _createGrid(
    int rows,
    int columns,
    List<Offset> barriers,
  ) {
    List<List<Tile>> grid = [];
    List.generate(rows, (x) {
      List<Tile> columnList = [];
      List.generate(columns, (y) {
        final offset = Offset(x.toDouble(), y.toDouble());
        bool isBarrier = barriers.where((element) {
          return element == offset;
        }).isNotEmpty;
        columnList.add(
          Tile(
            offset,
            [],
            isBarrier: isBarrier,
          ),
        );
      });
      grid.add(columnList);
    });
    return grid;
  }

  static void _addNeighbors(List<List<Tile>> grid) {
    grid.forEach((_) {
      _.forEach((element) {
        int x = element.position.dx.toInt();
        int y = element.position.dy.toInt();
        if (y > 0) {
          final t = grid[x][y - 1];
          if (!t.isBarrier) {
            element.neighbors.add(t);
          }
        }
        if (y < (grid.first.length - 1)) {
          final t = grid[x][y + 1];
          if (!t.isBarrier) {
            element.neighbors.add(t);
          }
        }

        if (x > 0) {
          final t = grid[x - 1][y];
          if (!t.isBarrier) {
            element.neighbors.add(t);
          }
        }

        if (x < (grid.length - 1)) {
          final t = grid[x + 1][y];
          if (!t.isBarrier) {
            element.neighbors.add(t);
          }
        }
      });
    });
  }

  Tile? _getTileWinner(Tile current, Tile end) {
    if (current == end) return current;
    _analiseDistance(current, end);

    current.neighbors.forEach((element) {
      _analiseDistance(element, end, parent: current);
    });

    current.neighbors.sort((a, b) => a.f.compareTo(b.f));

    _doneList.add(current);

    final nextList = current.neighbors.where((element) {
      return !_doneList.contains(element);
    });

    for (final element in nextList) {
      final result = _getTileWinner(element, end);
      if (result != null) return result;
    }

    return null;
  }

  void _analiseDistance(Tile current, Tile end, {Tile? parent}) {
    if (current.parent == null) {
      current.parent = parent;
      current.g = (current.parent?.g ?? 0) + 1;

      current.h = _distance(current, end);
    }
  }

  Tile _getFirstTileToStart(Tile startTile, Tile endTile) {
    Tile first = startTile;

    final neighbors = startTile.neighbors.where((element) {
      return !element.isBarrier;
    });

    first = neighbors.fold(neighbors.first, (previousValue, element) {
      return _distance(element, endTile) < _distance(previousValue, endTile)
          ? element
          : previousValue;
    });

    return first;
  }

  int _distance(Tile tile1, Tile tile2) {
    int distX = (tile1.position.dx.toInt() - tile2.position.dx.toInt()).abs();
    int distY = (tile1.position.dy.toInt() - tile2.position.dy.toInt()).abs();
    return distX + distY;
  }
}

class Tile {
  final Offset position;
  Tile? _parent;
  final List<Tile> neighbors;
  final bool isBarrier;
  int g = 0;
  int h = 0;

  int get f => g + h;

  set parent(Tile? t) {
    if (_parent == null) {
      _parent = t;
    }
  }

  Tile? get parent => _parent;

  Tile(this.position, this.neighbors, {Tile? parent, this.isBarrier = false}) {
    _parent = parent;
  }
}
