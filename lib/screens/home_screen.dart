import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import '../models/product.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'orders_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample product data
    final List<Product> products = [
      Product(
        id: '1',
        name: 'iPhone 15 Pro',
        description: 'Latest iPhone with A17 Pro chip',
        price: 999.99,
        imageUrl: 'https://picsum.photos/200/300?random=1',
        rating: 4.8,
        reviews: 1250,
      ),
      Product(
        id: '2',
        name: 'MacBook Pro M3',
        description: 'Powerful laptop with M3 chip',
        price: 1999.99,
        imageUrl: 'https://picsum.photos/200/300?random=2',
        rating: 4.9,
        reviews: 850,
      ),
      Product(
        id: '3',
        name: 'AirPods Pro',
        description: 'Wireless earbuds with noise cancellation',
        price: 249.99,
        imageUrl: 'https://picsum.photos/200/300?random=3',
        rating: 4.7,
        reviews: 2100,
      ),
      Product(
        id: '4',
        name: 'iPad Pro',
        description: '12.9-inch iPad with M2 chip',
        price: 1099.99,
        imageUrl: 'https://picsum.photos/200/300?random=4',
        rating: 4.8,
        reviews: 950,
      ),
      Product(
        id: '5',
        name: 'Apple Watch Series 9',
        description: 'Smartwatch with health tracking',
        price: 399.99,
        imageUrl: 'https://picsum.photos/200/300?random=5',
        rating: 4.6,
        reviews: 1800,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          // Categories
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _buildCategoryCard(Icons.phone_android, 'Electronics'),
                _buildCategoryCard(Icons.computer, 'Computers'),
                _buildCategoryCard(Icons.headphones, 'Accessories'),
                _buildCategoryCard(Icons.watch, 'Wearables'),
              ],
            ),
          ),
          // Products grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductCard(product: products[index]);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrdersScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildCategoryCard(IconData icon, String label) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () {
          // Handle category tap
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
