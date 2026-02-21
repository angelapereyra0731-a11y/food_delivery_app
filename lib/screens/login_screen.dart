import 'package:flutter/cupertino.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';

  void _loginWithCredentials() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter username and password.');
      return;
    }

    if (username == 'admin' && password == '123') {
      _navigateToHome();
    } else {
      setState(() => _errorMessage = 'Invalid username or password.');
    }
  }

  Future<void> _loginWithBiometrics() async {
    final orderProvider = context.read<OrderProvider>();

    if (!orderProvider.biometricEnabled) {
      setState(() => _errorMessage = 'Face ID / Touch ID is disabled in Settings.');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = ''; });

    final canAuth = await _authService.canAuthenticate();
    if (!canAuth) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Biometrics not available on this device.';
      });
      return;
    }

    final success = await _authService.authenticate();
    setState(() => _isLoading = false);

    if (success && mounted) {
      _navigateToHome();
    } else if (mounted) {
      setState(() => _errorMessage = 'Biometric authentication failed. Try again.');
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFE63946),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE63946).withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🍔', style: TextStyle(fontSize: 48)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'QuickBite',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Fast. Fresh. Delivered.',
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 48),

              // Username field
              CupertinoTextField(
                controller: _usernameController,
                placeholder: 'Username',
                placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey),
                style: const TextStyle(color: CupertinoColors.white),
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 14),
                  child: Icon(CupertinoIcons.person_fill,
                      color: CupertinoColors.systemGrey, size: 18),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF0F3460), width: 1.5),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),

              // Password field
              CupertinoTextField(
                controller: _passwordController,
                placeholder: 'Password',
                placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey),
                style: const TextStyle(color: CupertinoColors.white),
                obscureText: _obscurePassword,
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 14),
                  child: Icon(CupertinoIcons.lock_fill,
                      color: CupertinoColors.systemGrey, size: 18),
                ),
                suffix: GestureDetector(
                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Icon(
                      _obscurePassword ? CupertinoIcons.eye_fill : CupertinoIcons.eye_slash_fill,
                      color: CupertinoColors.systemGrey,
                      size: 18,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF0F3460), width: 1.5),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _loginWithCredentials(),
              ),
              const SizedBox(height: 8),

              // Error message
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 4),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: CupertinoColors.systemRed,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16),

              // Login button
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: const Color(0xFFE63946),
                  borderRadius: BorderRadius.circular(14),
                  onPressed: _loginWithCredentials,
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Divider row
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: const Color(0xFF0F3460))),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: TextStyle(color: CupertinoColors.systemGrey)),
                  ),
                  Expanded(child: Container(height: 1, color: const Color(0xFF0F3460))),
                ],
              ),
              const SizedBox(height: 16),

              // Biometric button
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(14),
                  onPressed: _isLoading ? null : _loginWithBiometrics,
                  child: _isLoading
                      ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.lock_shield_fill,
                          color: CupertinoColors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Login with Face ID / Touch ID',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}