import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentService {
  static const String _baseUrl = 'YOUR_BACKEND_URL';
  static String? _csrfToken;

  // Initialize the payment service
  static Future<void> initialize() async {
    await _getCsrfToken();
  }

  // Get CSRF token from the backend
  static Future<void> _getCsrfToken() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/csrf-token'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _csrfToken = data['token'];
      }
    } catch (e) {
      print('Error getting CSRF token: $e');
    }
  }

  // Create a payment intent
  static Future<Map<String, dynamic>> createPaymentIntent({
    required int amount,
    required String currency,
    required String orderId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/create-payment-intent'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': _csrfToken ?? '',
        },
        body: json.encode({
          'amount': amount,
          'currency': currency,
          'orderId': orderId,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create payment intent');
      }
    } catch (e) {
      print('Error creating payment intent: $e');
      rethrow;
    }
  }

  // Confirm payment
  static Future<bool> confirmPayment(String paymentIntentId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/confirm-payment'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': _csrfToken ?? '',
        },
        body: json.encode({'paymentIntentId': paymentIntentId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error confirming payment: $e');
      return false;
    }
  }

  // Handle payment success
  static Future<void> handlePaymentSuccess(String orderId) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/payment-success'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': _csrfToken ?? '',
        },
        body: json.encode({'orderId': orderId}),
      );
    } catch (e) {
      print('Error handling payment success: $e');
    }
  }

  // Handle payment failure
  static Future<void> handlePaymentFailure(String orderId, String error) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/payment-failure'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': _csrfToken ?? '',
        },
        body: json.encode({'orderId': orderId, 'error': error}),
      );
    } catch (e) {
      print('Error handling payment failure: $e');
    }
  }
}
