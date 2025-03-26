import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class BackendService {
  static const String _baseUrl = 'YOUR_BACKEND_URL';
  static String? _csrfToken;
  static bool _isInitialized = false;

  // Initialize the backend service
  static Future<void> initialize() async {
    if (kIsWeb) {
      // For web demo, skip backend initialization
      _isInitialized = true;
      return;
    }

    try {
      await _getCsrfToken();
      _isInitialized = true;
    } catch (e) {
      print('Warning: Backend service initialization failed: $e');
      // Still mark as initialized to not block the app
      _isInitialized = true;
    }
  }

  // Get CSRF token from the backend
  static Future<void> _getCsrfToken() async {
    if (kIsWeb) return; // Skip for web demo

    try {
      final response = await http.get(Uri.parse('$_baseUrl/csrf-token'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _csrfToken = data['token'];
      }
    } catch (e) {
      print('Warning: Error getting CSRF token: $e');
    }
  }

  // Create a payment intent
  static Future<Map<String, dynamic>> createPaymentIntent({
    required int amount,
    required String currency,
    required String orderId,
  }) async {
    if (kIsWeb) {
      // Simulate successful payment intent for web demo
      await Future.delayed(const Duration(seconds: 1));
      return {
        'clientSecret': 'demo_secret',
        'status': 'succeeded',
      };
    }

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
        body: json.encode({
          'paymentIntentId': paymentIntentId,
        }),
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
        body: json.encode({
          'orderId': orderId,
        }),
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
        body: json.encode({
          'orderId': orderId,
          'error': error,
        }),
      );
    } catch (e) {
      print('Error handling payment failure: $e');
    }
  }

  // Get order status
  static Future<Map<String, dynamic>> getOrderStatus(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/order-status/$orderId'),
        headers: {
          'X-CSRF-Token': _csrfToken ?? '',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get order status');
      }
    } catch (e) {
      print('Error getting order status: $e');
      rethrow;
    }
  }

  // Get order history
  static Future<List<Map<String, dynamic>>> getOrderHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/order-history'),
        headers: {
          'X-CSRF-Token': _csrfToken ?? '',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['orders']);
      } else {
        throw Exception('Failed to get order history');
      }
    } catch (e) {
      print('Error getting order history: $e');
      rethrow;
    }
  }
}
