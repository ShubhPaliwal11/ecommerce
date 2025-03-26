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
        title: const Text(
          'E-Commerce App',
          style: TextStyle(
            fontFamily: 'hello',
            fontSize: 30,
            color: Color(0xFFE6C7A6),
          ),
        ),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Color(0xFFE6C7A6)),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search, color: Colors.brown),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.brown),
                ),
                filled: true,
                fillColor: Colors.brown.shade50,
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _buildCategoryButton('Electronics'),
                _buildCategoryButton('Computers'),
                _buildCategoryButton('Accessories'),
                _buildCategoryButton('Wearables'),
              ],
            ),
          ),
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
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      // color: Color(0xFFF5E6DA), // Cream color inside the card
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ProductCard(product: products[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Color(0xFFE6C7A6),
        unselectedItemColor: Color(0xFFE6C7A6).withOpacity(0.6),
        backgroundColor: Colors.brown,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, color: Color(0xFFE6C7A6)), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag, color: Color(0xFFE6C7A6)),
            label: 'Orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person, color: Color(0xFFE6C7A6)), label: 'Profile'),
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
      backgroundColor: Colors.brown.shade100,
    );
  }

  Widget _buildCategoryButton(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: () {
          // Handle category tap
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown.shade300,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
