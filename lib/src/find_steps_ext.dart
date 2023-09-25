import 'dart:math';

import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:a_star_algorithm/src/helpers/list_tile_ext.dart';
import 'models/tile.dart';

extension FindStepsExt on AStar {
  List<Point<int>> findSteps({required int steps}) {
    addNeighbors(grid);

    Tile startTile = grid[start.x][start.y];
    final List<Tile> totalArea = [startTile];
    final List<Tile> waitArea = [];

    final List<Tile> currentArea = [...startTile.neighbors];
    if (currentArea.isEmpty) return totalArea.toPoints();
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
    return totalArea.toPoints();
  }
}
