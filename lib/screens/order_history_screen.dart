import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import 'tracking_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: Color(0xFF1A1A2E),
        middle: Text('Order History',
            style: TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.w700)),
      ),
      child: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          final orders = orderProvider.getOrderHistory();

          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📋', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 16),
                  Text('No orders yet',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemGrey)),
                  Text('Place your first order!',
                      style:
                      TextStyle(color: CupertinoColors.systemGrey2)),
                ],
              ),
            );
          }

          return SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final isActive = order.status == 'confirmed' ||
                    order.status == 'on_the_way';

                final statusColors = {
                  'confirmed': CupertinoColors.systemOrange,
                  'on_the_way': CupertinoColors.systemGreen,
                  'delivered': CupertinoColors.systemGrey,
                };
                final statusLabels = {
                  'confirmed': 'Confirmed',
                  'on_the_way': 'On the Way 🛵',
                  'delivered': 'Delivered ✓',
                };

                return GestureDetector(
                  onTap: isActive
                      ? () {
                    Navigator.of(context, rootNavigator: true)
                        .push(
                      CupertinoPageRoute(
                        builder: (_) => const TrackingScreen(),
                      ),
                    );
                  }
                      : null,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: isActive
                          ? Border.all(
                          color: const Color(0xFFE63946)
                              .withOpacity(0.4),
                          width: 1.5)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color:
                          CupertinoColors.black.withOpacity(0.06),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${order.orderId.substring(order.orderId.length - 6)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (statusColors[order.status] ??
                                    CupertinoColors.systemGrey)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                statusLabels[order.status] ??
                                    order.status,
                                style: TextStyle(
                                  color: statusColors[order.status] ??
                                      CupertinoColors.systemGrey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          order.items
                              .map((i) => i.foodItem.name)
                              .join(', '),
                          style: const TextStyle(
                              color: CupertinoColors.systemGrey,
                              fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${order.placedAt.month}/${order.placedAt.day}/${order.placedAt.year}',
                                  style: const TextStyle(
                                      color: CupertinoColors.systemGrey,
                                      fontSize: 12),
                                ),
                                if (isActive) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                      CupertinoIcons.chevron_right,
                                      size: 12,
                                      color: Color(0xFFE63946)),
                                  const Text('Track',
                                      style: TextStyle(
                                          color: Color(0xFFE63946),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ]
                              ],
                            ),
                            Text(
                              '₱${order.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Color(0xFFE63946),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}