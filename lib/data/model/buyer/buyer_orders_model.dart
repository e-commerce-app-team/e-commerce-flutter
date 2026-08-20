// lib/data/model/buyer/buyer_orders_model.dart

enum BuyerOrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
  returned,
  cancelledReturned,
}

enum BuyerOrderTabFilter { all, active, completed, cancelled }

enum BuyerOrderSort { newest, oldest, priceHigh, priceLow }

enum BuyerReturnStatus {
  none,
  submitted,
  underReview,
  approved,
  rejected,
}

class BuyerOrderItem {
  final String id;
  final String? productId;
  final String name;
  final int quantity;
  final double price;
  final String imageUrl;

  const BuyerOrderItem({
    required this.id,
    this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl = '',
  });

  factory BuyerOrderItem.fromJson(Map<String, dynamic> json) {
    final product = _asMap(json['product']);
    return BuyerOrderItem(
      id: '${json['id'] ?? ''}',
      productId: product?['id']?.toString() ?? json['product_id']?.toString(),
      name: product?['name']?.toString() ?? json['name']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: _toDouble(json['unit_price'] ?? json['price'] ?? json['total_price']),
      imageUrl: _productImage(product),
    );
  }
}

class BuyerSubOrderModel {
  final String id;
  final String sellerId;
  final String storeName;
  final String storeLogoUrl;
  final double totalPrice;
  final BuyerOrderStatus status;
  final List<BuyerOrderItem> items;

  const BuyerSubOrderModel({
    required this.id,
    required this.sellerId,
    required this.storeName,
    this.storeLogoUrl = '',
    required this.totalPrice,
    required this.status,
    required this.items,
  });

  int get itemsCount => items.fold(0, (sum, e) => sum + e.quantity);

  String get itemsPreview => items.map((e) => e.name).join('، ');

  factory BuyerSubOrderModel.fromJson(Map<String, dynamic> json) {
    final seller = _asMap(json['seller']);
    final itemsJson = _asList(json['items']);
    return BuyerSubOrderModel(
      id: '${json['id'] ?? ''}',
      sellerId: '${json['seller_id'] ?? seller?['id'] ?? ''}',
      storeName: seller?['store_name']?.toString() ??
          seller?['name']?.toString() ??
          json['store_name']?.toString() ??
          '',
      storeLogoUrl: seller?['store_logo']?.toString() ?? '',
      totalPrice: _toDouble(json['total_price'] ?? json['total']),
      status: BuyerOrderStatusX.fromApi(json['status']?.toString()),
      items: itemsJson
          .map(_asMap)
          .whereType<Map<String, dynamic>>()
          .map(BuyerOrderItem.fromJson)
          .toList(),
    );
  }
}

class BuyerTimelineStep {
  final String status;
  final String title;
  final DateTime? time;
  final bool isDone;
  final bool isCurrent;

  const BuyerTimelineStep({
    required this.status,
    required this.title,
    this.time,
    this.isDone = false,
    this.isCurrent = false,
  });

  factory BuyerTimelineStep.fromJson(Map<String, dynamic> json, {required bool isCurrent}) {
    final timeStr = json['time']?.toString();
    return BuyerTimelineStep(
      status: json['status']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      time: timeStr != null && timeStr.isNotEmpty ? DateTime.tryParse(timeStr) : null,
      isDone: json['is_done'] == true || json['done'] == true,
      isCurrent: isCurrent,
    );
  }
}

class BuyerReturnRequest {
  final BuyerReturnStatus status;
  final String reason;
  final String description;
  final List<String> imageUrls;
  final List<BuyerTimelineStep> timeline;

  const BuyerReturnRequest({
    required this.status,
    required this.reason,
    required this.description,
    this.imageUrls = const [],
    this.timeline = const [],
  });
}

class BuyerOrderModel {
  final String id;
  final String orderNumber;
  final double totalAmount;
  final BuyerOrderStatus status;
  final String? paymentStatus;
  final DateTime createdAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final List<BuyerSubOrderModel> subOrders;
  final List<BuyerTimelineStep> timeline;
  final BuyerReturnRequest? returnRequest;
  final bool isRated;
  final bool supportsDeliveryCompany;
  final bool showQr;
  final bool showMapTracking;

  const BuyerOrderModel({
    required this.id,
    required this.orderNumber,
    required this.totalAmount,
    required this.status,
    this.paymentStatus,
    required this.createdAt,
    this.shippedAt,
    this.deliveredAt,
    required this.subOrders,
    this.timeline = const [],
    this.returnRequest,
    this.isRated = false,
    this.supportsDeliveryCompany = false,
    this.showQr = false,
    this.showMapTracking = false,
  });

  bool get isActive => status.isActive;

  bool get isCompleted => status == BuyerOrderStatus.delivered;

  bool get isCancelledGroup =>
      status == BuyerOrderStatus.cancelled ||
      status == BuyerOrderStatus.returned ||
      status == BuyerOrderStatus.cancelledReturned;

  bool get canConfirmDelivery => status == BuyerOrderStatus.shipped;

  bool get canReportProblem =>
      status == BuyerOrderStatus.delivered && returnRequest == null;

  bool get canRate => status == BuyerOrderStatus.delivered && !isRated;

  DateTime? get escrowAutoReleaseAt {
    if (shippedAt == null || status == BuyerOrderStatus.delivered) return null;
    return shippedAt!.add(const Duration(days: 2));
  }

  int get itemsCount =>
      subOrders.fold(0, (sum, s) => sum + s.itemsCount);

  String get itemsPreview {
    final names = subOrders.expand((s) => s.items.map((i) => i.name)).toList();
    if (names.isEmpty) return '';
    return names.take(3).join('، ');
  }

