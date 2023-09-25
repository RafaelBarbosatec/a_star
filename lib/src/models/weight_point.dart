import 'dart:math';

class WeightedPoint extends Point<int> {
  const WeightedPoint(super.x, super.y, {required this.weight});
  final int weight;
}
