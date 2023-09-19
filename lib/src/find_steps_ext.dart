import 'dart:math';

import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:a_star_algorithm/src/helpers/list_tile_ext.dart';
import 'package:flutter/foundation.dart';

import 'models/tile.dart';

extension FindStepsExt on AStar {
  /// s1 path area
  ///
  /// s2 founded enemies
  (List<Point<int>>, List<Point<int>>) findSteps(
      {ValueChanged<List<Point<int>>>? doneList, required int steps}) {
    addNeighbors(grid);

    Tile startTile = grid[start.x][start.y];
    final List<Tile> totalArea = [startTile];
    final List<Tile> enemies =
        startTile.connectors.where((c) => c.isTarget).toList();
    final List<Tile> nextArea = [...startTile.neighbors];
    final List<Tile> waitArea = [];
    if (nextArea.isEmpty) return ([], enemies.toPoints());
    for (var i = 0; i < steps; i++) {
      for (var nextTile in nextArea) {
        for (var n in nextTile.neighbors) {
          if (totalArea.contains(n)) continue;
          if (n.isTarget && !enemies.contains(n)) enemies.add(n);
          waitArea.add(n);
        }
      }
      totalArea.addAll(nextArea);
      if (waitArea.isEmpty) break;
      nextArea.clear();
      nextArea.addAll(waitArea);
      waitArea.clear();
    }
    return (totalArea.toPoints(), enemies.toPoints());
  }
}
