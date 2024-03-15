library a_star_algorithm;

import 'dart:math';

import 'package:flutter/cupertino.dart';

/// Class responsible for calculating the best route using the A* algorithm.
class AStar {
  final int rows;
  final int columns;
  final Point<int> start;
  final Point<int> end;
  final List<Point<int>> barriers;
  final bool withDiagonal;
  List<Tile> _doneList = [];
  List<Tile> _waitList = [];

  late List<List<Tile>> grid;

  AStar({
    required this.rows,
    required this.columns,
    required this.start,
    required this.end,
    required this.barriers,
    this.withDiagonal = true,
  }) {
    grid = _createGrid(rows, columns, barriers);
  }

  /// Method that starts the search
  Iterable<Point<int>> findThePath({ValueChanged<List<Point<int>>>? doneList}) {
    _doneList.clear();
    _waitList.clear();

    if (barriers.contains(end)) {
      return [];
    }

    _addNeighbors(grid);

    Tile startTile = grid[start.x.toInt()][start.y.toInt()];
    Tile endTile = grid[end.x.toInt()][end.y.toInt()];

    Tile? winner = _getTileWinner(
      startTile,
      endTile,
    );

    List<Point<int>> path = [end];

    if (winner != null) {
      Tile? tileAux = winner.parent;
      for (int i = 0; i < winner.g - 1; i++) {
        path.add(tileAux!.position);
        tileAux = tileAux.parent;
      }
    }
    path.add(start);
    doneList?.call(_doneList.map((e) => e.position).toList());

    if (winner == null && !_isNeighbors(start, end)) {
      path.clear();
    }
    return path.reversed;
  }

  /// Method that create the grid
  List<List<Tile>> _createGrid(
      int rows, int columns, List<Point<int>> barriers) {
    List<List<Tile>> grid = [];
    List.generate(columns, (x) {
      List<Tile> rowList = [];
      List.generate(rows, (y) {
        final offset = Point(x, y);
        bool isBarrie = barriers.where((element) {
          return element == offset;
        }).isNotEmpty;
        rowList.add(
          Tile(
            offset,
            [],
            isBarrier: isBarrie,
          ),
        );
      });
      grid.add(rowList);
    });
    return grid;
  }

  /// Adds neighbors to cells
  void _addNeighbors(List<List<Tile>> grid) {
    grid.forEach((_) {
      _.forEach((element) {
        int x = element.position.x;
        int y = element.position.y;

        /// adds in top
        if (y > 0) {
          final t = grid[x][y - 1];
          if (!t.isBarrier) {
            element.neighbors.add(t);
          }
        }

        /// adds in bottom
        if (y < (grid.first.length - 1)) {
          final t = grid[x][y + 1];
          if (!t.isBarrier) {
            element.neighbors.add(t);
          }
        }

        /// adds in left
        if (x > 0) {
          final t = grid[x - 1][y];
          if (!t.isBarrier) {
            element.neighbors.add(t);
          }
        }

        /// adds in right
        if (x < (grid.length - 1)) {
          final t = grid[x + 1][y];
          if (!t.isBarrier) {
            element.neighbors.add(t);
          }
        }

        if (withDiagonal) {
          /// adds in top-left
          if (y > 0 && x > 0) {
            final top = grid[x][y - 1];
            final left = grid[x - 1][y];
            final t = grid[x - 1][y - 1];
            if (!t.isBarrier && !left.isBarrier && !top.isBarrier) {
              element.neighbors.add(t);
            }
          }

          /// adds in top-right
          if (y > 0 && x < (grid.length - 1)) {
            final top = grid[x][y - 1];
            final right = grid[x + 1][y];
            final t = grid[x + 1][y - 1];
            if (!t.isBarrier && !top.isBarrier && !right.isBarrier) {
              element.neighbors.add(t);
            }
          }

          /// adds in bottom-left
          if (x > 0 && y < (grid.first.length - 1)) {
            final bottom = grid[x][y + 1];
            final left = grid[x - 1][y];
            final t = grid[x - 1][y + 1];
            if (!t.isBarrier && !bottom.isBarrier && !left.isBarrier) {
              element.neighbors.add(t);
            }
          }

          /// adds in bottom-right
          if (x < (grid.length - 1) && y < (grid.first.length - 1)) {
            final bottom = grid[x][y + 1];
            final right = grid[x + 1][y];
            final t = grid[x + 1][y + 1];
            if (!t.isBarrier && !bottom.isBarrier && !right.isBarrier) {
              element.neighbors.add(t);
            }
          }
        }
      });
    });
  }

