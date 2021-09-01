void main(List<String> arguments) {
  var nodes = <String>["a", "b", "c", "d", "e"];
  print('Hello world!');
}

class Graph<T> {
  final Map<T, int> nodeIndex = {};
  final List<T> nodes;
  final List<List<double>> cost = [];

  Graph(this.nodes) {
    // initialize weights of cost matric to infinity
    for (var a = 0; a < nodes.length; a++) {
      // Set index in nodeIndex
      nodeIndex[nodes[a]] = a;

      List<double> list = <double>[];
      for (var b = 0; b < nodes.length; b++) {
        list.add(double.infinity);
      }

      cost.add(list);
    }
  }

  int _getIndex(T node) {
      final index = nodeIndex[node];

      if (index == null) {
        throw ("node must be part of the graph")
      }

      return index;
  }

  void addEdge(T from, T to, double weight) {
    final indexFrom = _getIndex(from);
    final indexTo = _getIndex(to);

    cost[indexFrom][indexTo] = weight;
  }

  // computes cost matrix using dijkstras algorithm
  void shortestPath(T from) {
    // index of `from` in cost matrix
    final indexFrom = _getIndex(from);

    // vector of distances to `from`
    var d = <double>[];

    // maps nodes (indexes) to their predecessors on a shortest path to `from`
    var p = <int?>[];

    // Note: performance could be improved by using set of all nodes with unknown path
    // set of all nodes indices for which least cost path is known
    var M = {indexFrom};

    // initialize distance vector
    for (var indexTo = 0; indexTo < nodes.length; indexTo++) {
      d.add(cost[indexFrom][indexTo]);
      p.add(null);
    }


    // repeate until shortest path to all nodes is known 
    while (M.length != nodes.length) {
      // find minimal d(j)
      int j = _findMinimal(d, M);
      M.add(j);

      // for all nodes not in M
      for (var k = 0; k < nodes.length; k++) { 
          if (M.contains(k)) { continue; }

          var neighbourCost = d[j] + cost[j][k];

          if (d[k] > neighbourCost) {
            d[k] = neighbourCost;
            p[k] = j;
          }
      }
    }
  }

  int _findMinimal(List<double> d, Set<int> m) {
    double? minValue;
    int? minIndex;

    for (int index = 0; index< d.length; index ++) {
      // skip all nodes already in set m
      if (m.contains(index)) { continue; }

      // set index to index of minimal element 
      if (minValue == null || d[index] < minValue) {
        minValue = d[index];
        minIndex = index;
      }
    }

    if (minIndex == null) {
      throw("no suitable node in set");
    }

    return minIndex;
  }
}
