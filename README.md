[![pub package](https://img.shields.io/pub/v/a_star_algorithm.svg)](https://pub.dev/packages/a_star_algorithm)

# a_star_algorithm

![](https://github.com/RafaelBarbosatec/a_star/blob/main/img/example.jpg)

A* algorithm

# Usage
To use this plugin, add `a_star` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### Example

``` dart
import 'package:flutter/material.dart';
 Iterable<Point> result = AStar(
      rows: 20,
      columns: 20,
      start: Point(5,0),
      end: Point(8,19),
      barriers: [
        Point(10,5),
        Point(10,6),
        Point(10,7),
        Point(10,8),
      ],
    ).findThePath();
```

[Demo Online](https://rafaelbarbosatec.github.io/a_star/)