  /// Method recursive that execute the A* algorithm
  Tile? _getTileWinner(Tile current, Tile end) {
    if (current == end) return current;
    _waitList.remove(current);

    current.neighbors.forEach((element) {
      _analiseDistance(element, end, parent: current);
    });

    _doneList.add(current);

    _waitList.addAll(current.neighbors.where((element) {
      return !_doneList.contains(element);
    }));

    _waitList.sort((a, b) => a.f.compareTo(b.f));

    for (final element in _waitList.toList()) {
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
  void _analiseDistance(Tile current, Tile end, {Tile? parent}) {
    if (current.parent == null) {
      current.parent = parent;
      current.g = (current.parent?.g ?? 0) + 1;

      current.h = _distance(current, end);
    }
  }

  /// Calculates the distance between two tiles.
  int _distance(Tile tile1, Tile tile2) {
    int distX = (tile1.position.x - tile2.position.x).abs();
    int distY = (tile1.position.y - tile2.position.y).abs();
    return distX + distY;
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
    List<List<Point<int>>> listOffset = [];
    int indexList = -1;
    int currentX = 0;
    int currentY = 0;

    path.forEach((element) {
      final dxDiagonal = element.x;
      final dyDiagonal = element.y;

      switch (type) {
        case TypeResumeDirection.axisX:
          if (element.x == currentX && listOffset.isNotEmpty) {
            listOffset[indexList].add(element);
          } else {
            listOffset.add([element]);
            indexList++;
          }
          break;
        case TypeResumeDirection.axisY:
          if (element.y == currentY && listOffset.isNotEmpty) {
            listOffset[indexList].add(element);
          } else {
            listOffset.add([element]);
            indexList++;
          }
          break;
        case TypeResumeDirection.topLeft:
          final nextDxDiagonal = (currentX - 1).floor();
          final nextDyDiagonal = (currentY - 1).floor();
          if (dxDiagonal == nextDxDiagonal &&
              dyDiagonal == nextDyDiagonal &&
              listOffset.isNotEmpty) {
            listOffset[indexList].add(element);
          } else {
            listOffset.add([element]);
            indexList++;
          }
          break;
        case TypeResumeDirection.bottomLeft:
          final nextDxDiagonal = (currentX - 1).floor();
          final nextDyDiagonal = (currentY + 1).floor();
          if (dxDiagonal == nextDxDiagonal &&
              dyDiagonal == nextDyDiagonal &&
              listOffset.isNotEmpty) {
            listOffset[indexList].add(element);
          } else {
            listOffset.add([element]);
            indexList++;
          }
          break;
        case TypeResumeDirection.topRight:
          final nextDxDiagonal = (currentX + 1).floor();
          final nextDyDiagonal = (currentY - 1).floor();
          if (dxDiagonal == nextDxDiagonal &&
              dyDiagonal == nextDyDiagonal &&
              listOffset.isNotEmpty) {
            listOffset[indexList].add(element);
          } else {
            listOffset.add([element]);
            indexList++;
          }
          break;
        case TypeResumeDirection.bottomRight:
          final nextDxDiagonal = (currentX + 1).floor();
          final nextDyDiagonal = (currentY + 1).floor();
          if (dxDiagonal == nextDxDiagonal &&
              dyDiagonal == nextDyDiagonal &&
              listOffset.isNotEmpty) {
            listOffset[indexList].add(element);
          } else {
            listOffset.add([element]);
            indexList++;
          }
          break;
      }

      currentX = element.x;
      currentY = element.y;
    });

    listOffset.forEach((element) {
      if (element.length > 1) {
        newPath.add(element.first);
        newPath.add(element.last);
      } else {
        newPath.add(element.first);
      }
    });

    return newPath;
  }

  bool _isNeighbors(Point<int> start, Point<int> end) {
    bool isNeighbor = false;

    int startX = start.x;
    int startY = start.y;
    int endX = end.x;
    int endY = end.y;

    if (startX + 1 == endX && startY == endY || //right
            startX - 1 == endX && startY == endY || //left
            startX == endX && startY + 1 == endY || //bottom
            startX == endX && startY - 1 == endY //top
        ) {
      isNeighbor = true;
    }

    if (withDiagonal) {
      if (startX + 1 == endX && startY + 1 == endY || //bottom-right
              startX - 1 == endX && startY - 1 == endY || //top-left
              startX - 1 == endX && startY + 1 == endY || //bottom-left
              startX + 1 == endX && startY - 1 == endY //top-right
          ) {
        isNeighbor = true;
      }
    }

    return isNeighbor;
  }
}

/// Class used to represent each cell
class Tile {
  final Point<int> position;
  Tile? parent;
  final List<Tile> neighbors;
  final bool isBarrier;
  int g = 0;
  int h = 0;

  int get f => g + h;

  Tile(this.position, this.neighbors, {this.parent, this.isBarrier = false});
}

enum TypeResumeDirection {
  axisX,
  axisY,
  topLeft,
  bottomLeft,
  topRight,
  bottomRight,
}
