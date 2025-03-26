import 'package:e_commerce/pages/LogininPage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_commerce/pages/auth_screen.dart';
import 'package:e_commerce/screens/home_screen.dart';
import 'package:e_commerce/screens/checkout_screen.dart';
import 'package:e_commerce/screens/order_confirmation_screen.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'services/backend_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:flutter/foundation.dart' show kIsWeb;

// void main() {
//   runApp(MaterialApp(
//     home: Logininpage(),
//   ));
// }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _isInitialized = false;
  bool isAuthenticated = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize Flutter bindings
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Supabase
      await Supabase.initialize(
        url: 'https://dmbyuzxazfqmvqdqegyn.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRtYnl1enhhemZxbXZxZHFlZ3luIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI5NzgyODIsImV4cCI6MjA1ODU1NDI4Mn0.YNtpistaMpTP7CajgyrtZyCa5cI3XLjg1nbguP806DQ',
      );

      // Initialize Stripe only for mobile platforms
      if (!kIsWeb) {
        stripe.Stripe.publishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
      }

      // Initialize backend service
      await BackendService.initialize();

      // Check authentication status
      final session = Supabase.instance.client.auth.currentSession;

      if (mounted) {
        setState(() {
          isAuthenticated = session != null;
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing app...'),
              ],
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: $_error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _isInitialized = false;
                    });
                    _initializeApp();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        initialRoute: isAuthenticated ? '/home' : '/auth',
        routes: {
          '/auth': (context) => AuthScreen(),
          '/home': (context) => HomeScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/order-confirmation': (context) => const OrderConfirmationScreen(),
        },
      ),
    );
  }
}
