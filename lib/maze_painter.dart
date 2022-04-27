import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide Stack;
import 'models/cell.dart';
import 'models/item_position.dart';
import 'models/stack.dart';
import 'dart:developer' as dev;

/// Direction movement
enum Direction {
  ///Goes up in the maze
  up,

  ///Goes down in the maze
  down,

  ///Goes left in the maze
  left,

  ///Goes right in the maze
  right
}

///Maze Painter
///
///Draws the maze based on params
class MazePainter {
  ///Default constructor
  MazePainter({
    required this.playerImage,
    this.checkpointsImages = const [],
    this.columns = 7,
    this.finishImage,
    this.onCheckpoint,
    this.onFinish,
    this.rows = 10,
    this.wallColor = Colors.black,
    this.wallThickness = 4.0,
  }) {
    _checkpoints = List.from(checkpointsImages);
    _checkpointsPositions = _checkpoints
        .map((i) => ItemPosition(
            col: _randomizer.nextInt(columns), row: _randomizer.nextInt(rows)))
        .toList();

    _createMaze();
  }

  ///Images for checkpoints
  final List<ui.Image> checkpointsImages;

  ///Number of collums
  final int columns;

  ///Image for player
  final ui.Image? finishImage;

  ///Callback when the player reach a checkpoint
  final Function(int)? onCheckpoint;

  ///Callback when the player reach the finish
  final Function? onFinish;

  ///Image for player
  final ui.Image playerImage;

  ///Number of rows
  final int rows;

  ///Color of the walls
  Color wallColor;

  final List<Cell> cellList = [];

  ///Size of the walls
  final double wallThickness;

  ///Private attributes
  late Cell _player, _exit;
  late List<ItemPosition> _checkpointsPositions;
  late List<List<Cell>> cells;
  late List<ui.Image> _checkpoints;
  late double _cellSize, _hMargin, _vMargin;

  ///Paints for `exit`, `player` and `walls`

  ///Randomizer for positions and walls distribution
  final Random _randomizer = Random();

  ///This method initialize the maze by randomizing what wall will be disable
  void _createMaze() {
    var stack = Stack<Cell>();
    Cell current;
    Cell? next;

    cells =
        List.generate(rows, (r) => List.generate(columns, (c) => Cell(r, c)));

    _player = cells.first.first;
    _exit = cells.last.last;

    current = cells.first.first..visited = true;

    //Recursive BackTracking Alog
    do {
      next = _getNext(current);
      if (next != null) {
        _removeWall(current, next);
        stack.push(current);
        current = next..visited = true;
      } else {
        current = stack.pop();
      }
    } while (stack.isNotEmpty);

    for (var i = 0; i < cells.length; i++) {
      for (var j = 0; j < cells[i].length; j++) {
        cellList.add(cells[i][j]);
        // dev.log(
        //   '(${cells[i][j].row},${cells[i][j].col})',
        // );
        // dev.log(
        //   'N:${cells[i][j].topWall},W:${cells[i][j].leftWall},S:${cells[i][j].bottomWall},E:${cells[i][j].rightWall}',
        // );
      }
    }
    //depthFirstSearch();
  }

