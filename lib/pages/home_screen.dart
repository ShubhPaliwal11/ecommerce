import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart'; // Import the authentication screen

final supabase = Supabase.instance.client;

class HomeScreen extends StatelessWidget {
  Future<void> signOut(BuildContext context) async {
    await supabase.auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => signOut(context), // Call the function here
          ),
        ],
      ),
      body: Center(child: Text('Welcome to the Home Screen!')),
    );
  }
}
