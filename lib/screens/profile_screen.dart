import 'package:e_commerce/pages/LogininPage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/auth_screen.dart';

Future<void> signOutUser(BuildContext context) async {
  try {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()),
      (route) => false, // Remove all previous routes
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Successfully logged out')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Handle settings
            },
          ),
        ],
      ),
      backgroundColor: Colors.brown.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.brown,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://imgs.search.brave.com/lwNPb1k8bMfm9sjIydfMxGzlGbwtjRaKYrwGa1YxnUc/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9jZG4x/Lmljb25maW5kZXIu/Y29tL2RhdGEvaWNv/bnMvbmluamEtdGhp/bmdzLTEvNzIwL25p/bmphLWJhY2tncm91/bmQtMTI4LnBuZw',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sanskar Agrawal',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'sanskar21072005@gmail.com',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            _buildProfileOption(Icons.shopping_bag, 'My Orders'),
            _buildProfileOption(Icons.favorite, 'Wishlist'),
            _buildProfileOption(Icons.location_on, 'Shipping Addresses'),
            _buildProfileOption(Icons.payment, 'Payment Methods'),
            _buildProfileOption(Icons.notifications, 'Notifications'),
            _buildProfileOption(Icons.help, 'Help & Support'),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.brown),
              title:
                  const Text('Logout', style: TextStyle(color: Colors.brown)),
              onTap: () => signOutUser(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.brown),
      title: Text(title, style: const TextStyle(color: Colors.brown)),
      trailing: const Icon(Icons.chevron_right, color: Colors.brown),
      onTap: () {
        // Navigate to respective screen
      },
    );
  }
}
