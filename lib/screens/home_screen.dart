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
        imageUrl: 'https://imgs.search.brave.com/3GUyVG79yRlOwgoFFUAvAH117Phqg7E1CJ6vGjDBd8k/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly93d3cu/YXBwbGUuY29tL25l/d3Nyb29tL2ltYWdl/cy8yMDIzLzA5L2Fw/cGxlLXVudmVpbHMt/aXBob25lLTE1LXBy/by1hbmQtaXBob25l/LTE1LXByby1tYXgv/YXJ0aWNsZS9BcHBs/ZS1pUGhvbmUtMTUt/UHJvLWxpbmV1cC1o/ZXJvLTIzMDkxMl9G/dWxsLUJsZWVkLUlt/YWdlLmpwZy5sYXJn/ZS5qcGc',
        rating: 4.8,
        reviews: 1250,
      ),
      Product(
        id: '2',
        name: 'MacBook Pro M3',
        description: 'Powerful laptop with M3 chip',
        price: 1999.99,
        imageUrl: 'https://imgs.search.brave.com/2o9yAAAiAhGNo5zYAJdnUJicVDnYK6zBCJsBxGFU_vk/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly90NC5m/dGNkbi5uZXQvanBn/LzA1LzUwLzczLzYx/LzM2MF9GXzU1MDcz/NjE1M182dEdNTXBk/UGJ4a3c0cHVDMmlj/YWg0UmpYUlZWaFJE/cC5qcGc',
        rating: 4.9,
        reviews: 850,
      ),
      Product(
        id: '3',
        name: 'AirPods Pro',
        description: 'Wireless earbuds with noise cancellation',
        price: 249.99,
        imageUrl: 'https://imgs.search.brave.com/3c4Om-CCMU1XkbiTjMDu7HLGmwNSvG0J2Ztg0mRFol4/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5nZXR0eWltYWdl/cy5jb20vaWQvMTQ1/OTM5MTE4My9waG90/by93aXJlbGVzcy1i/bHVldG9vdGgtaGVh/ZHBob25lcy5qcGc_/cz02MTJ4NjEyJnc9/MCZrPTIwJmM9Rmto/dmptcjZXdDhjSERN/bUFCOHJNRWxkMHpO/eE9YOUlrSXIxTnM3/QWNPTT0',
        rating: 4.7,
        reviews: 2100,
      ),
      Product(
        id: '4',
        name: 'iPad Pro',
        description: '12.9-inch iPad with M2 chip',
        price: 1099.99,
        imageUrl: 'https://imgs.search.brave.com/LSIRstSHmoA79woTvvi8FzApgnIrIFeG1dG2QM324-g/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pbWFn/ZXMubWFjcnVtb3Jz/LmNvbS9hcnRpY2xl/LW5ldy8yMDI0LzA1/L200LWlwYWQtcHJv/LXB1cnBsZS5qcGc',
        rating: 4.8,
        reviews: 950,
      ),
      Product(
        id: '5',
        name: 'Apple Watch Series 9',
        description: 'Smartwatch with health tracking',
        price: 399.99,
        imageUrl: 'https://imgs.search.brave.com/6MKPMo57vcRjBTzk6dtF58g5DSEddhRMhaLaTDM6nzQ/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9jZG4u/dGhld2lyZWN1dHRl/ci5jb20vd3AtY29u/dGVudC9tZWRpYS8y/MDIzLzA5L2FwcGxl/d2F0Y2gtMjA0OHB4/LTc3OTYuanBnP2F1/dG89d2VicCZxdWFs/aXR5PTc1JndpZHRo/PTEwMjQ',
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
