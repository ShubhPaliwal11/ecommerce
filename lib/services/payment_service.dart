import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  // Use localhost for web, 10.0.2.2 for Android emulator
  static String get _baseUrl =>
      kIsWeb ? 'http://localhost:3001' : 'http://10.0.2.2:3001';
  static String? _csrfToken;
  static bool _csrfVerified = false;

  // Initialize the payment service
  static Future<void> initialize() async {
    await _getCsrfToken();
  }

  // Get CSRF token from the backend
  static Future<void> _getCsrfToken() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/csrf-token'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _csrfToken = data['csrfToken'];
        print('CSRF Token fetched successfully: $_csrfToken');
      } else {
        print('Failed to fetch CSRF token: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting CSRF token: $e');
    }
  }

  // Check if CSRF token is verified
  static bool get isCsrfVerified => _csrfVerified;

  // Create a Razorpay order
  static Future<Map<String, dynamic>> createPaymentIntent({
    required int amount,
    required String currency,
    required String orderId,
  }) async {
    try {
      if (_csrfToken == null) {
        await _getCsrfToken();
      }

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
        _csrfVerified = true; // CSRF token was accepted
        final data = json.decode(response.body);
        print('Payment intent created successfully: $data');
        return data;
      } else if (response.statusCode == 403) {
        print('CSRF verification failed');
        throw Exception('Security verification failed. Please try again.');
      } else {
        print('Failed to create payment intent: ${response.statusCode}');
        throw Exception('Failed to create payment intent');
      }
    } catch (e) {
      print('Error creating payment intent: $e');
      rethrow;
    }
  }

  // Configure Razorpay instance with order details
  static Map<String, dynamic> getRazorpayOptions({
    required String orderId,
    required String razorpayOrderId,
    required int amount,
    required String currency,
    required String name,
    required String email,
    required String description,
  }) {
    return {
      'key': 'rzp_test_47mpRvV2Yh9XLZ', // Use your Razorpay key
      'amount': amount,
      'name': 'Your Store',
      'order_id': razorpayOrderId,
      'description': description,
      'prefill': {
        'contact': '',
        'email': email,
        'name': name,
      },
      'external': {
        'wallets': ['paytm']
      }
    };
  }

  // Confirm Razorpay payment with CSRF verification
  static Future<Map<String, dynamic>> confirmOrder({
    required String orderId,
    required String paymentIntentId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/confirm-order'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': _csrfToken ?? '',
        },
        body: json.encode({
          'orderId': orderId,
          'paymentIntentId': paymentIntentId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Order confirmed successfully: $data');
        return data;
      } else {
        print('Failed to confirm order: ${response.statusCode}');
        throw Exception('Failed to confirm order');
      }
    } catch (e) {
      print('Error confirming order: $e');
      rethrow;
    }
  }

  // The following methods are only used on mobile platforms
  // Handle Razorpay payment success
  static void handlePaymentSuccess(
      PaymentSuccessResponse response, String orderId) async {
    if (kIsWeb) return; // Skip on web platform

    try {
      final confirmResponse = await confirmOrder(
        orderId: orderId,
        paymentIntentId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      );

      print('Payment confirmed: $confirmResponse');
    } catch (e) {
      print('Error handling payment success: $e');
    }
  }

  // Handle Razorpay payment error
  static void handlePaymentError(
      PaymentFailureResponse response, String orderId) {
    if (kIsWeb) return; // Skip on web platform
    print('Payment error: ${response.code} - ${response.message}');
  }

  // Handle Razorpay external wallet
  static void handleExternalWallet(
      ExternalWalletResponse response, String orderId) {
    if (kIsWeb) return; // Skip on web platform
    print('External wallet selected: ${response.walletName}');
  }
}
