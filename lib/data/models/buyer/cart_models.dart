// lib/data/models/buyer/cart_models.dart

class ShippingOption {
  final String id;
  final String name;
  final String nameAr;
  final double cost;
  final String estimatedDelivery;
  final String estimatedDeliveryAr;

  const ShippingOption({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.cost,
    required this.estimatedDelivery,
    required this.estimatedDeliveryAr,
  });

  factory ShippingOption.fromJson(Map<String, dynamic> json) => ShippingOption(
        id: json['id']?.toString() ?? 'standard',
        name: json['name']?.toString() ?? '',
        nameAr: json['name_ar']?.toString() ?? json['name']?.toString() ?? '',
        cost: _toDouble(json['cost']),
        estimatedDelivery: json['estimated_delivery']?.toString() ?? '',
        estimatedDeliveryAr: json['estimated_delivery_ar']?.toString() ??
            json['estimated_delivery']?.toString() ??
            '',
      );

  String label(bool isArabic) => isArabic ? nameAr : name;
  String etaLabel(bool isArabic) =>
      isArabic ? estimatedDeliveryAr : estimatedDelivery;
}

class CartItem {
  final String id;
  final String productId;
  final String? variantId;
  final String name;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final int quantity;
  final int maxStock;
  final bool isOutOfStock;
  final String? variant;

  const CartItem({
    required this.id,
    required this.productId,
    this.variantId,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    required this.quantity,
    required this.maxStock,
    this.isOutOfStock = false,
    this.variant,
  });

  double? get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return null;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
  }

  double get lineTotal => price * quantity;

  CartItem copyWith({int? quantity, int? maxStock, bool? isOutOfStock}) =>
      CartItem(
        id: id,
        productId: productId,
        variantId: variantId,
        name: name,
        imageUrl: imageUrl,
        price: price,
        originalPrice: originalPrice,
        quantity: quantity ?? this.quantity,
        maxStock: maxStock ?? this.maxStock,
        isOutOfStock: isOutOfStock ?? this.isOutOfStock,
        variant: variant,
      );

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id']?.toString() ?? '',
        productId: json['product_id']?.toString() ?? '',
        variantId: json['variant_id']?.toString(),
        name: json['name']?.toString() ?? '',
        imageUrl: json['image']?.toString() ?? '',
        price: _toDouble(json['price']),
        originalPrice: json['original_price'] != null
            ? _toDouble(json['original_price'])
            : null,
        quantity: int.tryParse('${json['quantity']}') ?? 1,
        maxStock: int.tryParse('${json['max_stock']}') ?? 99,
        isOutOfStock: json['is_out_of_stock'] == true,
        variant: json['variant']?.toString(),
      );
}

class StoreCartGroup {
  final String sellerId;
  final String storeName;
  final String? storeLogo;
  final List<CartItem> items;
  final int itemsCount;
  final double subtotal;
  final bool hasFreeShipping;
  final List<ShippingOption> shippingOptions;

  const StoreCartGroup({
    required this.sellerId,
    required this.storeName,
    this.storeLogo,
    required this.items,
    required this.itemsCount,
    required this.subtotal,
    this.hasFreeShipping = false,
    this.shippingOptions = const [],
  });

  StoreCartGroup copyWith({
    List<CartItem>? items,
    List<ShippingOption>? shippingOptions,
  }) =>
      StoreCartGroup(
        sellerId: sellerId,
        storeName: storeName,
        storeLogo: storeLogo,
        items: items ?? this.items,
        itemsCount: items?.fold<int>(0, (a, i) => a + i.quantity) ?? itemsCount,
        subtotal: items?.fold<double>(0, (a, i) => a + i.lineTotal) ?? subtotal,
        hasFreeShipping: hasFreeShipping,
        shippingOptions: shippingOptions ?? this.shippingOptions,
      );

  factory StoreCartGroup.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
            .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <CartItem>[];

    final rawShipping = json['shipping_options'];
    final shipping = rawShipping is List
        ? rawShipping
            .map((e) => ShippingOption.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <ShippingOption>[];

    return StoreCartGroup(
      sellerId: json['seller_id']?.toString() ?? '',
      storeName: json['store_name']?.toString() ?? '',
      storeLogo: json['store_logo']?.toString(),
      items: items,
      itemsCount: int.tryParse('${json['items_count']}') ?? items.length,
      subtotal: _toDouble(json['subtotal']),
      hasFreeShipping: json['has_free_shipping'] == true,
      shippingOptions: shipping,
    );
  }
}

class BuyerAddress {
  final String id;
  final String title;
  final String details;
  final double? latitude;
  final double? longitude;
  final String? driverNotes;
  final bool isDefault;

  const BuyerAddress({
    required this.id,
    required this.title,
    required this.details,
    this.latitude,
    this.longitude,
    this.driverNotes,
    this.isDefault = false,
  });

  BuyerAddress copyWith({
    String? title,
    String? details,
    double? latitude,
    double? longitude,
    String? driverNotes,
    bool? isDefault,
  }) =>
      BuyerAddress(
        id: id,
        title: title ?? this.title,
        details: details ?? this.details,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        driverNotes: driverNotes ?? this.driverNotes,
        isDefault: isDefault ?? this.isDefault,
      );

  factory BuyerAddress.fromJson(Map<String, dynamic> json) => BuyerAddress(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        details: json['details']?.toString() ?? '',
        latitude: json['latitude'] != null ? _toDouble(json['latitude']) : null,
        longitude:
            json['longitude'] != null ? _toDouble(json['longitude']) : null,
        driverNotes: json['driver_notes']?.toString(),
        isDefault: json['is_default'] == true,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'details': details,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (driverNotes != null && driverNotes!.isNotEmpty)
          'driver_notes': driverNotes,
        'is_default': isDefault,
      };
}

class AppliedStoreCoupon {
  final String code;
  final String type;
  final double discountAmount;
  final String? message;

  const AppliedStoreCoupon({
    required this.code,
    required this.type,
    required this.discountAmount,
    this.message,
  });
}

class CheckoutResult {
  final String orderId;
  final String orderNumber;
  final double totalPrice;

  const CheckoutResult({
    required this.orderId,
    required this.orderNumber,
    required this.totalPrice,
  });

  factory CheckoutResult.fromJson(Map<String, dynamic> json) => CheckoutResult(
        orderId: json['order_id']?.toString() ?? '',
        orderNumber: json['order_number']?.toString() ?? '',
        totalPrice: _toDouble(json['total_price']),
      );
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}
