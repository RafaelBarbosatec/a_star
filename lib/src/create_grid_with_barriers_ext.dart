import 'dart:math';

import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:a_star_algorithm/src/models/tile.dart';

extension GreateGridWithBarrierExt on AStar {
 /// Method that create the grid using barriers
  List<List<Tile>> createGridWithBarriers() {
    List<List<Tile>> newGrid = [];
    List.generate(columns, (x) {
      List<Tile> rowList = [];
      List.generate(rows, (y) {
        final point = Point<int>(x, y);
        final isBarrier = barriers.any((b) => b == point);
        final costIndex = weighed.indexWhere((c) => c == point);
        final type = isBarrier
                ? TileType.barrier
                : TileType.free;
        rowList.add(
          Tile(
            point,
            [],
            // if have landCost use it else default 1
            weight: costIndex != -1 ? weighed[costIndex].weight : 1,
            type: type,
          ),
        );
      });
      newGrid.add(rowList);
    });
    return newGrid;
  }
}