  void depthFirstSearch() {
    var stack = Stack<Cell>();
    stack.push(cells.first.first);

    //making all cells unvisited for DFS
    for (var rows in cells) {
      for (var cell in rows) {
        cell.visited = false;
      }
    }

    while (cells.last.last.visited != true) {
      Cell current = stack.pop();
      //-------Bottom

      // if (current.bottomWall == true &&
      //     !cells[current.row + 1][current.col].visited &&
      //     current.rightWall == true &&
      //     !cells[current.row][current.col + 1].visited &&
      //     current.topWall == true &&
      //     !cells[current.row - 1][current.col].visited &&
      //     current.leftWall == false &&
      //     !cells[current.row][current.col - 1].visited) {
      //   stack.pop();
      //   dev.log('This is the phada node');
      //   dev.log(
      //     '(${current.row},${current.col})',
      //   );
      //   dev.log(
      //     'N:${current.topWall},W:${current.leftWall},S:${current.bottomWall},E:${current.rightWall}',
      //   );
      // }
      if (current.bottomWall == false &&
          !cells[current.row + 1][current.col].visited) {
        stack.push(cells[current.row + 1][current.col]);
        cells[current.row + 1][current.col].visited = true;
        dev.log(
          '(${current.row},${current.col})',
        );
        dev.log(
          'N:${current.topWall},W:${current.leftWall},S:${current.bottomWall},E:${current.rightWall}',
        );
      }
      //-------Right
      else if (current.rightWall == false &&
          !cells[current.row][current.col + 1].visited) {
        stack.push(cells[current.row][current.col + 1]);
        cells[current.row][current.col + 1].visited = true;
        dev.log(
          '(${current.row},${current.col})',
        );
        dev.log(
          'N:${current.topWall},W:${current.leftWall},S:${current.bottomWall},E:${current.rightWall}',
        );
      }
      //-------Top
      else if (current.topWall == false &&
          !cells[current.row - 1][current.col].visited) {
        stack.push(cells[current.row - 1][current.col]);
        cells[current.row - 1][current.col].visited = true;
        dev.log('This is the phada node');
        dev.log(
          '(${current.row},${current.col})',
        );
        dev.log(
          'N:${current.topWall},W:${current.leftWall},S:${current.bottomWall},E:${current.rightWall}',
        );
      }
      //-------Left
      else if (current.leftWall == false &&
          !cells[current.row][current.col - 1].visited) {
        stack.push(cells[current.row][current.col - 1]);
        cells[current.row][current.col - 1].visited = true;
        dev.log(
          '(${current.row},${current.col})',
        );
        dev.log(
          'N:${current.topWall},W:${current.leftWall},S:${current.bottomWall},E:${current.rightWall}',
        );
      } else {
        stack.pop();
        dev.log(
          '(${current.row},${current.col})',
        );
        dev.log(
          'N:${current.topWall},W:${current.leftWall},S:${current.bottomWall},E:${current.rightWall}',
        );
      }
    }
  }

  Cell? _getNext(Cell cell) {
    var neighbours = <Cell>[];

    //left
    if (cell.col > 0) {
      if (!cells[cell.row][cell.col - 1].visited) {
        neighbours.add(cells[cell.row][cell.col - 1]);
      }
    }

    //right
    if (cell.col < columns - 1) {
      if (!cells[cell.row][cell.col + 1].visited) {
        neighbours.add(cells[cell.row][cell.col + 1]);
      }
    }

    //Top
    if (cell.row > 0) {
      if (!cells[cell.row - 1][cell.col].visited) {
        neighbours.add(cells[cell.row - 1][cell.col]);
      }
    }

    //Bottom
    if (cell.row < rows - 1) {
      if (!cells[cell.row + 1][cell.col].visited) {
        neighbours.add(cells[cell.row + 1][cell.col]);
      }
    }
    if (neighbours.isNotEmpty) {
      final index = _randomizer.nextInt(neighbours.length);
      return neighbours[index];
    }
    return null;
  }

  void _removeWall(Cell current, Cell next) {
    //Below
    if (current.col == next.col && current.row == next.row + 1) {
      current.topWall = false;
      next.bottomWall = false;
    }

    //Above
    if (current.col == next.col && current.row == next.row - 1) {
      current.bottomWall = false;
      next.topWall = false;
    }

    //right
    if (current.col == next.col + 1 && current.row == next.row) {
      current.leftWall = false;
      next.rightWall = false;
    }

    //left
    if (current.col == next.col - 1 && current.row == next.row) {
      current.rightWall = false;
      next.leftWall = false;
    }
  }

  ItemPosition? _getItemPosition(int col, int row) {
    try {
      return _checkpointsPositions.singleWhere(
          (element) => element == ItemPosition(col: col, row: row));
    } catch (e) {
      return null;
    }
  }
}
