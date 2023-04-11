import 'dart:io';

class EightPuzzleSolver {
  int maxIterations = 10000;
  List<List<int>> openList = [];
  List<List<int>> closedList = [];
  List<List<int>> initialState =
      List.generate(4, (_) => List<int>.filled(3, 0));
  List<List<int>> goalState = List.generate(4, (_) => List<int>.filled(3, 0));
  List<List<List<int>>> solutionPath = [];

  int row = 0;
  int column = 0;
  int previousRow = -1;
  int previousColumn = -1;
  int depth = 0;
  int mismatchedTiles = 0;
  int states = 1;
  void findSuccessor(List<List<int>> orgNode, int depth) {
    findEmptySpace(orgNode);
    List<List<int>> directions = [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1]
    ];
    int calculateMismatchedTiles(List<List<int>> state) {
      int count = 0;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (state[i][j] != goalState[i][j]) {
            count++;
          }
        }
      }
      return count;
    }

    for (List<int> direction in directions) {
      int newRow = row + direction[0];
      int newCol = column + direction[1];

      if (newRow >= 0 &&
          newRow < 3 &&
          newCol >= 0 &&
          newCol < 3 &&
          (newRow != previousRow || newCol != previousColumn)) {
        List<List<int>> newState =
            List.generate(4, (_) => List<int>.filled(3, 0));
        for (int i = 0; i < 3; i++) {
          newState[i].setAll(0, orgNode[i]);
        }

        int temp = newState[newRow][newCol];
        newState[newRow][newCol] = newState[row][column];
        newState[row][column] = temp;
        newState[3][1] = depth;
        if (!stateExistsInLists(newState)) {
          var cost = depth + calculateMismatchedTiles(newState);
          newState[3][0] = cost;
          openList.add(stateToList(newState));
        }
      }
    }
  }

  EightPuzzleSolver(List<List<int>> initialState, List<List<int>> goalState) {
    this.initialState = List.generate(4, (_) => List<int>.filled(3, 0));
    for (int i = 0; i < 3; i++) {
      this.initialState[i].setAll(0, initialState[i]);
    }
    this.initialState[3][0] = 0; // Cost
    this.initialState[3][1] = 0; // Depth

    this.goalState = List.generate(3, (_) => List<int>.filled(3, 0));
    for (int i = 0; i < 3; i++) {
      this.goalState[i].setAll(0, goalState[i]);
    }
  }

  List<int> stateToList(List<List<int>> state) {
    List<int> flattened = [];
    for (int i = 0; i < 3; i++) {
      flattened.addAll(state[i]);
    }
    flattened.add(state[3][0]);
    flattened.add(state[3][1]);
    return flattened;
  }

  List<List<int>> listToState(List<int> flattened) {
    List<List<int>> state = List.generate(4, (_) => List<int>.filled(3, 0));
    for (int i = 0; i < 3; i++) {
      state[i] = flattened.sublist(i * 3, i * 3 + 3);
    }
    state[3][0] = flattened[9];
    state[3][1] = flattened[10];
    return state;
  }

  bool stateExistsInLists(List<List<int>> state) {
    List<int> stateAsList = stateToList(state);
    for (List<int> s in openList) {
      if (listEquals(state, listToState(s))) {
        return true;
      }
    }
    for (List<int> s in closedList) {
      if (listEquals(state, listToState(s))) {
        return true;
      }
    }
    return false;
  }

  // ...

  void expand(List<List<int>> node, int depth) {
    print('Expanding state (depth: $depth):');
    printState(node); // Print the state being expanded
    findSuccessor(node, depth);
    previousRow = row;
    previousColumn = column;
  }

  // ...

  void findEmptySpace(List<List<int>> state) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (state[i][j] == 0) {
          row = i;
          column = j;
          return;
        }
      }
    }
  }

  List<List<int>> findBestNode() {
    int bestIndex = 0;
    int bestCost = openList[0][9];
    int bestDepth = openList[0][10];
    for (int i = 1; i < openList.length; i++) {
      if (openList[i][9] < bestCost ||
          (openList[i][9] == bestCost && openList[i][10] < bestDepth)) {
        bestCost = openList[i][9];
        bestDepth = openList[i][10];
        bestIndex = i;
      }
    }
    List<List<int>> bestNode = listToState(openList[bestIndex]);
    openList.removeAt(bestIndex);
    return bestNode;
  }

  bool isGoalState(List<List<int>> state) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (state[i][j] != goalState[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  void printState(List<List<int>> state) {
    for (int i = 0; i < 3; i++) {
      print(state[i].join(' '));
    }
    print('');
  }

  String treeSearch() {
    openList.add(stateToList(initialState));
    int iterations = 0;
    while (openList.isNotEmpty && iterations < maxIterations) {
      List<List<int>> currentNode = findBestNode();
      solutionPath.add(currentNode);
      if (isGoalState(currentNode)) {
        print('Solution found in ${currentNode[3][1]} steps:\n');
        for (List<List<int>> state in solutionPath.reversed) {
          printState(state);
        }
        return '';
      }
      closedList.add(stateToList(currentNode));
      expand(currentNode, currentNode[3][1] + 1);
      iterations++;
    }
    return iterations >= maxIterations
        ? 'No solution found (maximum iterations reached)'
        : 'No solution found';
  }
}

bool listEquals(List<List<int>> a, List<List<int>> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i].length != b[i].length) return false;
    for (int j = 0; j < a[i].length; j++) {
      if (a[i][j] != b[i][j]) return false;
    }
  }
  return true;
}

// ... (your EightPuzzleSolver class code and listEquals function)

void main() {
  List<List<int>> initialState =
      List.generate(3, (_) => List<int>.filled(3, 0));
  List<List<int>> goalState = List.generate(3, (_) => List<int>.filled(3, 0));

  print('Enter the initial state of the puzzle (3x3):');
  for (int i = 0; i < 3; i++) {
    String? input = stdin.readLineSync();
    if (input != null) {
      initialState[i] = input.split(' ').map(int.parse).toList();
    }
  }

  print('\nEnter the goal state of the puzzle (3x3):');
  for (int i = 0; i < 3; i++) {
    String? input = stdin.readLineSync();
    if (input != null) {
      goalState[i] = input.split(' ').map(int.parse).toList();
    }
  }
  bool isSolvable(List<List<int>> initialState, List<List<int>> goalState) {
    int inversions(List<List<int>> state) {
      List<int> flatState = state.expand((row) => row).toList();
      int invCount = 0;
      for (int i = 0; i < flatState.length - 1; i++) {
        for (int j = i + 1; j < flatState.length; j++) {
          if (flatState[i] != 0 &&
              flatState[j] != 0 &&
              flatState[i] > flatState[j]) {
            invCount++;
          }
        }
      }
      return invCount;
    }

    return inversions(initialState) % 2 == inversions(goalState) % 2;
  }

  if (isSolvable(initialState, goalState)) {
    EightPuzzleSolver solver = EightPuzzleSolver(initialState, goalState);
    var s = solver.treeSearch();
    print(s);
  } else {
    print("The given puzzle is not solvable.");
  }
}
