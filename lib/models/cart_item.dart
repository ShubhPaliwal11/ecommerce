import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  bool isSaved;

  CartItem({required this.product, this.quantity = 1, this.isSaved = false});
}
