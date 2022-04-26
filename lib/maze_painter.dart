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
        List.generate(columns, (c) => List.generate(rows, (r) => Cell(c, r)));

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
        cellList.add(cells[j][i]);
        dev.log(
          '(${cells[i][j].row},${cells[i][j].col})',
        );
        dev.log(
          'N:${cells[i][j].topWall},W:${cells[i][j].leftWall},S:${cells[i][j].bottomWall},E:${cells[i][j].rightWall}',
        );
      }
    }
  }


  Cell? _getNext(Cell cell) {
    var neighbours = <Cell>[];

    //left
    if (cell.col > 0) {
      if (!cells[cell.col - 1][cell.row].visited) {
        neighbours.add(cells[cell.col - 1][cell.row]);
      }
    }

    //right
    if (cell.col < columns - 1) {
      if (!cells[cell.col + 1][cell.row].visited) {
        neighbours.add(cells[cell.col + 1][cell.row]);
      }
    }

    //Top
    if (cell.row > 0) {
      if (!cells[cell.col][cell.row - 1].visited) {
        neighbours.add(cells[cell.col][cell.row - 1]);
      }
    }

    //Bottom
    if (cell.row < rows - 1) {
      if (!cells[cell.col][cell.row + 1].visited) {
        neighbours.add(cells[cell.col][cell.row + 1]);
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
