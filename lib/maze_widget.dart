import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'maze_painter.dart';
import 'models/item.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer' as dev;
import 'Models/cell.dart';

///Maze
///
///Create a simple but powerfull maze game
///You can customize [wallColor], [wallThickness],
///[columns] and [rows]. A [player] is required and also
///you can pass a List of [checkpoints] and you will be notified
///if the player pass through a checkout at [onCheckpoint]
class Maze extends StatefulWidget {
  ///Default constructor
  Maze({
    required this.player,
    this.checkpoints = const [],
    this.columns = 5,
    this.finish,
    this.height,
    this.loadingWidget,
    this.onCheckpoint,
    this.onFinish,
    this.rows = 5,
    this.wallColor = Colors.black,
    this.wallThickness = 3.0,
    this.width,
  });

  ///List of checkpoints
  final List<MazeItem> checkpoints;

  ///Columns of the maze
  final int columns;

  ///The finish image
  final MazeItem? finish;

  ///Height of the maze
  final double? height;

  ///A widget to show while loading all
  final Widget? loadingWidget;

  ///Callback when the player pass through a checkpoint
  final Function(int)? onCheckpoint;

  ///Callback when the player reach finish
  final Function()? onFinish;

  ///The main player
  final MazeItem player;

  ///Rows of the maze
  final int rows;

  ///Wall color
  final Color? wallColor;

  ///Wall thickness
  ///
  ///Default: 3.0
  final double? wallThickness;

  ///Width of the maze
  final double? width;

  @override
  _MazeState createState() => _MazeState();
}

class _MazeState extends State<Maze> {
  double width = 2;
  bool _loaded = true;
  // final MazePainter _mazePainter = MazePainter(columns: 5, rows: 5);

  @override
  void initState() {
    super.initState();
    //setUp();
  }

  // void setUp() async {
  //   _mazePainter = MazePainter(
  //     columns: widget.columns,
  //     rows: widget.rows,
  //   );
  //   setState(() => _loaded = true);
  // }

  @override
  Widget build(BuildContext context) {
    final _mazePainter = Provider.of<MazePainter>(context, listen: false);
    BorderSide noBorder = BorderSide.none;
    BorderSide border = BorderSide(
      width: width,
      color: Colors.white,
    );
    return Builder(
      builder: (context) {
        if (_loaded) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.purple, Colors.orange],
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Algo Runner',
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 45,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            //mainAxisSpacing: 2,
                            crossAxisCount: _mazePainter.cells.first.length
                            //crossAxisSpacing: 2
                            ),
                        itemCount: _mazePainter.cells.first.length *
                            _mazePainter.cells.first.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Consumer<MazePainter>(
                            builder: ((context, value, _) {
                              Cell cell = value.cellList.elementAt(index);
                              return Container(
                                decoration: BoxDecoration(
                                  color: !_mazePainter.mazeSolved
                                      ? cell.isGoal
                                          ? Colors.green
                                          : Colors.transparent
                                      : cell.visited
                                          ? cell.isGoal
                                              ? Colors.green
                                              : cell.isBackTracked
                                                  ? Colors.blue
                                                  : Color.fromRGBO(
                                                      index, 0, index - 255, 1)
                                          : Colors.transparent,
                                  border: Border(
                                    bottom: cell.bottomWall ? border : noBorder,
                                    right: cell.rightWall ? border : noBorder,
                                    top: cell.topWall ? border : noBorder,
                                    left: cell.leftWall ? border : noBorder,
                                  ),

                                  // Border(
                                  //   bottom:  border ,
                                  //   right:  border ,
                                  //   top: border ,
                                  //   left:  border ,
                                  // ),
                                ),
                                // child: Center(
                                //   child: Icon(Icons.circle,
                                //       size: 5,
                                //       color:),
                                // ),
                                // child: Center(
                                //   child: Text(
                                //     '(${cell.row},${cell.col})',
                                //     style: GoogleFonts.montserrat(
                                //       color: Colors.white,
                                //       fontSize: 12,
                                //     ),
                                //   ),
                                // ),
                                // child: const Icon(
                                //   Icons.fiber_manual_record,
                                //   color: Colors.purple,
                                //   size: 5,
                                // ),
                              );
                            }),
                          );
                        }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          _mazePainter.createMaze();
                          //_mazePainter.depthFirstSearch();
                        },
                        icon: const Icon(
                          Icons.new_label,
                          color: Colors.blue,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _mazePainter.breathFirstSearch();
                            //_mazePainter.depthFirstSearch();
                          });
                        },
                        icon: const Icon(
                          Icons.play_arrow,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          if (widget.loadingWidget != null) {
            return widget.loadingWidget!;
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }
      },
    );
  }

  Future<ui.Image> _itemToImage(MazeItem item) {
    switch (item.type) {
      case ImageType.file:
        return _fileToByte(item.path);
      case ImageType.network:
        return _networkToByte(item.path);
      default:
        return _assetToByte(item.path);
    }
  }

  ///Creates a Image from file
  Future<ui.Image> _fileToByte(String path) async {
    final completer = Completer<ui.Image>();
    final bytes = await File(path).readAsBytes();
    ui.decodeImageFromList(bytes, completer.complete);
    return completer.future;
  }

  ///Creates a Image from asset
  Future<ui.Image> _assetToByte(String asset) async {
    final completer = Completer<ui.Image>();
    final bytes = await rootBundle.load(asset);
    ui.decodeImageFromList(bytes.buffer.asUint8List(), completer.complete);
    return completer.future;
  }

  ///Creates a Image from network
  Future<ui.Image> _networkToByte(String url) async {
    final completer = Completer<ui.Image>();
    final response = await http.get(Uri.parse(url));
    ui.decodeImageFromList(
        response.bodyBytes.buffer.asUint8List(), completer.complete);
    return completer.future;
  }
}

