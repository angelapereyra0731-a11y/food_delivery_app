import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        return CupertinoPageScaffold(
          backgroundColor: const Color(0xFFF0F0F5),
          navigationBar: const CupertinoNavigationBar(
            backgroundColor: Color(0xFF1A1A2E),
            middle: Text('Settings',
                style: TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w700)),
          ),
          child: SafeArea(
            child: ListView(
              children: [
                const SizedBox(height: 24),

                // Section header
                const Padding(
                  padding: EdgeInsets.only(left: 20, bottom: 8),
                  child: Text('SECURITY',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemGrey,
                          letterSpacing: 1)),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      // Face ID / Touch ID toggle
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A2E),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                  CupertinoIcons.lock_shield_fill,
                                  color: CupertinoColors.white,
                                  size: 18),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Face ID / Touch ID',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15)),
                                  Text('Use biometrics to log in',
                                      style: TextStyle(
                                          color: CupertinoColors.systemGrey,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                            CupertinoSwitch(
                              value: orderProvider.biometricEnabled,
                              activeColor: const Color(0xFFE63946),
                              onChanged: (val) =>
                                  orderProvider.toggleBiometric(val),
                            ),
                          ],
                        ),
                      ),
                      Container(
                          height: 0.5,
                          margin: const EdgeInsets.only(left: 66),
                          color: CupertinoColors.systemGrey5),
                      // Change PIN placeholder
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF457B9D),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(CupertinoIcons.person_crop_circle_fill,
                                  color: CupertinoColors.white, size: 18),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Account',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15)),
                                  Text('admin',
                                      style: TextStyle(
                                          color: CupertinoColors.systemGrey,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                            const Icon(CupertinoIcons.chevron_right,
                                color: CupertinoColors.systemGrey, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // App info section
                const Padding(
                  padding: EdgeInsets.only(left: 20, bottom: 8),
                  child: Text('APP',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemGrey,
                          letterSpacing: 1)),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE63946),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text('🍔', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('QuickBite',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                              Text('Version 1.0.0',
                                  style: TextStyle(
                                      color: CupertinoColors.systemGrey,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Logout button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CupertinoButton(
                    color: const Color(0xFFE63946),
                    borderRadius: BorderRadius.circular(14),
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (ctx) => CupertinoAlertDialog(
                          title: const Text('Log Out'),
                          content: const Text(
                              'Are you sure you want to log out?'),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('Cancel'),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                            CupertinoDialogAction(
                              isDestructiveAction: true,
                              child: const Text('Log Out'),
                              onPressed: () {
                                orderProvider.logout();
                                Navigator.of(ctx).pop();
                                Navigator.of(context, rootNavigator: true)
                                    .pushAndRemoveUntil(
                                  CupertinoPageRoute(
                                      builder: (_) => const LoginScreen()),
                                      (route) => false,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.square_arrow_left_fill,
                            color: CupertinoColors.white),
                        SizedBox(width: 10),
                        Text('Log Out',
                            style: TextStyle(
                                color: CupertinoColors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}