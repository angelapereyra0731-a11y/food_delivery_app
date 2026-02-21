import 'dart:math';
import 'package:latlong2/latlong.dart';

class PathNode {
  final LatLng position;
  double gCost; // cost from start
  double hCost; // heuristic cost to end
  PathNode? parent;

  PathNode({
    required this.position,
    this.gCost = 0,
    this.hCost = 0,
    this.parent,
  });

  double get fCost => gCost + hCost;
}

class PathfindingService {
  /// Generate a grid of waypoints between two LatLng points
  /// and use A* to find the most efficient path.
  /// For simulation purposes, we create a grid of intermediate points.
  static List<LatLng> findPath(LatLng start, LatLng end) {
    // Generate a realistic-looking path with waypoints
    // We simulate road-like movement by adding intermediate grid points
    final List<LatLng> waypoints = _generateGridWaypoints(start, end);
    return _aStar(start, end, waypoints);
  }

  static List<LatLng> _generateGridWaypoints(LatLng start, LatLng end) {
    final List<LatLng> points = [];

    // Create a grid of points in the area between start and end
    final double minLat = min(start.latitude, end.latitude) - 0.005;
    final double maxLat = max(start.latitude, end.latitude) + 0.005;
    final double minLng = min(start.longitude, end.longitude) - 0.005;
    final double maxLng = max(start.longitude, end.longitude) + 0.005;

    const int gridSize = 10;
    for (int i = 0; i <= gridSize; i++) {
      for (int j = 0; j <= gridSize; j++) {
        final double lat = minLat + (maxLat - minLat) * i / gridSize;
        final double lng = minLng + (maxLng - minLng) * j / gridSize;
        points.add(LatLng(lat, lng));
      }
    }
    return points;
  }

  static List<LatLng> _aStar(LatLng start, LatLng end, List<LatLng> grid) {
    final openList = <PathNode>[];
    final closedSet = <String>{};

    final startNode = PathNode(
      position: start,
      gCost: 0,
      hCost: _distance(start, end),
    );
    openList.add(startNode);

    PathNode? bestNode;
    double bestDist = double.infinity;

    int iterations = 0;
    while (openList.isNotEmpty && iterations < 500) {
      iterations++;
      // Sort by fCost
      openList.sort((a, b) => a.fCost.compareTo(b.fCost));
      final current = openList.removeAt(0);

      final key = '${current.position.latitude.toStringAsFixed(5)},${current.position.longitude.toStringAsFixed(5)}';
      closedSet.add(key);

      final dist = _distance(current.position, end);
      if (dist < bestDist) {
        bestDist = dist;
        bestNode = current;
      }

      if (dist < 0.001) break; // Close enough to destination

      // Find neighbors from grid
      final neighbors = _getNeighbors(current.position, grid);
      for (final neighborPos in neighbors) {
        final neighborKey = '${neighborPos.latitude.toStringAsFixed(5)},${neighborPos.longitude.toStringAsFixed(5)}';
        if (closedSet.contains(neighborKey)) continue;

        final gCost = current.gCost + _distance(current.position, neighborPos);
        final hCost = _distance(neighborPos, end);
        final neighbor = PathNode(
          position: neighborPos,
          gCost: gCost,
          hCost: hCost,
          parent: current,
        );
        openList.add(neighbor);
      }
    }

    // Reconstruct path
    final path = <LatLng>[];
    PathNode? node = bestNode;
    while (node != null) {
      path.insert(0, node.position);
      node = node.parent;
    }
    path.add(end);
    return path;
  }

  static List<LatLng> _getNeighbors(LatLng pos, List<LatLng> grid) {
    final neighbors = <LatLng>[];
    const double maxDist = 0.008;
    for (final point in grid) {
      final d = _distance(pos, point);
      if (d > 0 && d <= maxDist) {
        neighbors.add(point);
      }
    }
    // Limit to 4 nearest
    neighbors.sort((a, b) => _distance(pos, a).compareTo(_distance(pos, b)));
    return neighbors.take(4).toList();
  }

  static double _distance(LatLng a, LatLng b) {
    final dLat = a.latitude - b.latitude;
    final dLng = a.longitude - b.longitude;
    return sqrt(dLat * dLat + dLng * dLng);
  }

  /// Interpolate points along the path for smooth animation
  static List<LatLng> interpolatePath(List<LatLng> path, int steps) {
    if (path.isEmpty) return [];
    final result = <LatLng>[];
    final totalSegments = path.length - 1;
    if (totalSegments == 0) return path;

    final stepsPerSegment = (steps / totalSegments).ceil();
    for (int i = 0; i < totalSegments; i++) {
      for (int j = 0; j < stepsPerSegment; j++) {
        final t = j / stepsPerSegment;
        final lat = path[i].latitude + (path[i + 1].latitude - path[i].latitude) * t;
        final lng = path[i].longitude + (path[i + 1].longitude - path[i].longitude) * t;
        result.add(LatLng(lat, lng));
      }
    }
    result.add(path.last);
    return result;
  }
}