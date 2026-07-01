import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String _formatDateTime(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  try {
    final dt = DateTime.parse(raw).toLocal();
    return DateFormat('yyyy-MM-dd hh:mm a').format(dt);
  } catch (e) {
    return raw;
  }
}

class DiscountInfo {
  final String source;
  final String? couponCode;
  final int amount;

  const DiscountInfo({
    required this.source,
    this.couponCode,
    required this.amount,
  });

  bool get isCoupon => source == 'coupon';
  bool get isSpinWheel => source == 'spin_wheel';
  bool get isFreeShipping => source == 'free_shipping';
  bool get hasMoneyOff => amount > 0;

  factory DiscountInfo.fromJson(Map json) => DiscountInfo(
    source: json['discount_source'] ?? 'coupon',
    couponCode: json['coupon_code'],
    amount: json['discount_amount'] ?? 0,
  );
}

class OrderItemModel {
  final String name;
  final int qty;
  final int price;
  final String? variant;

  const OrderItemModel({
    required this.name,
    required this.qty,
    required this.price,
    this.variant,
  });

  factory OrderItemModel.fromJson(Map json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return double.tryParse(val)?.toInt() ?? 0;
      return 0;
    }
    return OrderItemModel(
      name: json['name'] ?? '',
      qty: parseInt(json['pivot']?['quantity'] ?? json['qty']),
      price: parseInt(json['pivot']?['price'] ?? json['price']),
      variant: json['variant'],
    );
  }

  int get subtotal => qty * price;
}

class TimelineStep {
  final String status;
  final String step;
  final String time;
  final bool isDone;

  const TimelineStep({
    required this.status,
    required this.step,
    required this.time,
    required this.isDone,
  });

  factory TimelineStep.fromJson(Map json) => TimelineStep(
    status: json['status'] ?? '',
    step: json['title'] ?? json['step'] ?? '',
    time: _formatDateTime(json['time']),
    isDone: json['is_done'] ?? true,
  );
}

class SubOrderModel {
  final String subOrderId;
  final int buyerId;
  final String buyerName;
  final String buyerPhone;
  final String shippingAddress;
  final List<OrderItemModel> items;
  final int itemsTotal;
  final int shippingFee;
  final int discount;
  final int subtotal;
  final String status;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? customerNotes;
  final String shippingType;
  final String createdAt;
  final String? qrToken;
  final String? estimatedReady;
  final String? escrowReleaseAt;
  final List<TimelineStep> timeline;
  final DiscountInfo? discountInfo;

  const SubOrderModel({
    required this.subOrderId,
    required this.buyerId,
    required this.buyerName,
    required this.buyerPhone,
    required this.shippingAddress,
    required this.items,
    required this.itemsTotal,
    required this.shippingFee,
    required this.discount,
    required this.subtotal,
    required this.status,
    this.paymentStatus,
    this.paymentMethod,
    this.customerNotes,
    required this.shippingType,
    required this.createdAt,
    this.qrToken,
    this.estimatedReady,
    this.escrowReleaseAt,
    this.timeline = const [],
    this.discountInfo,
  });

  factory SubOrderModel.fromJson(Map json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return double.tryParse(val)?.toInt() ?? 0;
      return 0;
    }
    
    final rawProducts = json['products'] ?? json['items'];
    final itemsList = (rawProducts is List ? rawProducts : [])
        .map((i) => OrderItemModel.fromJson(i is Map ? i : {}))
        .toList();
        
    final rawTimeline = json['status_timeline'] ?? json['tracking_timeline'];
    final timelineList = (rawTimeline is List ? rawTimeline : [])
        .map((t) => TimelineStep.fromJson(t is Map ? t : {}))
        .toList();
    final discountJson = json['discount_info'];
    
    final rawBuyer = json['buyer'];
    final buyerMap = rawBuyer is Map ? rawBuyer : null;
    final bName = buyerMap != null ? '${buyerMap['first_name']} ${buyerMap['last_name']}' : (json['buyer_name'] ?? '');
    
