import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/coupon.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  final Map<String, CartItem> _savedItems = {};
  Coupon? _activeCoupon;

  Map<String, CartItem> get items => {..._items};
  Map<String, CartItem> get savedItems => {..._savedItems};
  Coupon? get activeCoupon => _activeCoupon;

  int get itemCount => _items.length;
  int get savedItemCount => _savedItems.length;

  double get subtotal {
    return _items.values.fold(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  double get discountAmount {
    if (_activeCoupon == null) return 0.0;
    return _activeCoupon!.calculateDiscount(subtotal);
  }

  double get totalAmount {
    return subtotal - discountAmount;
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(product.id, () => CartItem(product: product));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void saveForLater(String productId) {
    if (_items.containsKey(productId)) {
      final item = _items[productId]!;
      _items.remove(productId);
      _savedItems.putIfAbsent(
        productId,
        () => CartItem(
          product: item.product,
          quantity: item.quantity,
          isSaved: true,
        ),
      );
      notifyListeners();
    }
  }

  void moveToCart(String productId) {
    if (_savedItems.containsKey(productId)) {
      final item = _savedItems[productId]!;
      _savedItems.remove(productId);
      _items.putIfAbsent(
        productId,
        () => CartItem(
          product: item.product,
          quantity: item.quantity,
          isSaved: false,
        ),
      );
      notifyListeners();
    }
  }

  bool applyCoupon(Coupon coupon) {
    if (coupon.isValid(subtotal)) {
      _activeCoupon = coupon;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeCoupon() {
    _activeCoupon = null;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _savedItems.clear();
    _activeCoupon = null;
    notifyListeners();
  }
}
