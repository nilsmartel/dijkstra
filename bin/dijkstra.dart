void main(List<String> arguments) {
  // Write list of nodes of graph here
  var nodes = <String>["a", "b", "c", "d", "e", "f"];
  var graph = Graph(nodes);

  // Edit this
  var source = 'a';
  {
    // helper function to add an non directed edge
    void edge(node1, node2, double weight) {
      graph.addEdge(node1, node2, weight);
      graph.addEdge(node2, node1, weight);
    }

    final a = "a";
    final b = "b";
    final c = "c";
    final d = "d";
    final e = "e";
    final f = "f";

    // include all edges here

    edge(a, b, 2);
    edge(a, c, 1);
    edge(b, d, 2);
    edge(b, e, 3);
    edge(c, d, 2);
    edge(c, f, 4);
    edge(d, e, 1);
    edge(d, f, 1);
    edge(e, f, 2);
  }

  // now print a nice csv document, separated with ; (because excel is bad with ,)
  // Note that we dont print the table for the source node
  print("M;" +
      nodes.where((n) => n != source).map((n) => "d($n);p($n)").join(";"));

  for (var info in graph.shortestPath(source)) {
    // line in csv; format
    var line = info.M.join(" ") + ";";

    line += () sync* {
      for (var node in nodes) {
        if (node == source) {
          continue;
        }

        var d = info.d[node];
        var valueForD = d.toString();
        if (d!.isInfinite) {
          valueForD = "∞";
        }
        var p = info.p[node]?.toString() ?? "-";

        yield "$valueForD;$p";
      }
    }()
        .join(";");

    print(line);
  }
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
      throw ("node must be part of the graph");
    }

    return index;
  }

  void addEdge(T from, T to, double weight) {
    final indexFrom = _getIndex(from);
    final indexTo = _getIndex(to);

    cost[indexFrom][indexTo] = weight;
  }

  // computes cost matrix using dijkstras algorithm
  Iterable<PathInfo> shortestPath(T from) sync* {
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
      // cost to arrive at this node
      var c = cost[indexFrom][indexTo];
      d.add(c);
      // if node a direct neighbour of `from`
      if (c.isFinite) {
        p.add(indexFrom);
      } else {
        p.add(null);
      }
    }

    // repeate until shortest path to all nodes is known
    while (M.length != nodes.length) {
      // yield intermediate result
      yield PathInfo(M, d, p, nodes);
      // find minimal d(j)
      int j = _findMinimal(d, M);
      M.add(j);

      // for all nodes not in M
      for (var k = 0; k < nodes.length; k++) {
        if (M.contains(k)) {
          continue;
        }

        var neighbourCost = d[j] + cost[j][k];

        if (d[k] > neighbourCost) {
          d[k] = neighbourCost;
          p[k] = j;
        }
      }
    }

    // yield final result
    yield PathInfo(M, d, p, nodes);
  }

  int _findMinimal(List<double> d, Set<int> m) {
    double? minValue;
    int? minIndex;

    for (int index = 0; index < d.length; index++) {
      // skip all nodes already in set m
      if (m.contains(index)) {
        continue;
      }

      // set index to index of minimal element
      if (minValue == null || d[index] < minValue) {
        minValue = d[index];
        minIndex = index;
      }
    }

    if (minIndex == null) {
      throw ("no suitable node in set");
    }

    return minIndex;
  }
}

class PathInfo<T> {
  // set of nodes with well known path
  Set<T> M = {};
  // distance from source
  Map<T, double> d = {};
  // predecessors
  Map<T, T?> p = {};

  PathInfo(Set<int> mId, List<double> dId, List<int?> pId, List<T> nodes) {
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (mId.contains(i)) M.add(node);

      d[node] = dId[i];

      var predId = pId[i];
      if (predId != null) {
        p[node] = nodes[predId];
      } else {
        p[node] = null;
      }
    }
  }
}
