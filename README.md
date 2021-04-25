# a_star

A* algorithm

# Usage
To use this plugin, add `a_star` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### Example

``` dart
import 'package:flutter/material.dart';
 List<Offset> result = AStar(
      rows: 20,
      columns: 20,
      start: Offset(5,0),
      end: Offset(8,19),
      barriers: [
        Offset(10,5),
        Offset(10,6),
        Offset(10,7),
        Offset(10,8),
      ],
    ).findThePath();
```