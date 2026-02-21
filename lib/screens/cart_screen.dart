import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'location_picker_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFF1A1A2E),
        middle: const Text('My Cart',
            style: TextStyle(
              color: CupertinoColors.white,
              fontWeight: FontWeight.w700,
            )),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.white),
        ),
      ),
      child: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🛒', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 16),
                  Text('Your cart is empty',
                      style: TextStyle(fontSize: 18, color: CupertinoColors.systemGrey,
                          fontWeight: FontWeight.w600)),
                  Text('Add some delicious items!',
                      style: TextStyle(color: CupertinoColors.systemGrey2)),
                ],
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.black.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.foodItem.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1A1A2E))),
                                  Text('₱${item.foodItem.price.toStringAsFixed(0)} each',
                                      style: const TextStyle(
                                          color: CupertinoColors.systemGrey,
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => cart.decreaseQuantity(item.foodItem.id),
                                  child: Container(
                                    width: 30, height: 30,
                                    decoration: BoxDecoration(
                                        color: CupertinoColors.systemGrey5,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(CupertinoIcons.minus, size: 14),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('${item.quantity}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700, fontSize: 16)),
                                ),
                                GestureDetector(
                                  onTap: () => cart.addItem(item.foodItem),
                                  child: Container(
                                    width: 30, height: 30,
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFE63946),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(CupertinoIcons.add,
                                        size: 14, color: CupertinoColors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Text('₱${item.subtotal.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFE63946),
                                    fontSize: 15)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 12)],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          Text('₱${cart.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFE63946))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          color: const Color(0xFFE63946),
                          borderRadius: BorderRadius.circular(14),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).push(
                              CupertinoPageRoute(
                                builder: (_) => const LocationPickerScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Proceed to Checkout',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}