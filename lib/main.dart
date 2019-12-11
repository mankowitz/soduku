// Copyright 2019 The Scott team. No rights reserved.

/*
   * Starting
   * 750943002
   * 024005090
   * 300020000
   * 140089005
   * 093050170
   * 500360024
   * 000070009
   * 070400810
   * 400198057
   * 
   * Solution
   * 751943682
   * 824615793
   * 369827541
   * 142789365
   * 693254178
   * 587361924
   * 218576439
   * 975432816
   * 436198257
   */

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Soduku solver", home: Soduku());
  }
}

class SodukuState extends State<Soduku> {
  SodukuSolver ss;
  List<String> _list;
  int _changes = 0;
  int _remaining = 81;

  @override
  void initState() {
    super.initState();

    final String _starting =
        "750943002024005090300020000140089005093050170500360024000070009070400810400198057";
    //     "934500060005067090000040503000000009601070402800000000206090000090280700080004926";
    ss = new SodukuSolver(_starting);
    _list = ss.getList();
  }

  @override
  Widget build(BuildContext context) {
    //var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: Text('Soduku solver'), actions: <Widget>[
        // action button
        IconButton(
          icon: Icon(Icons.directions_walk),
          onPressed: () {
            _iterate();
          },
        ),

        FlatButton(
          textColor: Colors.white,
          onPressed: () {},
          child: Text("$_remaining left"),
          shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
        ),

        FlatButton(
          textColor: Colors.white,
          onPressed: () {},
          child: Text("$_changes new"),
          shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
        ),
      ]),
      body: _buildGrid(),
    );
  }

  Widget _buildGrid() {
    return Column(children: <Widget>[
      AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          padding: const EdgeInsets.all(4.0),
          margin: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2.0)),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 9,
            ),
            itemBuilder: _buildGridItems,
            itemCount: 81,
          ),
        ),
      ),
    ]);
  }

  Widget _buildGridItems(BuildContext context, int index) {
    int x, y;
    x = index ~/ 9;
    y = index % 9;
    return GestureDetector(
      // onTap: () => _gridItemTapped(),
      child: GridTile(
        child: Container(
          decoration: BoxDecoration(
              border: Border(
            top: BorderSide(width: (x % 3 == 0) ? 3 : 1, color: Colors.black),
            left: BorderSide(width: (y % 3 == 0) ? 3 : 1, color: Colors.black),
            right: BorderSide(width: (y == 8) ? 3 : 1, color: Colors.black),
            bottom: BorderSide(width: (x == 8) ? 3 : 1, color: Colors.black),
          )),
          child: Center(
            child: Text(_list[index]),
          ),
        ),
      ),
    );
  }

  void _iterate() {
    setState(() {
      _changes = ss.iterateSoduku();
      _remaining = ss.empties();
      _list = ss.getList();
    });
  }
}

class Soduku extends StatefulWidget {
  @override
  SodukuState createState() => SodukuState();
}

class SodukuSolver {
  final Set fullSet = new Set.from([1, 2, 3, 4, 5, 6, 7, 8, 9]);
  List<Set<int>> rows = new List.generate(9, (_) => new Set());
  List<Set<int>> cols = new List.generate(9, (_) => new Set());
  List<Set<int>> boxes = new List.generate(9, (_) => new Set());
  List<List<int>> _gridState;
  List<List<Set<int>>> _possibles;

  SodukuSolver(String starting) {
    _gridState = new List.generate(9, (_) => new List(9));
    _possibles = new List.generate(9, (_) => new List(9));
    for (int x = 0; x < 9; x++)
      for (int y = 0; y < 9; y++)
        _gridState[x][y] = int.parse(starting[x * 9 + y]);
  }

  void printGrid() {
    print('$_gridState');
  }

  int empties() {
    int _empty = 0;
    for (int x = 0; x < 9; x++)
      for (int y = 0; y < 9; y++) if (_gridState[x][y] == 0) _empty++;
    return _empty;
  }

  List<String> getList() {
    List<String> list = List<String>(81);
    for (int y = 0; y < 9; y++) {
      for (int x = 0; x < 9; x++) {
        int val = _gridState[x][y];
        list[x * 9 + y] = (val == 0) ? "" : val.toString();
      }
    }
    return list;
  }

  int iterateSoduku() {
    int x, y, box;
    int changes = 0;

    // rows
    for (x = 0; x < 9; x++) {
      for (y = 0; y < 9; y++) {
        if (_gridState[x][y] != 0) rows[x].add(_gridState[x][y]);
      }
      changes += fillIncompleteRow(x);
    }

    // cols
    for (y = 0; y < 9; y++) {
      for (x = 0; x < 9; x++) {
        if (_gridState[x][y] != 0) cols[y].add(_gridState[x][y]);
      }
      changes += fillIncompleteCol(y);
    }

// boxes
    for (int boxx = 0; boxx < 9; boxx += 3)
      for (int boxy = 0; boxy < 9; boxy += 3) {
        box = boxy ~/ 3 + boxx;
        for (int x = 0; x < 3; x++)
          for (int y = 0; y < 3; y++) {
            if (_gridState[boxx + x][boxy + y] != 0)
              boxes[box].add(_gridState[boxx + x][boxy + y]);
          }
        changes += fillIncompleteBox(box);
      }

    // find possible numbers for each box
    for (x = 0; x < 9; x++) {
      for (y = 0; y < 9; y++) {
        if (_gridState[x][y] == 0) {
          _possibles[x][y] = new Set.from(fullSet);
          _possibles[x][y].removeAll(rows[x]);
          _possibles[x][y].removeAll(cols[y]);
          _possibles[x][y].removeAll(boxes[whichBox(x, y)]);

          if (_possibles[x][y].length == 1) {
            _gridState[x][y] = _possibles[x][y].first;
            changes += 1;
          }
        }
      }
    }

    return changes;
  }

  int whichBox(int x, int y) {
    return (y ~/ 3 + 3 * (x ~/ 3));
  }

  int fillIncompleteRow(int x) {
    if (rows[x].length == 8) {
      final int missing = fullSet.difference(rows[x]).first;
      for (int y = 0; y < 9; y++) {
        if (_gridState[x][y] == 0) {
          _gridState[x][y] = missing;
          return 1;
        }
      }
    }
    return 0;
  }

  int fillIncompleteCol(int y) {
    if (cols[y].length == 8) {
      final int missing = fullSet.difference(cols[y]).first;
      for (int x = 0; x < x; y++) {
        if (_gridState[x][y] == 0) {
          _gridState[x][y] = missing;
          return 1;
        }
      }
    }
    return 0;
  }

  int fillIncompleteBox(int box) {
    if (boxes[box].length == 8) {
      final int missing = fullSet.difference(boxes[box]).first;
      final int boxx = 3 * (box ~/ 3);
      final int boxy = 3 * (box % 3);
      for (int x = 0; x < 3; x++)
        for (int y = 0; y < 3; y++) {
          if (_gridState[boxx + x][boxy + y] == 0)
            _gridState[boxx + x][boxy + y] = missing;
          return 1;
        }
    }
    return 0;
  }
}
