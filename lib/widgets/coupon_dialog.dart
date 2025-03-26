import 'package:flutter/material.dart';
import '../models/coupon.dart';

class CouponDialog extends StatelessWidget {
  final List<Coupon> coupons;
  final double cartTotal;

  const CouponDialog({
    super.key,
    required this.coupons,
    required this.cartTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Coupons',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: coupons.length,
                itemBuilder: (context, index) {
                  final coupon = coupons[index];
                  final isValid = coupon.isValid(cartTotal);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isValid ? Colors.white : Colors.grey[100],
                    child: ListTile(
                      title: Text(
                        coupon.code,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isValid ? Colors.brown : Colors.brown.shade50,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(coupon.description),
                          if (!isValid) ...[
                            if (DateTime.now().isAfter(coupon.expiryDate))
                              const Text(
                                'Expired',
                                style: TextStyle(color: Colors.red),
                              )
                            else if (cartTotal < coupon.minimumPurchaseAmount)
                              Text(
                                'Min. purchase: \$${coupon.minimumPurchaseAmount.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.red),
                              ),
                          ],
                        ],
                      ),
                      trailing: Text(
                        '${coupon.discountPercentage}% OFF',
                        style: TextStyle(
                          color: isValid ? Colors.brown : Colors.brown.shade50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap:
                          isValid
                              ? () {
                                Navigator.pop(context, coupon);
                              }
                              : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
