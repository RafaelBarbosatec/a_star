import 'dart:math';

import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(StepsAreaApp());
}

class StepsAreaApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Steps Area Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

enum TypeInput {
  START_POINT,
  END_POINT,
  BARRIERS,
  TARGETS,
  WATER,
  STEPS,
  FOUNDED_TARGET,
  TARGETS_STEPS,
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TypeInput _typeInput = TypeInput.START_POINT;
  int steps = 5;
  bool _showDoneList = true;
  Point<int> start = Point<int>(0, 0);
  Point<int> end = Point<int>(0, 0);
  List<Tile> tiles = [];
  List<Point<int>> barriers = [];
  List<CostPoint> lands = [];
  List<Point<int>> targets = [];

  /// turn based area
  List<Point<int>> stepsArea = [];
  List<Point<int>> foundedEnemies = [];
  int rows = 20;
  int columns = 20;

  @override
  void initState() {
    super.initState();
    List.generate(rows, (y) {
      List.generate(columns, (x) {
        final point = Point(x, y);
        tiles.add(
          Tile(point),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('A* tbs'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _typeInput = TypeInput.START_POINT;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: _getColorSelected(TypeInput.START_POINT),
                  ),
                  child: Text('START'),
                ),
                Column(
                  children: [
                    Text('steps $steps'.toUpperCase()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              steps += 1;
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: _getColorSelected(TypeInput.WATER),
                          ),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            if (steps > 0)
                              setState(() {
                                steps -= 1;
                              });
                          },
                          style: ButtonStyle(
                            backgroundColor: _getColorSelected(TypeInput.WATER),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _typeInput = TypeInput.WATER;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: _getColorSelected(TypeInput.WATER),
                  ),
                  child: Text('WATER'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _typeInput = TypeInput.BARRIERS;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: _getColorSelected(TypeInput.BARRIERS),
                  ),
                  child: Text('BARRIES'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _typeInput = TypeInput.TARGETS;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: _getColorSelected(TypeInput.TARGETS),
                  ),
                  child: Text('TARGETS'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      barriers.clear();
                      _cleanTiles();
                    });
                  },
                  child: Text('CLEAN'),
                )
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: columns,
              children: tiles.map((e) {
                return _buildItem(e);
              }).toList(),
            ),
          ),
          Row(
            children: [
              Switch(
                value: _showDoneList,
                onChanged: (value) {
                  setState(() {
                    _showDoneList = value;
                  });
                },
              ),
              Text('Show done list')
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _start,
        tooltip: 'Find path',
        child: Icon(Icons.map),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildItem(Tile e) {
    Color color = Colors.white;
    String text = '1';
    IconData? icon;
    if (lands.contains(e.position)) {
      color = Colors.cyan.withOpacity(0.5);
      text = lands
          .firstWhere((i) => i.x == e.position.x && i.y == e.position.y)
          .cost
          .toString();
    }
    if (barriers.contains(e.position)) {
      color = Colors.red;
      icon = Icons.do_not_step_outlined;
    }
    if (e.done) {
      color = Colors.black;
    }
    if (e.selected && _showDoneList) {
      color = Colors.green;
    }

    if (targets.contains(e.position)) {
      color = Colors.purple;
      icon = Icons.man;
    }

    if (e.position == start) {
      color = Colors.black;
      icon = Icons.person;
    }
    if (e.position == end) {
      color = Colors.green;
      icon = Icons.flag;
    }
    if(stepsArea.contains(e.position)){
      color = Colors.green;
    }
    if(targets.contains(e.position)){
      color = Colors.purple;
    }

    return Ink(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54, width: 1.0),
        color: color.withOpacity(.3),
      ),
      height: 10,
      child: InkWell(
        child: Stack(
          children: [
            if(icon !=null) Center(child: Icon(icon,color: color)),
            Text(
              text,
              style: TextStyle(fontSize: 9, color: Colors.black),
            ),
          ],
        ),
        onLongPress: () {},
        onDoubleTap: () {},
        onTap: () {
          if (_typeInput == TypeInput.START_POINT) {
            start = e.position;
          }

          if (_typeInput == TypeInput.END_POINT) {
            end = e.position;
          }

          if (_typeInput == TypeInput.BARRIERS) {
            if (barriers.contains(e.position)) {
              barriers.remove(e.position);
            } else {
              barriers.add(e.position);
            }
          }
          if (_typeInput == TypeInput.TARGETS) {
            if (targets.contains(e.position)) {
              targets.remove(e.position);
            } else {
              targets.add(e.position);
            }
          }
          if (_typeInput == TypeInput.WATER) {
            if (lands.contains(e.position)) {
              lands.remove(e.position);
            } else {
              lands.add(CostPoint(e.position.x, e.position.y, cost: 7));
            }
          }
          setState(() {});
        },
      ),
    );
  }

  MaterialStateProperty<Color> _getColorSelected(TypeInput input) {
    return MaterialStateProperty.all(
      _typeInput == input ? _getColorByType(input) : Colors.grey,
    );
  }

  Color _getColorByType(TypeInput input) {
    switch (input) {
      case TypeInput.START_POINT:
        return Colors.yellow;
      case TypeInput.END_POINT:
        return Colors.green;
      case TypeInput.BARRIERS:
        return Colors.red;
      case TypeInput.TARGETS:
        return Colors.purple;
      case TypeInput.WATER:
        return Colors.blue;
      case TypeInput.STEPS:
        return Colors.blueGrey[700]!;
      case TypeInput.TARGETS_STEPS:
      case TypeInput.FOUNDED_TARGET:
        return Colors.deepPurple[700]!;
    }
  }

  void _start() {
    _cleanTiles();
    final result = AStar(
      rows: rows,
      columns: columns,
      start: start,
      end: end,
      landCosts: lands,
      barriers: barriers,
      targets: targets,
    ).findSteps(steps: steps);
    print('Steps areas ${result}');

    setState(() {
      stepsArea = List.of(result);
    });
  }

  void _cleanTiles() {
    for (var element in tiles) {
      element.selected = false;
      element.done = false;
    }
  }
}

class Tile {
  final Point<int> position;
  bool selected = false;
  bool done = false;

  Tile(this.position);
}
