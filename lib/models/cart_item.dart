import 'package:hive/hive.dart';
import 'food_item.dart';

part 'cart_item.g.dart';

@HiveType(typeId: 1)
class CartItem extends HiveObject {
  @HiveField(0)
  final FoodItem foodItem;

  @HiveField(1)
  int quantity;

  CartItem({required this.foodItem, this.quantity = 1});

  double get subtotal => foodItem.price * quantity;
}