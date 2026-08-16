// lib/data/models/buyer/buyer_orders_model.dart
// Pure data layer — zero Flutter/UI imports.

enum BuyerOrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
  returned,
}

class BuyerOrderItem {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final String imageUrl;

  const BuyerOrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });
}

class BuyerOrderModel {
  final String id;
  final String orderNumber;
  final String storeName;
  final String storeLogoUrl;
  final double totalAmount;
  final BuyerOrderStatus status;
  final DateTime createdAt;
  final List<BuyerOrderItem> items;
  final String? trackingNumber;

  const BuyerOrderModel({
    required this.id,
    required this.orderNumber,
    required this.storeName,
    required this.storeLogoUrl,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.items,
    this.trackingNumber,
  });

  /// Total number of purchased items (sum of quantities).
  int get itemsCount => items.fold(0, (sum, e) => sum + e.quantity);

  /// Comma-joined product names for the single-line preview row.
  String get itemsPreview => items.map((e) => e.name).join('، ');
}

