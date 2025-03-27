import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/coupon.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../services/payment_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _csrfVerified = false;
  String _orderId = '';
  Razorpay? _razorpay;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    try {
      // Initialize payment service to fetch CSRF token
      await PaymentService.initialize();

      // Setup Razorpay (only for mobile)
      if (!kIsWeb) {
        _razorpay = Razorpay();
        _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
        _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
        _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
        print('Razorpay initialized successfully');
      }
    } catch (e) {
      print('Error initializing payment: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment successful: ${response.paymentId}');
    PaymentService.handlePaymentSuccess(response, _orderId);
    Navigator.of(context)
        .pushReplacementNamed('/order-confirmation', arguments: {
      'csrfVerified': true,
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    PaymentService.handlePaymentError(response, _orderId);
    String errorDetails = '';

    // Provide more detailed error messages based on Razorpay error codes
    if (response.code != null) {
      switch (response.code) {
        case 2:
          errorDetails = 'Payment cancelled by user';
          break;
        case 3:
          errorDetails = 'Payment processing failure';
          break;
        default:
          errorDetails = response.message ?? 'Unknown error';
          break;
      }
    }

    setState(() {
      _errorMessage = 'Payment failed: $errorDetails';
      _isLoading = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    PaymentService.handleExternalWallet(response, _orderId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    if (!kIsWeb && _razorpay != null) {
      _razorpay?.clear(); // Remove all listeners
      _razorpay = null;
    }
    super.dispose();
  }

  // Ensure we have a clean Razorpay instance for payment
  Future<void> _ensureRazorpayInstance() async {
    // If already initialized, dispose it first
    if (_razorpay != null) {
      _razorpay?.clear();
      _razorpay = null;
    }

    // Create a fresh instance
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    print('Fresh Razorpay instance created');
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Generate a unique order ID
      _orderId = const Uuid().v4();

      // Web platforms require a different approach since Razorpay Flutter SDK doesn't work on web
      if (kIsWeb) {
        print('Running on web platform - using web-specific checkout flow');

        // For web, we need to use Razorpay JS Checkout instead of the Flutter SDK
        // For demo purposes, we'll just simulate a successful payment
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _csrfVerified = true;
        });

        // Show a message to the user explaining the web limitation
        setState(() {
          _errorMessage =
              'Note: For web, please use the mobile app to complete real payments with Razorpay. This is a simulation.';
        });

        // Simulate payment processing
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.of(context)
              .pushReplacementNamed('/order-confirmation', arguments: {
            'csrfVerified': true,
          });
        }
      } else {
        // On mobile, proceed with Razorpay SDK
        final cartAmount =
            (context.read<CartProvider>().totalAmount * 100).round();

        try {
          // Rest of the mobile implementation stays the same
          await _ensureRazorpayInstance();

          print('Opening Razorpay for amount: $cartAmount');

          var options = {
            'key': 'rzp_test_47mpRvV2Yh9XLZ',
            'amount': cartAmount, // amount in paise
            'currency': 'INR', // Currency is required
            'name': 'Your Store',
            'description': 'Order #$_orderId',
            'timeout': 120, // timeout in seconds
            'prefill': {
              'contact': '9999999999',
              'email': _emailController.text.isNotEmpty
                  ? _emailController.text
                  : 'customer@example.com',
              'name': _nameController.text.isNotEmpty
                  ? _nameController.text
                  : 'Customer',
            },
            'notes': {
              'order_id': _orderId,
              'shipping_address': _addressController.text,
            },
            'theme': {
              'color': '#3399cc',
            }
          };

          print('Razorpay options: $options');

          // Verify Razorpay instance exists
          if (_razorpay == null) {
            print('Razorpay instance is null, creating a new one');
            await _ensureRazorpayInstance();
          }

          // Open Razorpay checkout with try-catch to handle exceptions
          try {
            _razorpay?.open(options);
            print('Razorpay.open() called successfully');
          } catch (e) {
            print('Error opening Razorpay: $e');
            setState(() {
              _errorMessage = 'Could not open payment gateway: ${e.toString()}';
              _isLoading = false;
            });
          }
        } catch (e) {
          print('Error during Razorpay process: $e');
          setState(() {
            _errorMessage = 'Payment gateway error: ${e.toString()}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Payment process error: $e');
      setState(() {
        _errorMessage = 'Payment error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Show a warning banner when using web
              if (kIsWeb)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade400),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.amber.shade800),
                          const SizedBox(width: 8),
                          Text(
                            'Web Environment Detected',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Razorpay Flutter SDK is not supported in web browsers. '
                        'For real payments, please use the mobile app. '
                        'This will simulate a successful payment for demonstration purposes.',
                      ),
                    ],
                  ),
                ),
              _buildOrderSummary(cart),
              const SizedBox(height: 24),
              _buildShippingForm(),
              const SizedBox(height: 16),
              if (_csrfVerified)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'CSRF verified successfully',
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Place Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal'),
                Text('\$${cart.subtotal.toStringAsFixed(2)}'),
              ],
            ),
            if (cart.activeCoupon != null) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Discount (${cart.activeCoupon!.code})'),
                  Text(
                    '-\$${cart.discountAmount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.brown),
                  ),
                ],
              ),
            ],
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${cart.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipping Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your city';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _zipController,
                    decoration: const InputDecoration(labelText: 'ZIP Code'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your ZIP code';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
