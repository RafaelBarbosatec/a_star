import 'dart:math';

import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TypeInput _typeInput = TypeInput.START_POINT;

  bool _showDoneList = false;
  Point<int> start = Point(0, 0);
  Point<int> end = Point(0, 0);
  List<Tile> tiles = [];
  List<Point<int>> barriers = [];
  int rows = 20;
  int columns = 20;

  @override
  void initState() {
    List.generate(rows, (y) {
      List.generate(columns, (x) {
        final offset = Point(x, y);
        tiles.add(
          Tile(offset),
        );
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('A*'),
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
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _typeInput = TypeInput.END_POINT;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: _getColorSelected(TypeInput.END_POINT),
                  ),
                  child: Text('END'),
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
    if (e.selected) {
      color = Colors.blue;
    } else if (e.position == start) {
      color = Colors.yellow;
    } else if (e.position == end) {
      color = Colors.green;
    } else if (barriers.contains(e.position)) {
      color = Colors.red;
    } else if (e.done) {
      color = Colors.purple;
    }

    return InkWell(
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
        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.5),
          color: color,
        ),
        height: 10,
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
    }
  }

  void _start() {
    _cleanTiles();
    List<Point<int>> done = [];
    final result = AStar(
      rows: rows,
      columns: columns,
      start: start,
      end: end,
      barriers: barriers,
    ).findThePath(doneList: (doneList) {
      done = doneList;
    });

    print(AStar.resumePath(result));

    result.forEach((element) {
      done.remove(element);
    });

    done.remove(start);
    done.remove(end);

    setState(() {
      tiles.forEach((element) {
        element.selected = result.where((r) {
          return r == element.position;
        }).isNotEmpty;

        if (_showDoneList) {
          element.done = done.where((r) {
            return r == element.position;
          }).isNotEmpty;
        }
      });
    });
  }

  void _cleanTiles() {
    tiles.forEach((element) {
      element.selected = false;
      element.done = false;
    });
  }
}

class Tile {
  final Point<int> position;
  bool selected = false;
  bool done = false;

  Tile(this.position);
}
