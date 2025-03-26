import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../screens/product_details_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  product.imageUrl,
                  height: 216,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Consumer<CartProvider>(
                    builder: (context, cart, child) {
                      return IconButton(
                        icon: Icon(
                          product.isInCart
                              ? Icons.shopping_cart
                              : Icons.shopping_cart_outlined,
                          color: product.isInCart ? Colors.brown : Colors.grey,
                        ),
                        onPressed: () {
                          if (product.isInCart) {
                            cart.removeItem(product.id);
                          } else {
                            cart.addItem(product);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.brown),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${product.reviews} reviews)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
