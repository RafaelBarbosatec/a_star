import 'dart:math';

import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:a_star_algorithm/src/models/tile.dart';

extension GreateGridWithFreeExt on AStar {
  /// Method that create the grid using barriers
  List<List<Tile>> createGridWithFree(
    List<Point<int>> freeSpaces,
  ) {
    List<List<Tile>> newGrid = [];
    List.generate(columns, (x) {
      List<Tile> rowList = [];
      List.generate(rows, (y) {
        final point = Point<int>(x, y);
        final isTarget = targets.any((t) => t == point);
        final costIndex = landCosts.indexWhere((c) => c == point);
        // any more faster then where
        bool isFreeSpace = freeSpaces.any((element) {
          return element == point;
        });
        final type = isTarget
            ? TileType.target
            : isFreeSpace
                ? TileType.free
                : TileType.barrier;

        rowList.add(
          Tile(
            point,
            [],
            [],
            // if have landCost use it else default 1
            cost: costIndex != -1 ? landCosts[costIndex].cost : 1,
            type: type,
          ),
        );
      });
      newGrid.add(rowList);
    });
    return newGrid;
  }
}
