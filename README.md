# A very inefficient AlgoRunner :satisfied:

A simple visualization app that creates a maze and then uses Breadth First and Depth First and A star algorithm to solve the randomly generated maze from scratch.

## Intro
As computer science students we often find it hard to understand where these algorithms that we study and implement through our code can be used in a real-world scenario? or How can we simulate the working of these algorithms on a small scale where we can visually see the characteristics of each algorithm through some visual representation? For our scenario, we have considered Mazes and we will use Search Algorithms to find paths in those complex mazes. So we can visually see the core difference of how algorithms like BFS and DFS differ from each other in the same maze and mimic a different behavior. 
One can understand the code and abstract working of the algorithm but it is really hard for beginners to imagine how these algorithms can have applications in our daily life Apps like Google maps use this algorithm under the hood. Also, we can convert this idea into a small game where you are the agent and you to 

## The Algorithm used for the generation of the maze

There are many algorithms that we can use to generate a random maze and the one I have used in my program is known as the recursive backtracking algorithm I used this one because it’s really easy to implement and it generates a Perfect maze i.e there is only one path from a particular start node to the end node.As you can see my Algorithm can only have “one’’ solution through the maze.
Here is my code for the generation of the maze that is known as the recursive backtracking algorithm but in fact, it doesn’t use the recursion at all; the algorithm is iterative.

