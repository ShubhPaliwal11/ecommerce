import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final product = cart.items.values.elementAt(index);
                    return _buildCartItem(context, cart, product as Product);
                  },
                ),
              ),
              _buildCartSummary(context, cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartProvider cart,
    Product product,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Remove Button
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => cart.removeItem(product.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${cart.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement checkout
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
