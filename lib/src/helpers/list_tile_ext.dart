import 'dart:math';

import 'package:a_star_algorithm/src/models/tile.dart';

extension ListTileConverter on List<Tile> {
  List<Point<int>> toPoints() =>
      this.map((tile) => Point<int>(tile.position.x, tile.position.y)).toList();
}