[Algorithms: For generating maze a perfect maze](https://www.astrolog.org/labyrnth/algrithm.htm) :paperclip:

```dart
void generateMaze() async {
    //---------Start the processing---------------------------------------------
    isProcessing = true;
    notifyListeners();
    //--------------------------------------------------------------------------
    var maze = MazeData.mazeAdjacencyList;
    //Choose the initial cell, mark it as visited
    //and push it to the stack-------------------
    CellNode current = maze[0][0];
    current.isVisited = true;
    stack.push(current);
    // --While the Stack is not Empty------------
    while (stack.isNotEmpty()) {
      current = stack.pop();
      var result = current.checkNeighbors();
      if (result != null) {
        stack.push(current);
        await Future.delayed(Duration(milliseconds: MazeData.duration));
        notifyListeners();
        current.removeWall(result);
        result.isVisited = true;
        stack.push(result);
      }
    }
    isMazeGenerated = true;
    isProcessing = false;
    notifyListeners();
  }
```

To understand the above code one must take a look at the CellNode class.
```dart 
class CellNode {
  CellNode({
    required this.rowNumber,
    required this.colNumber,
    required this.walls,
    required this.cellColor,
    required this.isVisited,
    required this.isTop,
    required this.isPath,
    required this.f,
    required this.h,
    required this.g,
  });

  CellNode.empty({
    this.rowNumber = 0,
    this.colNumber = 0,
    this.walls = const [true, true, true, true],
    this.cellColor = Colors.red,
    this.isVisited = false,
    this.isTop = false,
    this.isPath = false,
    this.f = maxInt,
    this.g = maxInt,
    this.h = maxInt,
  });
 ```

So basically it selects the first node and randomly chooses any direction from the top, bottom, right, or left and removes the wall from the border of that square block that I have stated as CellNode and after that, it marks that CellNode as visited. So if the algorithm ever encounters the same node again it won’t move toward that particular node because it’s already been visited. It uses a stack to backtrack if such a situation is encountered. 

# 3- Finding Path in the Maze
Now I have demonstrated how you can generate a simple maze and represent that Data Structure visually in the form of a grid where each element of the grid is a Node that contains the data about the current state of the cell.
As our environment is Deterministic and we know how the world looks, we can use many simple paths finding algorithms to find paths from one node to another node. I have used Informed and Uninformed search Algos:

1-Breadth First Search\
2-Depth First Search\
3- A star

As the Maze is a perfect maze and no matter which algorithm we use we will always get the same path but the interesting thing to note here is how each algorithm propagates in the maze which is the whole purpose of this project. 

# 4- The Agent
Now let's talk about the Agent. We will pass the generated maze data structure to our agent and the users can select which algorithm they want to apply to that maze. 
Just like the generation of the maze algorithm above, these algorithms will take the starting node and check the possible paths from where they can move in a direction till the goal node is not reached. I will explain Breadth First Search Algorithm in detail below is the code it has code related to GUI too but I will abstract out the logical part and explain it:

```dart
 void breathFirstSearch() async {
    //---------Start the processing---------------------------------------------
    isProcessing = true;
    notifyListeners();
    //--------------------------------------------------------------------------

    var maze = MazeData.mazeAdjacencyList;

    var frontier = Queue<CellNode>();
    var explorered = Queue<CellNode>();

    Map<CellNode, CellNode> path = {};
    var fwdPath = {};

    CellNode child = CellNode.empty();

    explorered.addFirst(maze.first.first);
    frontier.addFirst(maze.first.first);

    //making all maze unvisited for DFS
    for (var rows in maze) {
      for (var cell in rows) {
        cell.isVisited = false;
      }
    }
    //(maze.last.last.isVisited != true)
    while (frontier.isNotEmpty) {
      CellNode current = frontier.removeFirst();

      if (current == maze.last.last) {
        break;
      }

      for (int i = 0; i < 4; i++) {
        //-------Bottom
        if (current.walls[2] == false &&
            !maze[current.rowNumber + 1][current.colNumber].isVisited) {
          child = maze[current.rowNumber + 1][current.colNumber];

          child.isVisited = true;
        }
        //-------Right
        else if (current.walls[1] == false &&
            !maze[current.rowNumber][current.colNumber + 1].isVisited) {
          child = maze[current.rowNumber][current.colNumber + 1];
          child.isVisited = true;
        }
        //-------Top
        else if (current.walls[0] == false &&
            !maze[current.rowNumber - 1][current.colNumber].isVisited) {
          child = maze[current.rowNumber - 1][current.colNumber];
          child.isVisited = true;
        }
        //-------Left
        else if (current.walls[3] == false &&
            !maze[current.rowNumber][current.colNumber - 1].isVisited) {
          maze[current.rowNumber][current.colNumber - 1].isVisited = true;
          child = maze[current.rowNumber][current.colNumber - 1];
          child.isVisited = true;
        }

        if (explorered.contains(child)) {
          continue;
        }
        frontier.add(child);
        explorered.add(child);
        nodesExplored++;
        path[child] = current;
        await Future.delayed(Duration(milliseconds: MazeData.duration));
        notifyListeners();
      }
    }

    var start = maze.first.first;
    var cell = maze.last.last;

    while (start != cell) {
      await Future.delayed(Duration(milliseconds: MazeData.duration));
      cell.isPath = true;
      pathLength++;
      notifyListeners();
      cell = path[cell]!;
    }
    start.isPath = true;
    isProcessing = false;
    notifyListeners();
  }
```
As our Maze is basically a graph and our agent will pick one node and search all its possible neighbors and then pick the neighbors and search them level by level this will guarantee the shortest path in the maze.
As we know we use a Queue Data Structure for the Breadth First Search we will maintain two Queues one that will keep track of currently opened nodes and one that will keep track of completely  visited nodes. When we visit a node we check in each possible direction and put all those nodes that can be explored in the frontier Queue  and when we dequeue one element from the frontier Queue we put that in the explored Queue. 
And I have also maintained a Map of type <Node,Node>
That contains the child and parent node child node as key and parent as the value <child,parent> and I have used this Map to generate the actual path from the start node to the goal node but there is problem with it it is inverted i.e form goal to start so I have used a while loop in the end to invert this path and visually manipulate the 
isPath bool in each Node of the Maze to show the path and visited nodes separately in the Maze Ui. 


The basic Idea for the other two algos is same just a little difference for the A star algorithm is that we maintain the value of the function 


f(n) = g(n) + h(n)
And depending upon the minimum f(n) we will choose the next node as it is an informed search unlike those of BFS and DFS. Also it uses a Priority Queue that uses Heap and the backend to sort the Nodes according to the minimum value of f that is an attribute defined the CellNode as well.

# 5 - A Final Word
It is really amazing to see that a few lined algorithms can do search in a maze. It is sure fun to watch but apart from being an eye candy in this app they have an important role in everything we look around ourselves, especially in Photo Manipulation softwares like Photoshop  and Maps applications like Google Maps.  Understanding these algorithms gave me a broader look on how we can use basic Ai knowledge in real life scenarios.

