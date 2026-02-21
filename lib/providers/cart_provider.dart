import 'package:flutter/cupertino.dart';
import '../models/food_item.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get total => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  void addItem(FoodItem food) {
    final existingIndex = _items.indexWhere((item) => item.foodItem.id == food.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(foodItem: food));
    }
    notifyListeners();
  }

  void removeItem(String foodId) {
    _items.removeWhere((item) => item.foodItem.id == foodId);
    notifyListeners();
  }

  void decreaseQuantity(String foodId) {
    final index = _items.indexWhere((item) => item.foodItem.id == foodId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  int getQuantity(String foodId) {
    final item = _items.firstWhere(
          (item) => item.foodItem.id == foodId,
      orElse: () => CartItem(foodItem: _items.isEmpty ? CartItem(foodItem: FoodItem(id: '', name: '', description: '', price: 0, category: '', imagePlaceholder: '')).foodItem : _items.first.foodItem),
    );
    return _items.any((i) => i.foodItem.id == foodId)
        ? _items.firstWhere((i) => i.foodItem.id == foodId).quantity
        : 0;
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}