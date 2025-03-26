import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: ListView.builder(
        itemCount: 5, // Sample data
        itemBuilder: (context, index) {
          return _buildOrderCard(context);
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            title: const Text('Order #12345'),
            subtitle: const Text('Placed on March 15, 2024'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Delivered',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: Image.network(
              'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-15-pro-finish-select-202309-6-7inch_GEO_EMEA?wid=5120&hei=2880&fmt=p-jpg&qlt=80&.v=1693009284541',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: const Text('iPhone 15 Pro'),
            subtitle: const Text('1 item'),
            trailing: const Text('\$999.99'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    // Handle reorder
                  },
                  child: const Text('Reorder'),
                ),
                TextButton(
                  onPressed: () {
                    // Handle cancel order
                  },
                  child: const Text('Cancel Order'),
                ),
                TextButton(
                  onPressed: () {
                    // Handle write review
                  },
                  child: const Text('Write Review'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
