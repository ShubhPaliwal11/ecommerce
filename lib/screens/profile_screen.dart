import 'package:flutter/material.dart';

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
            // Profile header
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
                      'https://via.placeholder.com/150',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
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
            _buildProfileOption(Icons.shopping_bag, 'My Orders'),
            _buildProfileOption(Icons.favorite, 'Wishlist'),
            _buildProfileOption(Icons.location_on, 'Shipping Addresses'),
            _buildProfileOption(Icons.payment, 'Payment Methods'),
            _buildProfileOption(Icons.notifications, 'Notifications'),
            _buildProfileOption(Icons.help, 'Help & Support'),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.brown),
              title: const Text('Logout', style: TextStyle(color: Colors.brown)),
              onTap: () {
                // Handle logout
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logout functionality coming soon!'),
                  ),
                );
              },
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
