import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../screens/cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(widget.product.imageUrl, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.brown],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border,color: Colors.brown),
                onPressed: () {
                  // TODO: Implement wishlist functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to wishlist')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share,color: Colors.brown),
                onPressed: () {
                  // TODO: Implement share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share functionality coming soon'),
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Consumer<CartProvider>(
                        builder: (context, cart, child) {
                          return IconButton(
                            icon: const Icon(Icons.shopping_cart,color: Colors.brown),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CartScreen(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.brown, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        widget.product.rating.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${widget.product.reviews} reviews)',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.brown.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${widget.product.price.toStringAsFixed(2)}',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            color: Colors.brown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Colors.brown),
                                onPressed:
                                quantity > 1
                                    ? () {
                                  setState(() {
                                    quantity--;
                                  });
                                }
                                    : null,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add,color: Colors.brown,),
                                onPressed: () {
                                  setState(() {
                                    quantity++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Specifications',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildSpecificationItem('Brand', 'Apple'),
                        _buildDivider(),
                        _buildSpecificationItem('Model', widget.product.name),
                        _buildDivider(),
                        _buildSpecificationItem('Color', 'Space Gray'),
                        _buildDivider(),
                        _buildSpecificationItem('Warranty', '1 Year'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            for (int i = 0; i < quantity; i++) {
                              context.read<CartProvider>().addItem(
                                widget.product,
                              );
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Added $quantity item(s) to cart',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.brown,
                          ),
                          icon: const Icon(Icons.shopping_cart, color: Colors.grey,),
                          label: const Text(
                            'Add to Cart',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[300],
      indent: 16,
      endIndent: 16,
    );
  }
}