import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../services/database_service.dart';
import '../services/pathfinding_service.dart';

class OrderProvider extends ChangeNotifier {
  Order? _currentOrder;
  List<LatLng> _riderPath = [];
  int _riderPathIndex = 0;
  Timer? _statusTimer;
  Timer? _riderTimer;
  LatLng? _riderPosition;
  bool _biometricEnabled = true;

  Order? get currentOrder => _currentOrder;
  List<LatLng> get riderPath => _riderPath;
  LatLng? get riderPosition => _riderPosition;
  int get riderPathIndex => _riderPathIndex;
  bool get biometricEnabled => _biometricEnabled;

  // Rider starts near BGC Taguig (mock start)
  static const LatLng riderStart = LatLng(14.5547, 121.0499);

  void toggleBiometric(bool value) {
    _biometricEnabled = value;
    notifyListeners();
  }

  Future<void> placeOrder({
    required List<CartItem> items,
    required double total,
    required LatLng deliveryLocation,
  }) async {
    // Cancel any existing timers
    cancelTimers();

    final order = Order(
      orderId: DateTime.now().millisecondsSinceEpoch.toString(),
      items: List.from(items),
      total: total,
      placedAt: DateTime.now(),
      status: 'confirmed',
      deliveryLat: deliveryLocation.latitude,
      deliveryLng: deliveryLocation.longitude,
    );

    await DatabaseService.saveOrder(order);
    _currentOrder = order;

    // Calculate rider path using A*
    final destination = LatLng(order.deliveryLat, order.deliveryLng);
    final rawPath = PathfindingService.findPath(riderStart, destination);
    _riderPath = PathfindingService.interpolatePath(rawPath, 80);
    _riderPathIndex = 0;
    _riderPosition = riderStart;

    notifyListeners();

    // After 1 minute, update status to "on_the_way" and start rider
    _statusTimer = Timer(const Duration(minutes: 1), () async {
      if (_currentOrder != null) {
        _currentOrder!.status = 'on_the_way';
        await DatabaseService.updateOrderStatus(
            _currentOrder!.orderId, 'on_the_way');
        notifyListeners();
        _startRiderMovement();
      }
    });
  }

  void _startRiderMovement() {
    _riderTimer?.cancel();
    // Move rider every 1.5 seconds along the path
    _riderTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (_riderPathIndex < _riderPath.length - 1) {
        _riderPathIndex++;
        _riderPosition = _riderPath[_riderPathIndex];
        notifyListeners();
      } else {
        // Rider arrived
        if (_currentOrder != null) {
          _currentOrder!.status = 'delivered';
          DatabaseService.updateOrderStatus(
              _currentOrder!.orderId, 'delivered');
          notifyListeners();
        }
        timer.cancel();
      }
    });
  }

  // Call this to resume tracking after navigating back
  void resumeTracking() {
    if (_currentOrder?.status == 'on_the_way' &&
        _riderTimer == null &&
        _riderPathIndex < _riderPath.length - 1) {
      _startRiderMovement();
    }
  }

  void logout() {
    cancelTimers();
    _currentOrder = null;
    _riderPath = [];
    _riderPathIndex = 0;
    _riderPosition = null;
    notifyListeners();
  }

  List<Order> getOrderHistory() {
    return DatabaseService.getAllOrders();
  }

  void cancelTimers() {
    _statusTimer?.cancel();
    _riderTimer?.cancel();
    _statusTimer = null;
    _riderTimer = null;
  }

  @override
  void dispose() {
    cancelTimers();
    super.dispose();
  }
}