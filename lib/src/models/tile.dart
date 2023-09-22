import 'dart:math';

/// Class used to represent each cell
enum TileType { free, ally, barrier, target }

class Tile {
  final Point<int> position;
  Tile? parent;
  final List<Tile> neighbors;
  final List<Tile> connectors;
  final TileType type;
  final int weight;
  /// distanse from current to start
  int g = 0;
  /// distanse from current to end
  int h = 0;
  /// total cost 
  int get f => g + h;
  bool get isBarrier => type == TileType.barrier;
  bool get isFree => type == TileType.free;
  bool get isTarget => type == TileType.target;

  Tile(this.position, this.neighbors, this.connectors,
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

