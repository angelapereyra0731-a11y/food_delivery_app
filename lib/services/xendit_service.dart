import 'dart:convert';
import 'package:http/http.dart' as http;

class XenditService {
  static const String _testSecretKey =
      'xnd_development_GIn6FTYylHnFDjfGBrshGwk4CYzDlQwu97Hxz2R9z8lVf1lwfb5F1SlhpFhUCoUN';
  static const String _baseUrl = 'https://api.xendit.co';

  static Future<Map<String, dynamic>> createInvoice({
    required double amount,
    required String referenceId,
  }) async {
    try {
      final credentials =
      base64Encode(utf8.encode('$_testSecretKey:'));

      final response = await http.post(
        Uri.parse('$_baseUrl/v2/invoices'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'external_id': referenceId,
          'amount': amount,
          'currency': 'PHP',
          'description': 'QuickBite Food Delivery Order',
          'invoice_duration': 86400,
          'customer': {
            'given_names': 'QuickBite',
            'email': 'customer@quickbite.com',
          },
          'success_redirect_url': 'https://quickbite.com/success',
          'failure_redirect_url': 'https://quickbite.com/failure',
          'payment_methods': ['GCASH', 'MAYA', 'CREDIT_CARD', 'OTC'],
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'invoiceUrl': data['invoice_url'],
          'invoiceId': data['id'],
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Invoice creation failed',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<String> getInvoiceStatus(String invoiceId) async {
    try {
      final credentials =
      base64Encode(utf8.encode('$_testSecretKey:'));

      final response = await http.get(
        Uri.parse('$_baseUrl/v2/invoices/$invoiceId'),
        headers: {'Authorization': 'Basic $credentials'},
      );

      final data = jsonDecode(response.body);
      return data['status'] ?? 'UNKNOWN';
    } catch (e) {
      return 'ERROR';
    }
  }
}