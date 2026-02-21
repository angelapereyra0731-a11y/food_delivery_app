import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';

class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canAuthenticate() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return isSupported || canCheck;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final canAuth = await canAuthenticate();
      if (!canAuth) return false;

      return await _auth.authenticate(
        localizedReason: 'Scan your fingerprint or face to log in',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // false = allows PIN fallback
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      // NotAvailable, NotEnrolled, LockedOut etc.
      if (e.code == auth_error.notAvailable ||
          e.code == auth_error.notEnrolled ||
          e.code == auth_error.passcodeNotSet) {
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
}