  String get primaryStoreName =>
      subOrders.isNotEmpty ? subOrders.first.storeName : '';

  List<BuyerTimelineStep> get effectiveTimeline {
    if (timeline.isNotEmpty) return timeline;
    return _buildDefaultTimeline();
  }

  List<BuyerTimelineStep> _buildDefaultTimeline() {
    const steps = ['pending', 'processing', 'shipped', 'delivered'];
    final currentIdx = _statusIndex(status);
    final terminal = status == BuyerOrderStatus.delivered ||
        status == BuyerOrderStatus.cancelled ||
        status == BuyerOrderStatus.returned ||
        status == BuyerOrderStatus.cancelledReturned;

    return steps.asMap().entries.map((e) {
      final idx = e.key;
      return BuyerTimelineStep(
        status: e.value,
        title: e.value,
        isDone: terminal ? idx <= currentIdx : idx < currentIdx,
        isCurrent: !terminal && idx == currentIdx,
      );
    }).toList();
  }

  int _statusIndex(BuyerOrderStatus s) {
    switch (s) {
      case BuyerOrderStatus.pending:
        return 0;
      case BuyerOrderStatus.processing:
        return 1;
      case BuyerOrderStatus.shipped:
        return 2;
      case BuyerOrderStatus.delivered:
        return 3;
      default:
        return 0;
    }
  }

  BuyerOrderModel copyWith({
    BuyerOrderStatus? status,
    DateTime? deliveredAt,
    List<BuyerTimelineStep>? timeline,
    BuyerReturnRequest? returnRequest,
    bool? isRated,
    bool clearReturnRequest = false,
  }) {
    return BuyerOrderModel(
      id: id,
      orderNumber: orderNumber,
      totalAmount: totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus,
      createdAt: createdAt,
      shippedAt: shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      subOrders: subOrders,
      timeline: timeline ?? this.timeline,
      returnRequest:
          clearReturnRequest ? null : (returnRequest ?? this.returnRequest),
      isRated: isRated ?? this.isRated,
      supportsDeliveryCompany: supportsDeliveryCompany,
      showQr: showQr,
      showMapTracking: showMapTracking,
    );
  }

  factory BuyerOrderModel.fromJson(Map<String, dynamic> json) {
    final subOrdersJson = _asList(json['sub_orders']);
    final subOrders = subOrdersJson
        .map(_asMap)
        .whereType<Map<String, dynamic>>()
        .map(BuyerSubOrderModel.fromJson)
        .toList();

    final timelineJson = json['timeline'] ?? json['status_timeline'];
    List<BuyerTimelineStep> timeline = [];
    if (timelineJson is List) {
      final parsed = timelineJson
          .map(_asMap)
          .whereType<Map<String, dynamic>>()
          .toList();
      final currentStatus = json['status']?.toString() ?? '';
      timeline = parsed.asMap().entries.map((e) {
        final isLast = e.key == parsed.length - 1;
        return BuyerTimelineStep.fromJson(
          e.value,
          isCurrent: isLast && currentStatus != 'delivered',
        );
      }).toList();
    }

    final id = '${json['id'] ?? ''}';
    return BuyerOrderModel(
      id: id,
      orderNumber: json['order_number']?.toString() ?? 'ORD-$id',
      totalAmount: _toDouble(json['total_price'] ?? json['total_amount']),
      status: BuyerOrderStatusX.fromApi(json['status']?.toString()),
      paymentStatus: json['payment_status']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      shippedAt: DateTime.tryParse(json['shipped_at']?.toString() ?? ''),
      deliveredAt: DateTime.tryParse(json['delivered_at']?.toString() ?? ''),
      subOrders: subOrders,
      timeline: timeline,
      supportsDeliveryCompany: json['supports_delivery_company'] == true,
      showQr: json['show_qr'] == true,
      showMapTracking: json['show_map_tracking'] == true,
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<dynamic> _asList(dynamic value) => value is List ? value : const [];

extension BuyerOrderStatusX on BuyerOrderStatus {
  bool get isActive =>
      this == BuyerOrderStatus.pending ||
      this == BuyerOrderStatus.processing ||
      this == BuyerOrderStatus.shipped;

  static BuyerOrderStatus fromApi(String? raw) {
    switch (raw) {
      case 'processing':
        return BuyerOrderStatus.processing;
      case 'shipped':
        return BuyerOrderStatus.shipped;
      case 'delivered':
        return BuyerOrderStatus.delivered;
      case 'returned':
        return BuyerOrderStatus.returned;
      case 'cancelled_returned':
        return BuyerOrderStatus.cancelledReturned;
      case 'cancelled':
        return BuyerOrderStatus.cancelled;
      default:
        return BuyerOrderStatus.pending;
    }
  }

  String get labelKey {
    switch (this) {
      case BuyerOrderStatus.pending:
        return 'status_pending';
      case BuyerOrderStatus.processing:
        return 'status_processing';
      case BuyerOrderStatus.shipped:
        return 'status_shipped';
      case BuyerOrderStatus.delivered:
        return 'status_delivered';
      case BuyerOrderStatus.cancelled:
        return 'status_cancelled';
      case BuyerOrderStatus.returned:
        return 'status_returned';
      case BuyerOrderStatus.cancelledReturned:
        return 'status_cancelled_returned';
    }
  }
}

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

String _productImage(Map<String, dynamic>? product) {
  if (product == null) return '';
  final images = product['images'];
  if (images is List && images.isNotEmpty) {
    return images.first.toString();
  }
  return product['image']?.toString() ?? '';
}
