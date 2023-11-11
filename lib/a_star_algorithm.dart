library a_star_algorithm;

import 'dart:math';

import 'package:flutter/cupertino.dart';

/// Class responsible for calculating the best route using the A* algorithm.

class AStar {
  final int _rows;
  final int _columns;
  final Point<int> start;
  final Point<int> end;
  final List<Point<int>> _barriers;
  final List<WeightedPoint> weighted;

  final bool withDiagonal;
  final List<Tile> _doneList = [];
  final List<Tile> _waitList = [];

  late List<List<Tile>> _grid;

  AStar({
    required int rows,
    required int columns,
    required this.start,
    required this.end,
    required List<Point<int>> barriers,
    this.weighted = const <WeightedPoint>[],
    this.withDiagonal = false,
  })  : _rows = rows,
        _columns = columns,
        _barriers = barriers {
    _grid = _createGridWithBarriers(
        rows: _rows, columns: _columns, barriers: _barriers);
  }

  AStar.byFreeSpaces({
    required int rows,
    required int columns,
    required this.start,
    required this.end,
    required List<Point<int>> freeSpaces,
    this.weighted = const [],
    this.withDiagonal = true,
  })  : _barriers = [],
        _rows = rows,
        _columns = columns {
    _grid = _createGridWithFree(freeSpaces, rows: _rows, columns: _columns);
  }

  /// Method that starts the search
  Iterable<Point<int>> findThePath({ValueChanged<List<Point<int>>>? doneList}) {
    _doneList.clear();
    _waitList.clear();

    if (_barriers.contains(end)) {
      return [];
    }

    Tile startTile = _grid[start.x][start.y];

    Tile endTile = _grid[end.x][end.y];
    _addNeighbors(_grid);
    Tile? winner = _getTileWinner(
      startTile,
      endTile,
    );

    List<Point<int>> path = [end];
    if (winner?.parent != null) {
      Tile tileAux = winner!.parent!;
      for (int i = 0; i < winner.g - 1; i++) {
        if (tileAux.position == start) {
          break;
        }
        path.add(tileAux.position);
        tileAux = tileAux.parent!;
      }
    }
    doneList?.call(_doneList.map((e) => e.position).toList());

    if (winner == null && !_isNeighbors(start, end)) {
      path.clear();
    }
    path.add(start);

    return path.reversed;
  }

  /// Method that create the grid using barriers
  List<List<Tile>> _createGridWithBarriers({
    required int rows,
    required int columns,
    required List<Point> barriers,
  }) {
    List<List<Tile>> grid = [];
    List.generate(columns, (x) {
      List<Tile> rowList = [];
      List.generate(rows, (y) {
        final point = Point<int>(x, y);
        final isBarrier = barriers.any((b) => b == point);
        final weightedIndex = weighted.indexWhere((c) => c == point);
        final type = isBarrier ? TileType.barrier : TileType.free;
        rowList.add(
          Tile(
            point,
            [],
            weight: weightedIndex != -1 ? weighted[weightedIndex].weight : 1,
            type: type,
          ),
        );
      });
      grid.add(rowList);
    });
    return grid;
  }

  /// Method recursive that execute the A* algorithm
  Tile? _getTileWinner(Tile current, Tile end) {
    _waitList.remove(current);
    if (end == current) return current;
    for (final n in current.neighbors) {
      if (n.parent == null) {
        _analiseDistance(n, end, parent: current);
      }
      if (!_doneList.contains(n)) {
        _waitList.add(n);
      }
    }
    _doneList.add(current);
    _waitList.sort((a, b) => a.f.compareTo(b.f));

    for (final element in _waitList) {
      if (!_doneList.contains(element)) {
        final result = _getTileWinner(element, end);
        if (result != null) {
          return result;
        }
      }
    }

    return null;
  }

  /// Calculates the distance g and h
  void _analiseDistance(Tile current, Tile end, {required Tile parent}) {
    current.parent = parent;
    current.g = parent.g + current.weight;
    current.h = _distance(current.position, end.position);
  }

  /// Calculates the distance between two tiles.
  double _distance(Point<int> current, Point<int> target) {
    int toX = current.x - target.x;
    int toY = current.y - target.y;
    return Point(toX, toY).magnitude * 2;
  }

  /// Resume path
  /// Example:
  /// [(1,2),(1,3),(1,4),(1,5)] = [(1,2),(1,5)]
  static List<Point<int>> resumePath(Iterable<Point<int>> path) {
    List<Point<int>> newPath =
        _resumeDirection(path, TypeResumeDirection.axisX);
    newPath = _resumeDirection(newPath, TypeResumeDirection.axisY);
    newPath = _resumeDirection(newPath, TypeResumeDirection.bottomLeft);
    newPath = _resumeDirection(newPath, TypeResumeDirection.bottomRight);
    newPath = _resumeDirection(newPath, TypeResumeDirection.topLeft);
    newPath = _resumeDirection(newPath, TypeResumeDirection.topRight);
    return newPath;
  }

