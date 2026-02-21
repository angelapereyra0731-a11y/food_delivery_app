import 'package:hive_flutter/hive_flutter.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';

class DatabaseService {
  static const String ordersBox = 'orders';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(FoodItemAdapter());
    Hive.registerAdapter(CartItemAdapter());
    Hive.registerAdapter(OrderAdapter());

    await Hive.openBox<Order>(ordersBox);
  }

  static Future<void> saveOrder(Order order) async {
    final box = Hive.box<Order>(ordersBox);
    await box.put(order.orderId, order);
  }

  static List<Order> getAllOrders() {
    final box = Hive.box<Order>(ordersBox);
    return box.values.toList()
      ..sort((a, b) => b.placedAt.compareTo(a.placedAt));
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    final box = Hive.box<Order>(ordersBox);
    final order = box.get(orderId);
    if (order != null) {
      order.status = status;
      await order.save();
    }
  }
}