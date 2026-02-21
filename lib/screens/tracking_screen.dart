import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  MapController? _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // Resume rider movement if coming back to this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().resumeTracking();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        final order = orderProvider.currentOrder;

        if (order == null) {
          return CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              backgroundColor: Color(0xFF1A1A2E),
              middle: Text('Order Tracking',
                  style: TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.w700)),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📋', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 16),
                  Text('No active order',
                      style: TextStyle(
                          fontSize: 18, color: CupertinoColors.systemGrey)),
                ],
              ),
            ),
          );
        }

        final destination =
        LatLng(order.deliveryLat, order.deliveryLng);
        final riderPos =
            orderProvider.riderPosition ?? OrderProvider.riderStart;
        final path = orderProvider.riderPath;
        final traveled = orderProvider.riderPathIndex < path.length
            ? path.sublist(0, orderProvider.riderPathIndex + 1)
            : path;

        // Auto-center map on rider
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            _mapController?.move(riderPos, 14);
          } catch (_) {}
        });

        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            backgroundColor: const Color(0xFF1A1A2E),
            middle: const Text('Order Tracking',
                style: TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w700)),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(CupertinoIcons.back,
                  color: CupertinoColors.white),
            ),
          ),
          child: Column(
            children: [
              _buildStatusBanner(order.status),
              Expanded(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: riderPos,
                    initialZoom: 14,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                      'com.yourname.food_delivery_app',
                    ),
                    // Full planned route (grey)
                    if (path.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: path,
                            color: CupertinoColors.systemGrey
                                .withOpacity(0.35),
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                    // Traveled route (green)
                    if (traveled.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: traveled,
                            color: const Color(0xFF00C853),
                            strokeWidth: 5,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        // Rider marker
                        Marker(
                          point: riderPos,
                          width: 52,
                          height: 52,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A2E),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: CupertinoColors.black
                                      .withOpacity(0.3),
                                  blurRadius: 6,
                                )
                              ],
                            ),
                            child: const Center(
                              child: Text('🛵',
                                  style: TextStyle(fontSize: 24)),
                            ),
                          ),
                        ),
                        // Destination marker
                        Marker(
                          point: destination,
                          width: 52,
                          height: 60,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE63946),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                    CupertinoIcons.house_fill,
                                    color: CupertinoColors.white,
                                    size: 18),
                              ),
                              Container(
                                  width: 2,
                                  height: 10,
                                  color: const Color(0xFFE63946)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildBottomInfo(order),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBanner(String status) {
    final configs = {
      'confirmed': {
        'color': const Color(0xFF1A1A2E),
        'icon': CupertinoIcons.checkmark_circle_fill,
        'text': 'Order Confirmed',
        'sub': 'Preparing your food... rider coming in 1 min',
      },
      'on_the_way': {
        'color': const Color(0xFF2D6A4F),
        'icon': CupertinoIcons.location_fill,
        'text': 'Delivery is on the way! 🛵',
        'sub': 'Watch your rider move on the map',
      },
      'delivered': {
        'color': const Color(0xFF457B9D),
        'icon': CupertinoIcons.hand_thumbsup_fill,
        'text': 'Delivered!',
        'sub': 'Enjoy your meal! 🍽️',
      },
    };

    final config = configs[status] ?? configs['confirmed']!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: config['color'] as Color,
      child: Row(
        children: [
          Icon(config['icon'] as IconData,
              color: CupertinoColors.white, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(config['text'] as String,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  )),
              Text(config['sub'] as String,
                  style: TextStyle(
                    color: CupertinoColors.white.withOpacity(0.75),
                    fontSize: 12,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfo(Order order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        boxShadow: [
          BoxShadow(color: Color(0x1A000000), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🛵', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Juan Dela Cruz',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              Text('Your delivery rider',
                  style: TextStyle(
                      color: CupertinoColors.systemGrey, fontSize: 12)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₱${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFFE63946),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  )),
              const Text('Total',
                  style: TextStyle(
                      color: CupertinoColors.systemGrey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}