import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../services/xendit_service.dart';
import '../services/auth_service.dart';
import 'tracking_screen.dart';

class PaymentScreen extends StatefulWidget {
  final LatLng deliveryLocation;
  const PaymentScreen({super.key, required this.deliveryLocation});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _currentStep = 0; // 0=review, 1=processing, 2=webview, 3=success, 4=failed
  bool _isProcessing = false;
  String _statusMessage = '';
  String _invoiceId = '';
  String _invoiceUrl = '';
  Timer? _pollTimer;
  final AuthService _authService = AuthService();
  InAppWebViewController? _webViewController;

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFF0A2540),
        middle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF00B9A8),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text('XENDIT',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1.5,
                  )),
            ),
            const SizedBox(width: 8),
            const Text('Checkout',
                style: TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
          ],
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back,
              color: CupertinoColors.white),
        ),
        trailing: const Icon(CupertinoIcons.lock_fill,
            color: Color(0xFF00B9A8), size: 18),
      ),
      child: SafeArea(child: _buildCurrentStep(cart)),
    );
  }

  Widget _buildCurrentStep(CartProvider cart) {
    switch (_currentStep) {
      case 1:
        return _buildProcessingStep();
      case 2:
        return _buildWebViewStep();
      case 3:
        return _buildSuccessStep();
      case 4:
        return _buildFailedStep();
      default:
        return _buildOrderReview(cart);
    }
  }

  // ─── Order Review ──────────────────────────────────────────────────────────
  Widget _buildOrderReview(CartProvider cart) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A2540), Color(0xFF16437E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0A2540).withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE63946),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('🍔',
                          style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('QuickBite',
                            style: TextStyle(
                                color: CupertinoColors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16)),
                        Text('Food Delivery',
                            style: TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontSize: 11)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                        const Color(0xFF00B9A8).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(CupertinoIcons.lock_fill,
                              color: Color(0xFF00B9A8), size: 11),
                          SizedBox(width: 4),
                          Text('SECURE',
                              style: TextStyle(
                                  color: Color(0xFF00B9A8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('AMOUNT TO PAY',
                    style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 11,
                        letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text(
                  '₱${cart.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                    height: 1,
                    color: CupertinoColors.white.withOpacity(0.1)),
                const SizedBox(height: 14),
                ...cart.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.foodItem.name} ×${item.quantity}',
                        style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 13),
                      ),
                      Text(
                        '₱${item.subtotal.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Biometric auth card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFF00B9A8).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(CupertinoIcons.lock_shield_fill,
                        color: Color(0xFF00B9A8), size: 20),
                    SizedBox(width: 10),
                    Text('Biometric Authorization Required',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF0A2540))),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Authenticate with Face ID or fingerprint to open the Xendit payment page.',
                  style: TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 13,
                      height: 1.5),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _biometricBadge(
                        CupertinoIcons.person_crop_circle, 'Face ID'),
                    const SizedBox(width: 20),
                    _biometricBadge(
                        CupertinoIcons.hand_raised_fill, 'Touch ID'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Pay button
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: const Color(0xFF00B9A8),
              borderRadius: BorderRadius.circular(16),
              onPressed:
              _isProcessing ? null : () => _authenticateAndPay(cart),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.lock_shield_fill,
                      color: CupertinoColors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Authenticate & Pay ₱${cart.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.lock_fill,
                  color: CupertinoColors.systemGrey, size: 12),
              SizedBox(width: 4),
              Text('256-bit SSL · Secured by Xendit',
                  style: TextStyle(
                      color: CupertinoColors.systemGrey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _biometricBadge(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF00B9A8).withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
                color: const Color(0xFF00B9A8).withOpacity(0.3),
                width: 1.5),
          ),
          child: Icon(icon, color: const Color(0xFF00B9A8), size: 24),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: CupertinoColors.systemGrey,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ─── Processing ────────────────────────────────────────────────────────────
  Widget _buildProcessingStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF00B9A8).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CupertinoActivityIndicator(
                    radius: 22, color: Color(0xFF00B9A8)),
              ),
            ),
            const SizedBox(height: 28),
            const Text('Creating Invoice...',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0A2540))),
            const SizedBox(height: 10),
            Text(
              _statusMessage.isEmpty
                  ? 'Connecting to Xendit...'
                  : _statusMessage,
              style: const TextStyle(
                  color: CupertinoColors.systemGrey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── WebView (Xendit Invoice Page) ─────────────────────────────────────────
  Widget _buildWebViewStep() {
    return Column(
      children: [
        // Mini top bar
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: const Color(0xFF0A2540),
          child: Row(
            children: [
              const Icon(CupertinoIcons.lock_fill,
                  color: Color(0xFF00B9A8), size: 14),
              const SizedBox(width: 6),
              const Text('api.xendit.co — Secure Payment',
                  style: TextStyle(
                      color: CupertinoColors.systemGrey, fontSize: 12)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _currentStep = 4),
                child: const Text('Cancel',
                    style: TextStyle(
                        color: Color(0xFFE63946),
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        Expanded(
          child: InAppWebView(
            initialUrlRequest:
            URLRequest(url: WebUri(_invoiceUrl)),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStop: (controller, url) {
              // Check if redirected to success/failure URL
              final urlStr = url.toString();
              if (urlStr.contains('success')) {
                _onPaymentSuccess();
              } else if (urlStr.contains('failure') ||
                  urlStr.contains('cancel')) {
                setState(() {
                  _currentStep = 4;
                  _statusMessage = 'Payment was cancelled.';
                });
              }
            },
          ),
        ),
      ],
    );
  }

  // ─── Success ───────────────────────────────────────────────────────────────
  Widget _buildSuccessStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF00B9A8).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                  child: Text('✅', style: TextStyle(fontSize: 52))),
            ),
            const SizedBox(height: 24),
            const Text('Payment Confirmed!',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0A2540))),
            const SizedBox(height: 10),
            const Text(
              'Your payment was verified.\nYour order is now being prepared!',
              style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 14,
                  height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: const Color(0xFFE63946),
                borderRadius: BorderRadius.circular(14),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true)
                      .pushAndRemoveUntil(
                    CupertinoPageRoute(
                        builder: (_) => const TrackingScreen()),
                        (route) => route.isFirst,
                  );
                },
                child: const Text('Track My Order 🛵',
                    style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Failed ────────────────────────────────────────────────────────────────
  Widget _buildFailedStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('❌', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            const Text('Payment Failed',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0A2540))),
            const SizedBox(height: 10),
            Text(
              _statusMessage.isEmpty
                  ? 'Something went wrong. Please try again.'
                  : _statusMessage,
              style: const TextStyle(
                  color: CupertinoColors.systemGrey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: const Color(0xFF00B9A8),
                borderRadius: BorderRadius.circular(14),
                onPressed: () => setState(() {
                  _currentStep = 0;
                  _statusMessage = '';
                }),
                child: const Text('Try Again',
                    style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Logic ─────────────────────────────────────────────────────────────────
  Future<void> _authenticateAndPay(CartProvider cart) async {
    setState(() => _isProcessing = true);

    final canAuth = await _authService.canAuthenticate();

    if (canAuth) {
      final authenticated = await _authService.authenticate();
      if (!mounted) return;

      if (!authenticated) {
        setState(() => _isProcessing = false);
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Authentication Failed'),
            content: const Text(
                'Biometric authentication is required to proceed with payment.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        );
        return;
      }
    }

    // Biometric passed — create Xendit invoice
    setState(() {
      _currentStep = 1;
      _statusMessage = 'Creating your invoice...';
    });

    final referenceId = 'QB_${DateTime.now().millisecondsSinceEpoch}';

    final result = await XenditService.createInvoice(
      amount: cart.total,
      referenceId: referenceId,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      _invoiceUrl = result['invoiceUrl'];
      _invoiceId = result['invoiceId'];

      setState(() {
        _currentStep = 2; // Open WebView
        _isProcessing = false;
      });

      // Start polling invoice status in background
      _startPolling(cart);
    } else {
      setState(() {
        _isProcessing = false;
        _currentStep = 4;
        _statusMessage =
            result['error'] ?? 'Failed to create invoice.';
      });
    }
  }

  void _startPolling(CartProvider cart) {
    int attempts = 0;
    _pollTimer =
        Timer.periodic(const Duration(seconds: 4), (timer) async {
          attempts++;
          if (!mounted) {
            timer.cancel();
            return;
          }

          final status =
          await XenditService.getInvoiceStatus(_invoiceId);

          if (status == 'PAID' || status == 'SETTLED') {
            timer.cancel();
            _onPaymentSuccess();
          } else if (status == 'EXPIRED') {
            timer.cancel();
            if (mounted) {
              setState(() {
                _currentStep = 4;
                _statusMessage = 'Invoice expired. Please try again.';
              });
            }
          }

          if (attempts >= 150) timer.cancel(); // 10 min timeout
        });
  }

  Future<void> _onPaymentSuccess() async {
    _pollTimer?.cancel();
    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    await orderProvider.placeOrder(
      items: cart.items.toList(),
      total: cart.total,
      deliveryLocation: widget.deliveryLocation,
    );
    cart.clear();

    if (mounted) {
      setState(() {
        _currentStep = 3;
        _isProcessing = false;
      });
    }
  }
}