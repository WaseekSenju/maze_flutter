import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'maze_painter.dart';
import 'models/item.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer' as dev;

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
  double width = 1;
  int crossAxixCount = 50;
  bool _loaded = false;
  late MazePainter _mazePainter;

  @override
  void initState() {
    super.initState();
    setUp();
  }

  void setUp() async {
    final playerImage = await _itemToImage(widget.player);
    final checkpoints = await Future.wait(
        widget.checkpoints.map((c) async => await _itemToImage(c)));
    final finishImage =
        widget.finish != null ? await _itemToImage(widget.finish!) : null;

    _mazePainter = MazePainter(
      checkpointsImages: checkpoints,
      columns: widget.columns,
      finishImage: finishImage,
      onCheckpoint: widget.onCheckpoint,
      onFinish: widget.onFinish,
      playerImage: playerImage,
      rows: widget.rows,
      wallColor: widget.wallColor ?? Colors.black,
      wallThickness: widget.wallThickness ?? 4.0,
    );
    setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    int row = 0;
    int column = 0;
    var rng = Random();
    int itemCount = crossAxixCount * crossAxixCount;
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
                          var cell = _mazePainter.cellList.elementAt(index);
                          // dev.log(
                          //   '(${cell.row},${cell.col})',
                          // );
                          // dev.log(
                          //   'N:${cell.topWall},W:${cell.leftWall},S:${cell.bottomWall},E:${cell.rightWall}',
                          // );

                          // var cell = _mazePainter.cells
                          //     .elementAt(row)
                          //     .elementAt(c olumn);

                          return Container(
                            decoration: BoxDecoration(
                              color: cell.visited
                                  ? Colors.red
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
                            height: 1,
                            width: 1,
                            // child: Center(
                            //   child: Text(
                            //     '$index',
                            //     style: GoogleFonts.orbitron(
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
                  ),

                  IconButton(
                    onPressed: () {
                      setState(() {
                        _mazePainter.depthFirstSearch();
                      });
                    },
                    icon: const Icon(
                      Icons.add_circle,
                      color: Colors.purple,
                    ),
                  ),

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     IconButton(
                  //         onPressed: () {
                  //           setState(() {
                  //             crossAxixCount++;
                  //           });
                  //         },
                  //         icon: const Icon(
                  //           Icons.add_circle,
                  //           color: Colors.purple,
                  //         )),
                  //     Text(
                  //       '$crossAxixCount',
                  //       style: GoogleFonts.orbitron(
                  //         fontWeight: FontWeight.bold,
                  //         color: Colors.purple,
                  //         fontSize: 15,
                  //       ),
                  //     ),
                  //     IconButton(
                  //       onPressed: () {
                  //         setState(() {
                  //           crossAxixCount--;
                  //         });
                  //       },
                  //       icon: const Icon(Icons.remove_circle),
                  //       color: Colors.purple,
                  //     ),
                  //   ],
                  // ),
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
