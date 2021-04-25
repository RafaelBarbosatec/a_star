import 'package:a_star/a_star.dart';
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

  Offset start = Offset.zero;
  Offset end = Offset.zero;
  List<Tile> tiles = [];
  List<Offset> barriers = [];
  int rows = 20;
  int columns = 30;

  @override
  void initState() {
    List.generate(rows, (x) {
      List.generate(columns, (y) {
        final offset = Offset(x.toDouble(), y.toDouble());
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
      body: Center(
        child: Column(
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
                ],
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: columns,
              children: tiles.map((e) {
                return _buildItem(e);
              }).toList(),
            ),
            SizedBox(
              height: 50,
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  barriers.clear();
                  tiles.forEach((element) {
                    element.selected = false;
                  });
                });
              },
              child: Text('CLEAN'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _start,
        tooltip: 'Find path',
        child: Icon(Icons.map),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _start() {
    final result = AStar(
      rows: rows,
      columns: columns,
      start: start,
      end: end,
      barriers: barriers,
    ).findThePath();

    setState(() {
      tiles.forEach((element) {
        element.selected =
            result.where((r) => r == element.position).isNotEmpty;
      });
    });
  }

  Widget _buildItem(Tile e) {
    Color color = Colors.white;
    if (barriers.contains(e.position)) {
      color = Colors.red;
    }
    if (e.position == start) {
      color = Colors.yellow;
    }
    if (e.position == end) {
      color = Colors.green;
    }

    if (e.selected) {
      color = Colors.blue;
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
        print(e.position);
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
}

class Tile {
  final Offset position;
  bool selected = false;

  Tile(this.position);
}