  static List<Point<int>> _resumeDirection(
    Iterable<Point<int>> path,
    TypeResumeDirection type,
  ) {
    List<Point<int>> newPath = [];
    List<List<Point<int>>> listPoint = [];
    int indexList = -1;
    int currentX = 0;
    int currentY = 0;

    for (var element in path) {
      final dxDiagonal = element.x;
      final dyDiagonal = element.y;

      switch (type) {
        case TypeResumeDirection.axisX:
          if (element.x == currentX && listPoint.isNotEmpty) {
            listPoint[indexList].add(element);
          } else {
            listPoint.add([element]);
            indexList++;
          }
          break;
        case TypeResumeDirection.axisY:
          if (element.y == currentY && listPoint.isNotEmpty) {
            listPoint[indexList].add(element);
          } else {
            listPoint.add([element]);
            indexList++;
          }
          break;
        case TypeResumeDirection.topLeft:
          final nextDxDiagonal = (currentX - 1);
          final nextDyDiagonal = (currentY - 1);
          if (dxDiagonal == nextDxDiagonal &&
              dyDiagonal == nextDyDiagonal &&
              listPoint.isNotEmpty) {
            listPoint[indexList].add(element);
          } else {
            listPoint.add([element]);
            indexList++;
          }
          break;
        case TypeResumeDirection.bottomLeft:
          final nextDxDiagonal = (currentX - 1);
          final nextDyDiagonal = (currentY + 1);
          if (dxDiagonal == nextDxDiagonal &&
              dyDiagonal == nextDyDiagonal &&
              listPoint.isNotEmpty) {
            listPoint[indexList].add(element);
          } else {
            listPoint.add([element]);
            indexList++;
          }
          break;
        case TypeResumeDirection.topRight:
          final nextDxDiagonal = (currentX + 1).floor();
          final nextDyDiagonal = (currentY - 1).floor();
          if (dxDiagonal == nextDxDiagonal &&
              dyDiagonal == nextDyDiagonal &&
              listPoint.isNotEmpty) {
            listPoint[indexList].add(element);
          } else {
            listPoint.add([element]);
            indexList++;
          }
          break;
        case TypeResumeDirection.bottomRight:
          final nextDxDiagonal = (currentX + 1);
          final nextDyDiagonal = (currentY + 1);
          if (dxDiagonal == nextDxDiagonal &&
              dyDiagonal == nextDyDiagonal &&
              listPoint.isNotEmpty) {
            listPoint[indexList].add(element);
          } else {
            listPoint.add([element]);
            indexList++;
          }
          break;
      }

      currentX = element.x;
      currentY = element.y;
    }

    // for in faster than forEach
    for (var element in listPoint) {
      if (element.length > 1) {
        newPath.add(element.first);
        newPath.add(element.last);
      } else {
        newPath.add(element.first);
      }
    }

    return newPath;
  }

  bool _isNeighbors(Point<int> start, Point<int> end) {
    bool isNeighbor = false;
    if (start.x + 1 == end.x) {
      isNeighbor = true;
    }

    if (start.x - 1 == end.x) {
      isNeighbor = true;
    }

    if (start.y + 1 == end.y) {
      isNeighbor = true;
    }

    if (start.y - 1 == end.y) {
      isNeighbor = true;
    }

    return isNeighbor;
  }

  /// Method that create the grid using barriers
  List<List<Tile>> _createGridWithFree(
    List<Point<int>> freeSpaces, {
    required int rows,
    required int columns,
  }) {
    List<List<Tile>> grid = [];
    List.generate(columns, (x) {
      List<Tile> rowList = [];
      List.generate(rows, (y) {
        final point = Point<int>(x, y);
        final costIndex = weighted.indexWhere((c) => c == point);
        // any more faster then where
        bool isFreeSpace = freeSpaces.any((element) {
          return element == point;
        });
        final type = isFreeSpace ? TileType.free : TileType.barrier;

        rowList.add(
          Tile(
            point,
            [],
            weight: costIndex != -1 ? weighted[costIndex].weight : 1,
            type: type,
          ),
        );
      });
      grid.add(rowList);
    });
    return grid;
  }

  /// Adds neighbors to cells
  void _addNeighbors(List<List<Tile>> grid) {
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

extension FindStepsExt on AStar {
  List<Point<int>> findSteps({required int steps}) {
    _addNeighbors(_grid);

    Tile startTile = _grid[start.x][start.y];
    final List<Tile> totalArea = [startTile];
    final List<Tile> waitArea = [];

    final List<Tile> currentArea = [...startTile.neighbors];
    if (currentArea.isEmpty) {
      return totalArea.map((tile) => tile.position).toList();
    }
    for (var element in startTile.neighbors) {
      element.parent = startTile;
      element.g = element.weight + startTile.weight;
    }
    for (var i = 1; i < steps + 2; i++) {
      if (currentArea.isEmpty) continue;
      for (var currentTile in currentArea) {
        if (currentTile.g <= i) {
          totalArea.add(currentTile);
          for (var n in currentTile.neighbors) {
            if (totalArea.contains(n)) continue;
            if (n.parent == null) {
              n.parent = currentTile;
              n.g = n.weight + currentTile.g;
            }
            waitArea.add(n);
          }
        } else {
          waitArea.add(currentTile);
        }
      }
      currentArea.clear();
      currentArea.addAll(waitArea);
      waitArea.clear();
    }
    return totalArea.map((tile) => tile.position).toList();
  }
}
/// Class used to represent each cell
enum TileType { free, barrier, target }

class Tile {
  final Point<int> position;
  Tile? parent;
  final List<Tile> neighbors;
  final TileType type;
  final int weight;

  /// distanse from current to start
  int g = 0;

  /// distanse from current to end
  double h = 0;

  /// total distance
  double get f => g + h;
  bool get isBarrier => type == TileType.barrier;
  bool get isFree => type == TileType.free;

  Tile(this.position, this.neighbors,
      {this.parent, this.type = TileType.free, this.weight = 1});

  @override
  bool operator ==(covariant Tile other) {
    if (identical(this, other)) return true;
    return other.position == position;
  }

  @override
  int get hashCode {
    return position.hashCode ^ type.hashCode;
  }
}

class WeightedPoint extends Point<int> {
  const WeightedPoint(super.x, super.y, {required this.weight});
  final int weight;
}



enum TypeResumeDirection {
  axisX,
  axisY,
  topLeft,
  bottomLeft,
  topRight,
  bottomRight,
}
