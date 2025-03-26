import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_commerce/pages/auth_screen.dart';
import 'package:e_commerce/pages/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dmbyuzxazfqmvqdqegyn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRtYnl1enhhemZxbXZxZHFlZ3luIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI5NzgyODIsImV4cCI6MjA1ODU1NDI4Mn0.YNtpistaMpTP7CajgyrtZyCa5cI3XLjg1nbguP806DQ',

  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final supabase = Supabase.instance.client;
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();

    // Listen to auth state changes
    supabase.auth.onAuthStateChange.listen((data) {
      final session = supabase.auth.currentSession;
      setState(() {
        isAuthenticated = session != null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isAuthenticated ? HomeScreen() : AuthScreen(),
    );
  }
}
