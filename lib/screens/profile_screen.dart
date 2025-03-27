import 'package:e_commerce/pages/LogininPage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
Future<void> signOutUser(BuildContext context) async {
  try {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Logininpage()),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor,
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150',
                    ),
                  ),
                  const SizedBox(height: 16),
                   Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'john.doe@example.com',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            // Profile options
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('My Orders'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to orders
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Wishlist'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to wishlist
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Shipping Addresses'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to addresses
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Payment Methods'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to payment methods
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to notifications
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to help
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => signOutUser(context),
            ),
          ],
        ),
      ),
    );
  }
}
