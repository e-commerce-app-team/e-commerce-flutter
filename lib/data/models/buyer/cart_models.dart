// ─────────────────────────────────────────────────────────────────────────────
// lib/data/models/buyer/cart_models.dart
// ─────────────────────────────────────────────────────────────────────────────

class CartItem {
  final String id;
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final int quantity;
  final String? variant; // e.g. "مقاس: L — لون: أبيض"
  final String storeName;
  final String storeId;
  final int maxStock; // لمنع تجاوز المخزون

  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    required this.quantity,
    this.variant,
    required this.storeName,
    required this.storeId,
    this.maxStock = 99,
  });

  /// نسبة الخصم على المنتج (إن وجدت)
  double? get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return null;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
  }

  /// إجمالي سعر هذا المنتج حسب الكمية
  double get lineTotal => price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        id: id,
        productId: productId,
        name: name,
        imageUrl: imageUrl,
        price: price,
        originalPrice: originalPrice,
        quantity: quantity ?? this.quantity,
        variant: variant,
        storeName: storeName,
        storeId: storeId,
        maxStock: maxStock,
      );
}
