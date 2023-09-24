// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

// import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:a_star_algorithm/a_star_algorithm.dart';

import 'models/tile.dart';

/// Class responsible for calculating the best route using the A* algorithm.
class AStar {
  final int rows;
  final int columns;
  // ligher than Offset
  // Point<int> not need to translate toDouble and back
  final Point<int> start;
  final Point<int> end;
  final List<Point<int>> barriers;
  final List<WeightPoint> weighed;

  final bool withDiagonal;
  final List<Tile> _doneList = [];
  final List<Tile> _waitList = [];

  late List<List<Tile>> grid;

  AStar({
    required this.rows,
    required this.columns,
    required this.start,
    required this.end,
    required this.barriers,
    this.weighed = const [],
    this.withDiagonal = false,
  }) {
    grid = createGridWithBarriers();
  }

  AStar.byFreeSpaces({
    required this.rows,
    required this.columns,
    required this.start,
    required this.end,
    required List<Point<int>> freeSpaces,
    this.weighed = const [],
    this.withDiagonal = true,
  }) : barriers = [] {
    grid = createGridWithFree(freeSpaces);
  }

  /// Method that starts the search
  Iterable<Point<int>> findThePath({ValueChanged<List<Point<int>>>? doneList}) {
    _doneList.clear();
    _waitList.clear();

    if (barriers.contains(end)) {
      return [];
    }

    Tile startTile = grid[start.x][start.y];

    Tile endTile = grid[end.x][end.y];
    addNeighbors(grid);
    startTile.g = startTile.weight;

    // ---- old ----
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

  /// Method recursive that execute the A* algorithm
  Tile? _getTileWinner(Tile current, Tile end) {
    if (end == current) return current;
    _waitList.remove(current);
    for (final element in current.neighbors) {
      if (element.parent == null) {
        _analiseDistance(element, end, parent: current);
      }
    }
    _doneList.add(current);

    for (var n in current.neighbors) {
      if (!_doneList.contains(n)) {
        _waitList.add(n);
      }
    }
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
    current.h = _distance(current.position, parent.position, end.position);
  }

  /// Calculates the distance between two tiles.
  int _distance(Point<int> current, Point<int> parent, Point<int> target) {
    int distX = (current.x - target.x).abs();
    int distY = (current.y - target.y).abs();
    if (withDiagonal) {
      return distX + distY;
    }
    return distX * distY;
  }

  /// Resume path
  /// Example:
  /// [(1,2),(1,3),(1,4),(1,5)] = [(1,2),(1,5)]
  static List<Point<int>> _resumePath(Iterable<Point<int>> path) {
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
}

enum TypeResumeDirection {
  axisX,
  axisY,
  topLeft,
  bottomLeft,
  topRight,
  bottomRight,
}