    return SubOrderModel(
      subOrderId: json['id'] != null ? '#ORD-${json['id']}' : (json['sub_order_id'] ?? ''),
      buyerId: parseInt(buyerMap?['id'] ?? json['buyer_id']),
      buyerName: bName,
      buyerPhone: buyerMap?['phone'] ?? json['buyer_phone'] ?? '',
      shippingAddress: json['shipping_address_details'] ?? json['shipping_address'] ?? '',
      items: itemsList,
      itemsTotal: parseInt(json['total_price'] ?? json['items_total']),
      shippingFee: parseInt(json['shipping_fee']),
      discount: parseInt(json['discount']),
      subtotal: parseInt(json['total_price'] ?? json['subtotal']),
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'],
      paymentMethod: json['payment_method'],
      customerNotes: json['customer_notes'],
      shippingType: json['shipping_type'] ?? 'our_delivery',
      createdAt: _formatDateTime(json['created_at']),
      qrToken: json['qr_token'],
      escrowReleaseAt: json['escrow_release_at'],
      timeline: timelineList,
      discountInfo: discountJson is Map ? DiscountInfo.fromJson(discountJson) : null,
    );
  }

  SubOrderModel copyWith({
    String? status,
    String? qrToken,
    DiscountInfo? discountInfo,
  }) =>
      SubOrderModel(
        subOrderId: subOrderId,
        buyerId: buyerId,
        buyerName: buyerName,
        buyerPhone: buyerPhone,
        shippingAddress: shippingAddress,
        items: items,
        itemsTotal: itemsTotal,
        shippingFee: shippingFee,
        discount: discount,
        subtotal: subtotal,
        status: status ?? this.status,
        paymentStatus: paymentStatus,
        paymentMethod: paymentMethod,
        customerNotes: customerNotes,
        shippingType: shippingType,
        createdAt: createdAt,
        qrToken: qrToken ?? this.qrToken,
        escrowReleaseAt: escrowReleaseAt,
        timeline: timeline,
        discountInfo: discountInfo ?? this.discountInfo,
      );

  int get rawId => int.tryParse(subOrderId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isShipped => status == 'shipped';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled' || status == 'cancelled_returned';
  bool get isReturned => status == 'returned';
  bool get isOurDelivery => shippingType == 'our_delivery';
  bool get isSelfShipping => shippingType == 'self_shipping';
  bool get hasDiscount => discount > 0 || discountInfo != null;
  bool get showQR => isOurDelivery && (isProcessing || isShipped);

  String _formatPrice(int v) =>
      v >= 1000 ? 'SP ${v ~/ 1000}k' : 'SP $v';

  String get formattedTotal => _formatPrice(subtotal);

  static List<SubOrderModel> mockList() => [
    SubOrderModel(
      subOrderId: '#ORD-2847',
      buyerId: 101,
      buyerName: 'Alaa Aldoos',
      buyerPhone: '0911234567',
      shippingAddress: 'دمشق، المزة، بناء 5',
      items: const [
        OrderItemModel(
            name: 'مبايل ايفون', qty: 1, price: 45000, variant: 'اسود'),
        OrderItemModel(name: 'مبايل ايفون', qty: 2, price: 15000),
      ],
      itemsTotal: 75000,
      shippingFee: 5000,
      discount: 10000,
      subtotal: 70000,
      status: 'pending',
      shippingType: 'our_delivery',
      createdAt: 'منذ دقيقتين',
      discountInfo: const DiscountInfo(
        source: 'coupon',
        couponCode: 'SUMMER25',
        amount: 10000,
      ),
    ),
    SubOrderModel(
      subOrderId: '#ORD-2846',
      buyerId: 102,
      buyerName: 'Soso Ahmad',
      buyerPhone: '0921234567',
      shippingAddress: 'حلب، العزيزية',
      items: const [
        OrderItemModel(name: 'لابتب', qty: 2, price: 14000),
      ],
      itemsTotal: 28000,
      shippingFee: 0,
      discount: 0,
      subtotal: 28000,
      status: 'processing',
      shippingType: 'our_delivery',
      createdAt: 'منذ 15 دقيقة',
      qrToken: 'MOCK_QR_TOKEN_2846',
      discountInfo: const DiscountInfo(
        source: 'spin_wheel',
        amount: 0,
      ),
    ),
    SubOrderModel(
      subOrderId: '#ORD-2845',
      buyerId: 103,
      buyerName: 'Alaa Adf',
      buyerPhone: '0931234567',
      shippingAddress: 'حمص، وادي الذهب',
      items: const [
        OrderItemModel(name: 'سوار فضي', qty: 1, price: 32000),
        OrderItemModel(name: 'سوار الذهب', qty: 3, price: 8500),
      ],
      itemsTotal: 57500,
      shippingFee: 0,
      discount: 5000,
      subtotal: 52500,
      status: 'shipped',
      shippingType: 'self_shipping',
      createdAt: 'منذ ساعة',
      discountInfo: const DiscountInfo(
        source: 'free_shipping',
        amount: 0,
      ),
    ),
    SubOrderModel(
      subOrderId: '#ORD-2844',
      buyerId: 104,
      buyerName: 'Soaad Mosa',
      buyerPhone: '0941234567',
      shippingAddress: 'دمشق، باب توما',
      items: const [
        OrderItemModel(name: 'سوار ذهبي', qty: 1, price: 38000),
      ],
      itemsTotal: 38000,
      shippingFee: 5000,
      discount: 0,
      subtotal: 43000,
      status: 'delivered',
      shippingType: 'our_delivery',
      createdAt: 'منذ 3 ساعات',
      escrowReleaseAt: 'بعد 18 ساعة',
      timeline: const [
        TimelineStep(status: 'pending', step: 'تم الدفع', time: '09:42', isDone: true),
        TimelineStep(
            status: 'processing', step: 'قيد التجهيز', time: '09:50', isDone: true),
        TimelineStep(
            status: 'shipped', step: 'استلم المندوب', time: '10:30', isDone: true),
        TimelineStep(status: 'delivered', step: 'تم التسليم', time: '11:15', isDone: true),
      ],
    ),
    SubOrderModel(
      subOrderId: '#ORD-2843',
      buyerId: 105,
      buyerName: 'Rozan Salam',
      buyerPhone: '0951234567',
      shippingAddress: 'دمشق، الشعلان',
      items: const [
        OrderItemModel(
            name: 'جلاية صحون', qty: 1, price: 22000),
      ],
      itemsTotal: 22000,
      shippingFee: 5000,
      discount: 0,
      subtotal: 27000,
      status: 'cancelled',
      shippingType: 'self_shipping',
      createdAt: 'أمس',
    ),
  ];
}

