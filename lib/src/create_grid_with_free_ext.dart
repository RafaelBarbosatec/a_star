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
      newGrid.add(rowList);
    });
    return newGrid;
  }
}