///Extension to get screen size
extension ScreenSizeExtension on BuildContext {
  ///Gets the current height
  double get height => MediaQuery.of(this).size.height;

  ///Gets the current width
  double get width => MediaQuery.of(this).size.width;
}






//BorderBakcup 

// Border(
//                           bottom: index > (itemCount - crossAxixCount) - 1 ||
//                                   random == 1
//                               ? border
//                               : noBorder,
//                           right:
//                               (index + 1) % crossAxixCount == 0 || random == 0
//                                   ? border
//                                   : noBorder,
//                           top: index < crossAxixCount ? border : noBorder,
//                           left: index % crossAxixCount == 0 ? border : noBorder,
//                         ),































//using padding
//  padding: EdgeInsets.only(
//                     top: index < crossAxixCount ? width : 0,
//                     bottom:
//                         index > (itemCount - crossAxixCount) - 1 || random == 1
//                             ? width
//                             : 0,
//                     left: index % crossAxixCount == 0 ? width : 0,
//                     right: (index + 1) % crossAxixCount == 0 || random == 0
//                         ? width
//                         : 0,
//                   ),







//  decoration: 
// BoxDecoration(
//                         color: Colors.transparent,
//                         border: Border(
//                           bottom: index > (itemCount - crossAxixCount) - 1 ||
//                                   random == 1
//                               ? border
//                               : noBorder,
//                           right:
//                               (index + 1) % crossAxixCount == 0 || random == 0
//                                   ? border
//                                   : noBorder,
//                           top: index < crossAxixCount ? border : noBorder,
//                           left: index % crossAxixCount == 0 ? border : noBorder,
//                         ),
//                       ),

//         ),

//border
// Border(
//                           bottom: index > (itemCount - crossAxixCount) - 1 ||
//                                   random == 1
//                               ? border
//                               : noBorder,
//                           right:
//                               (index + 1) % crossAxixCount == 0 || random == 0
//                                   ? border
//                                   : noBorder,
//                           top: index < crossAxixCount ? border : noBorder,
//                           left: index % crossAxixCount == 0 ? border : noBorder,
//                         ),
