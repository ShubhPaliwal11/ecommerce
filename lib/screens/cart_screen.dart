import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../models/coupon.dart';
import '../widgets/coupon_dialog.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty && cart.savedItems.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    if (cart.items.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Cart Items',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...cart.items.values.map(
                        (item) => _buildCartItem(context, item, false),
                      ),
                    ],
                    if (cart.savedItems.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Saved for Later',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...cart.savedItems.values.map(
                        (item) => _buildCartItem(context, item, true),
                      ),
                    ],
                  ],
                ),
              ),
              if (cart.items.isNotEmpty) _buildCartSummary(context, cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item, bool isSaved) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Image.network(
          item.product.imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(item.product.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\$${item.product.price.toStringAsFixed(2)}'),
            if (!isSaved) Text('Quantity: ${item.quantity}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isSaved) ...[
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () {
                  context.read<CartProvider>().saveForLater(item.product.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item saved for later')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  context.read<CartProvider>().removeItem(item.product.id);
                },
              ),
              Text('${item.quantity}'),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  context.read<CartProvider>().addItem(item.product);
                },
              ),
            ] else ...[
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  context.read<CartProvider>().moveToCart(item.product.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item moved to cart')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  context.read<CartProvider>().removeItem(item.product.id);
                },
              ),
            ],
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
          if (cart.activeCoupon != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_offer, color: Colors.brown),
                    const SizedBox(width: 8),
                    Text(
                      'Coupon: ${cart.activeCoupon!.code}',
                      style: const TextStyle(
                        color: Colors.brown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    cart.removeCoupon();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Discount'),
                Text(
                  '-\$${cart.discountAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text('\$${cart.subtotal.toStringAsFixed(2)}'),
            ],
          ),
          if (cart.activeCoupon != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${cart.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showCouponDialog(context, cart),
                  icon: const Icon(Icons.local_offer),
                  label: const Text('Apply Coupon'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/checkout');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Checkout'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCouponDialog(BuildContext context, CartProvider cart) {
    // Sample coupons - in a real app, these would come from a backend
    final coupons = [
      Coupon(
        code: 'WELCOME10',
        description: '10% off on your first order',
        discountPercentage: 10,
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        minimumPurchaseAmount: 50,
      ),
      Coupon(
        code: 'SPECIAL20',
        description: '20% off on orders above \$100',
        discountPercentage: 20,
        expiryDate: DateTime.now().add(const Duration(days: 15)),
        minimumPurchaseAmount: 100,
      ),
      Coupon(
        code: 'FLASH30',
        description: '30% off on orders above \$200',
        discountPercentage: 30,
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        minimumPurchaseAmount: 200,
      ),
    ];

    showDialog(
      context: context,
      builder: (context) =>
          CouponDialog(coupons: coupons, cartTotal: cart.subtotal),
    ).then((selectedCoupon) {
      if (selectedCoupon != null) {
        if (cart.applyCoupon(selectedCoupon)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Coupon ${selectedCoupon.code} applied successfully!',
              ),
              backgroundColor: Colors.brown,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This coupon cannot be applied to your cart'),
              backgroundColor: Colors.brown,
            ),
          );
        }
      }
    });
  }
}
