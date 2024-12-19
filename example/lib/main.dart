import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(_MyApp());
}

class _MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _MyHomePage(),
    );
  }
}

enum TypeInput {
  startPoint,
  endPoint,
  barriers,
}

class _MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  TypeInput _typeInput = TypeInput.startPoint;

  bool _showDoneList = false;
  (int, int) start = (0, 0);
  (int, int) end = (0, 0);
  List<Tile> tiles = [];
  List<(int, int)> barriers = [];
  int rows = 20;
  int columns = 20;

  @override
  void initState() {
    List.generate(rows, (y) {
      List.generate(columns, (x) {
        final offset = (x, y);
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
        title: const Text('A*'),
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
                      _typeInput = TypeInput.startPoint;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: _getColorSelected(TypeInput.startPoint),
                  ),
                  child: const Text('START'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _typeInput = TypeInput.endPoint;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: _getColorSelected(TypeInput.endPoint),
                  ),
                  child: const Text('END'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _typeInput = TypeInput.barriers;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: _getColorSelected(TypeInput.barriers),
                  ),
                  child: const Text('BARRIES'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      barriers.clear();
                      _cleanTiles();
                    });
                  },
                  child: const Text('CLEAN'),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: columns,
              children: tiles.map(_buildItem).toList(),
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
              const Text('Show done list'),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _start,
        tooltip: 'Find path',
        child: const Icon(Icons.map),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildItem(Tile e) {
    var color = Colors.white;
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
        if (_typeInput == TypeInput.startPoint) {
          start = e.position;
        }

        if (_typeInput == TypeInput.endPoint) {
          end = e.position;
        }

        if (_typeInput == TypeInput.barriers) {
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

  WidgetStateProperty<Color> _getColorSelected(TypeInput input) {
    return WidgetStateProperty.all(
      _typeInput == input ? _getColorByType(input) : Colors.grey,
    );
  }

  Color _getColorByType(TypeInput input) {
    switch (input) {
      case TypeInput.startPoint:
        return Colors.yellow;
      case TypeInput.endPoint:
        return Colors.green;
      case TypeInput.barriers:
        return Colors.red;
    }
  }

  void _start() {
    _cleanTiles();
    var done = <(int, int)>[];
    final result = AStar(
      rows: rows,
      columns: columns,
      start: start,
      end: end,
      barriers: barriers,
    ).findThePath(
      doneList: (doneList) {
        done = doneList;
      },
    );

    print(AStar.simplifyPath(result));

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
  final (int, int) position;
  bool selected = false;
  bool done = false;

  Tile(this.position);
}
