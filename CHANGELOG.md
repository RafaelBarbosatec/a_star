## [0.4.0]
* BREAK: Now uses `(int, int)` instead of Point. Thanks [spydon](https://github.com/spydon)!
* Flutter is no longer a dependency

## [0.3.2]
* Some improvements. [#8](https://github.com/RafaelBarbosatec/a_star/pull/8) Thanks [Horned-Nonsense](https://github.com/Horned-Nonsense)

## [0.3.1]
* Performance improvements.
* BREAK: Now uses `Point<int>` instead of Offset

## [0.3.0]
* Adds `AStar.byFreeSpaces`.

## [0.2.1]
* Add util method `AStar.resumePath`. This resume path like: [(1,2),(1,3),(1,4),(1,5)] = [(1,2),(1,5)]

## [0.2.0]
* Fixes result list order
* Adds start and end Offset in the result.

## [0.1.1]
* fix conditional to consider diagonal

## [0.1.0]
* Adds param `withDiagonal` to enable and disable diagonal.

## [0.0.5]

* Improvements example.
* Fix crash when not found a path.

## [0.0.4]

* return path empty if the and is a barrier.
* fix bug Offset inverted.

## [0.0.3]

* Improvement in the algorithm implementation

## [0.0.2]

* Fix return the shortest path

## [0.0.1]

* First version