class OrderStatusConfig {
  final String labelKey;
  final Color bg;
  final Color text;
  final Color accent;

  const OrderStatusConfig({
    required this.labelKey,
    required this.bg,
    required this.text,
    required this.accent,
  });

  static final Map<String, OrderStatusConfig> map = {
    'pending': const OrderStatusConfig(
      labelKey: 'status_pending',
      bg: Color(0xffFFF3E0),
      text: Color(0xffE65100),
      accent: Color(0xffE65100),
    ),
    'processing': const OrderStatusConfig(
      labelKey: 'status_processing',
      bg: Color(0xffE3F2FD),
      text: Color(0xff1565C0),
      accent: Color(0xff1565C0),
    ),
    'shipped': const OrderStatusConfig(
      labelKey: 'status_shipped',
      bg: Color(0xffEEEDFE),
      text: Color(0xff553C9A),
      accent: Color(0xff553C9A),
    ),
    'delivered': const OrderStatusConfig(
      labelKey: 'status_delivered',
      bg: Color(0xffE8F8F0),
      text: Color(0xff1B5E20),
      accent: Color(0xff27AE60),
    ),
    'cancelled_returned': const OrderStatusConfig(
      labelKey: 'status_cancelled',
      bg: Color(0xffFEECEC),
      text: Color(0xffB71C1C),
      accent: Color(0xffE74C3C),
    ),
    'cancelled': const OrderStatusConfig(
      labelKey: 'status_cancelled',
      bg: Color(0xffFEECEC),
      text: Color(0xffB71C1C),
      accent: Color(0xffE74C3C),
    ),
    'returned': const OrderStatusConfig(
      labelKey: 'status_returned',
      bg: Color(0xffFFF8E1),
      text: Color(0xffF39C12),
      accent: Color(0xffF39C12),
    ),
  };

  static OrderStatusConfig of(String status) =>
      map[status] ?? map['pending']!;
}