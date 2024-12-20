[![pub package](https://img.shields.io/pub/v/a_star_algorithm.svg)](https://pub.dev/packages/a_star_algorithm)
[![Code Quality](https://github.com/RafaelBarbosatec/a_star/actions/workflows/unit.yml/badge.svg)](https://github.com/RafaelBarbosatec/a_star/actions/workflows/unit.yml)

# a_star_algorithm

![](https://github.com/RafaelBarbosatec/a_star/blob/main/img/example.jpg)

A* algorithm

# Usage
To use this package, add `a_star_algorithm` as a [dependency in your pubspec.yaml file](https://docs.flutter.dev/packages-and-plugins/using-packages).

### Example

``` dart

void main() {
  Iterable<(int, int)> result = AStar(
    rows: 20,
    columns: 20,
    start: (5,0),
    end: (8,19),
    barriers: [
      (10,5),
      (10,6),
      (10,7),
      (10,8),
    ],
  ).findThePath();
}
```

[Demo Online](https://rafaelbarbosatec.github.io/a_star/)
