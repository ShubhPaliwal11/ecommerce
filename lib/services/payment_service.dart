import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  // Use localhost for web, 10.0.2.2 for Android emulator, and IPv4 address as fallback
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3001';
    } else {
      // Android emulator uses 10.0.2.2 to access host machine
      // Real devices need actual IP address
      return 'http://10.0.2.2:3001';
    }
  }

  // Public method to get base URL for external use
  static String getBaseUrl() {
    return _baseUrl;
  }

  static String? _csrfToken;
  static bool _csrfVerified = false;
  static int _maxRetries = 3;

  // Initialize the payment service
  static Future<void> initialize() async {
    await _getCsrfTokenWithRetry();
  }

  // Get CSRF token with retry mechanism
  static Future<void> _getCsrfTokenWithRetry() async {
    int attempts = 0;
    while (attempts < _maxRetries) {
      try {
        await _getCsrfToken();
        if (_csrfToken != null) {
          print(
              'CSRF Token obtained successfully after ${attempts + 1} attempts');
          return;
        }
      } catch (e) {
        print('Attempt ${attempts + 1} failed: $e');
      }
      attempts++;
      if (attempts < _maxRetries) {
        // Wait before retrying
        await Future.delayed(Duration(seconds: 1));
      }
    }
    print('Failed to get CSRF token after $_maxRetries attempts');
  }

  // Get CSRF token from the backend
  static Future<void> _getCsrfToken() async {
    try {
      print('Attempting to connect to server: $_baseUrl/csrf-token');
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
      print(
          'Starting payment intent creation with amount: $amount, currency: $currency, orderId: $orderId');

      if (_csrfToken == null) {
        print('CSRF token is null, attempting to get it');
        await _getCsrfToken();
        if (_csrfToken == null) {
          print(
              'Failed to get CSRF token, generating a fallback payment intent');
          // Return a fallback payment intent that allows Razorpay to be opened
          return {
            'id': 'order_${DateTime.now().millisecondsSinceEpoch}',
            'amount': amount,
            'currency': currency,
            'status': 'created',
            'key': 'rzp_test_47mpRvV2Yh9XLZ'
          };
        }
      }

      print(
          'Sending request to $_baseUrl/create-payment-intent with CSRF token: $_csrfToken');

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

      print('Received response with status code: ${response.statusCode}');
      print('Response body: ${response.body}');

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

      // Return a fallback payment intent for testing purposes
      print('Generating fallback payment intent due to error');
      return {
        'id': 'order_${DateTime.now().millisecondsSinceEpoch}',
        'amount': amount,
        'currency': currency,
        'status': 'created',
        'key': 'rzp_test_47mpRvV2Yh9XLZ'
      };
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
        'contact': '9999999999', // Add a default contact number
        'email': email,
        'name': name,
      },
      'external': {
        'wallets': ['paytm']
      },
      'theme': {'color': '#3399cc'},
      'send_sms_hash': true,
      'remember_customer': false,
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
      if (response.orderId == null ||
          response.paymentId == null ||
          response.signature == null) {
        print('Error: Missing required fields in payment success response');
        return;
      }

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

    String errorDesc = "";
    switch (response.code) {
      case 1:
        errorDesc = "Payment processing cancelled by user";
        break;
      case 2:
        errorDesc = "Payment processing failed";
        break;
      default:
        errorDesc = "Unknown error occurred";
        break;
    }

    print(
        'Razorpay payment error: Code: ${response.code}, Message: ${response.message}, Description: $errorDesc');
  }

  // Handle Razorpay external wallet
  static void handleExternalWallet(
      ExternalWalletResponse response, String orderId) {
    if (kIsWeb) return; // Skip on web platform
    print('Razorpay external wallet selected: ${response.walletName}');
  }
}
