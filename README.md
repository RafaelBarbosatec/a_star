[![pub package](https://img.shields.io/pub/v/a_star_algorithm.svg)](https://pub.dev/packages/a_star_algorithm)

# a_star_algorithm

![](https://github.com/RafaelBarbosatec/a_star/blob/main/img/example.jpg)

A* algorithm

# Usage
To use this plugin, add `a_star` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### Example

``` dart
import 'dart:math';
import 'package:flutter/material.dart';
 Iterable<Point<int>> result = AStar(
      rows: 20,
      columns: 20,
      start: Point<int>(5,0),
      end: Point<int>(8,19),
      barriers: [
        Point<int>(10,5),
        Point<int>(10,6),
        Point<int>(10,7),
        Point<int>(10,8),
      ],
    ).findThePath();
```

[Demo Online](https://rafaelbarbosatec.github.io/a_star/)
