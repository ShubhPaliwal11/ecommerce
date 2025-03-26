class Coupon {
  final String code;
  final String description;
  final double discountPercentage;
  final DateTime expiryDate;
  final double minimumPurchaseAmount;
  final bool isActive;

  Coupon({
    required this.code,
    required this.description,
    required this.discountPercentage,
    required this.expiryDate,
    required this.minimumPurchaseAmount,
    this.isActive = true,
  });

  bool isValid(double cartTotal) {
    return isActive &&
        DateTime.now().isBefore(expiryDate) &&
        cartTotal >= minimumPurchaseAmount;
  }

  double calculateDiscount(double cartTotal) {
    return (cartTotal * discountPercentage) / 100;
  }
}
