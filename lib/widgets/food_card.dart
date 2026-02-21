import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../providers/cart_provider.dart';

class FoodCard extends StatelessWidget {
  final FoodItem food;

  const FoodCard({super.key, required this.food});

  Color _hexToColor(String hex) {
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final qty = cart.getQuantity(food.id);
        return Container(
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food image (colored placeholder)
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: _hexToColor(food.imagePlaceholder),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Text(
                      _getEmoji(food.category),
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
              ),
              // Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        food.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF1A1A2E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₱${food.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFFE63946),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          if (qty == 0)
                            GestureDetector(
                              onTap: () => cart.addItem(food),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE63946),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.add,
                                  color: CupertinoColors.white,
                                  size: 16,
                                ),
                              ),
                            )
                          else
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => cart.decreaseQuantity(food.id),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.systemGrey5,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(CupertinoIcons.minus, size: 12),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text('$qty',
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                ),
                                GestureDetector(
                                  onTap: () => cart.addItem(food),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE63946),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(CupertinoIcons.add,
                                        size: 12, color: CupertinoColors.white),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getEmoji(String category) {
    switch (category) {
      case 'Burgers': return '🍔';
      case 'Pizza': return '🍕';
      case 'Pasta': return '🍝';
      case 'Salads': return '🥗';
      case 'Seafood': return '🐟';
      case 'Mains': return '🍖';
      case 'Desserts': return '🍰';
      case 'Drinks': return '🥤';
      case 'Sandwiches': return '🥪';
      default: return '🍽️';
    }
  }
}