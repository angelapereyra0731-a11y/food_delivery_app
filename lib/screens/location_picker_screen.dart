import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'payment_screen.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng _pinnedLocation = const LatLng(14.5547, 121.0244);
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFF1A1A2E),
        middle: const Text(
          'Pin Delivery Location',
          style: TextStyle(
              color: CupertinoColors.white, fontWeight: FontWeight.w700),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.white),
        ),
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pinnedLocation,
              initialZoom: 15,
              onTap: (tapPosition, point) {
                setState(() => _pinnedLocation = point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yourname.food_delivery_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pinnedLocation,
                    width: 50,
                    height: 65,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE63946),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE63946)
                                    .withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            CupertinoIcons.location_fill,
                            color: CupertinoColors.white,
                            size: 20,
                          ),
                        ),
                        CustomPaint(
                          size: const Size(2, 12),
                          painter: _PinLinePainter(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Top instruction banner
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E).withOpacity(0.92),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(CupertinoIcons.hand_point_right_fill,
                      color: CupertinoColors.white, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tap anywhere on the map to pin your delivery location',
                      style: TextStyle(
                          color: CupertinoColors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Current coordinates display
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.1),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.location_circle,
                      color: Color(0xFFE63946), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Lat: ${_pinnedLocation.latitude.toStringAsFixed(4)}, '
                        'Lng: ${_pinnedLocation.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confirm button
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: CupertinoButton(
              color: const Color(0xFFE63946),
              borderRadius: BorderRadius.circular(14),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) =>
                        PaymentScreen(deliveryLocation: _pinnedLocation),
                  ),
                );
              },
              child: const Text(
                'Confirm Location & Pay',
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
    );
  }
}

// Custom painter for the pin stem line
class _PinLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE63946)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}