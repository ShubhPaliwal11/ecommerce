import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: CheckoutScreen(),
  ));
}

class CheckoutScreen extends StatelessWidget {
  final List<Map<String, dynamic>> chosenProducts = [
    {'name': 'Product A', 'price': 200},
    {'name': 'Product B', 'price': 150},
  ];

  final List<Map<String, dynamic>> recommendedProducts = [
    {'name': 'Product C', 'price': 180},
    {'name': 'Product D', 'price': 220},
  ];

  @override
  Widget build(BuildContext context) {
    double total = chosenProducts.fold(0, (sum, item) => sum + item['price']);

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Chosen Products', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            ...chosenProducts.map((product) => ListTile(
                  title: Text(product['name']),
                  subtitle: Text('₹${product['price']}'),
                )),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Recommended Products', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            ...recommendedProducts.map((product) => ListTile(
                  title: Text(product['name']),
                  subtitle: Text('₹${product['price']}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Add your add-to-cart logic here
                      print('Added ${product['name']}');
                    },
                    child: Text('Add'),
                  ),
                )),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Total: ₹$total', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}