import 'package:hive/hive.dart';
import 'cart_item.dart';

part 'order.g.dart';

@HiveType(typeId: 2)
class Order extends HiveObject {
  @HiveField(0)
  final String orderId;

  @HiveField(1)
  final List<CartItem> items;

  @HiveField(2)
  final double total;

  @HiveField(3)
  final DateTime placedAt;

  @HiveField(4)
  String status; // "confirmed", "on_the_way", "delivered"

  @HiveField(5)
  final double deliveryLat;

  @HiveField(6)
  final double deliveryLng;

  Order({
    required this.orderId,
    required this.items,
    required this.total,
    required this.placedAt,
    required this.status,
    required this.deliveryLat,
    required this.deliveryLng,
  });
}