import 'dart:math';

 class CostPoint extends Point<int> {
  CostPoint(super.x, super.y,{required this.cost});
  final int cost;

}