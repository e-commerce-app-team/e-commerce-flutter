import 'dart:ui';

class OrderItemModel {
  final String name;
  final int    qty;
  final int    price;
  final String? variant;

  const OrderItemModel({
    required this.name,
    required this.qty,
    required this.price,
    this.variant,
  });

  factory OrderItemModel.fromJson(Map json) => OrderItemModel(
    name:    json['name']    ?? '',
    qty:     json['qty']     ?? 1,
    price:   json['price']   ?? 0,
    variant: json['variant'],
  );

  int get subtotal => qty * price;
}


class TimelineStep {
  final String step;
  final String time;
  final bool   isDone;

  const TimelineStep({
    required this.step,
    required this.time,
    required this.isDone,
  });
}


class SubOrderModel {
  final String subOrderId;
  final String buyerName;
  final String buyerPhone;
  final String shippingAddress;
  final List<OrderItemModel> items;
  final int    itemsTotal;
  final int    shippingFee;
  final int    discount;
  final int    subtotal;
  final String status;
  final String shippingType;
  final String createdAt;
  final String? qrToken;
  final String? estimatedReady;
  final String? escrowReleaseAt;
  final List<TimelineStep> timeline;

  const SubOrderModel({
    required this.subOrderId,
    required this.buyerName,
    required this.buyerPhone,
    required this.shippingAddress,
    required this.items,
    required this.itemsTotal,
    required this.shippingFee,
    required this.discount,
    required this.subtotal,
    required this.status,
    required this.shippingType,
    required this.createdAt,
    this.qrToken,
    this.estimatedReady,
    this.escrowReleaseAt,
    this.timeline = const [],
  });

  factory SubOrderModel.fromJson(Map json) {
    final itemsList = (json['items'] as List? ?? [])
        .map((i) => OrderItemModel.fromJson(i))
        .toList();
    final timelineList = (json['tracking_timeline'] as List? ?? [])
        .map((t) => TimelineStep(
              step:   t['step']   ?? '',
              time:   t['time']   ?? '',
              isDone: true,
            ))
        .toList();
    return SubOrderModel(
      subOrderId:      json['sub_order_id']    ?? '',
      buyerName:       json['buyer_name']       ?? '',
      buyerPhone:      json['buyer_phone']      ?? '',
      shippingAddress: json['shipping_address'] ?? '',
      items:           itemsList,
      itemsTotal:      json['items_total']      ?? 0,
      shippingFee:     json['shipping_fee']     ?? 0,
      discount:        json['discount']         ?? 0,
      subtotal:        json['subtotal']         ?? 0,
      status:          json['status']           ?? 'pending',
      shippingType:    json['shipping_type']    ?? 'delivery',
      createdAt:       json['created_at']       ?? '',
      qrToken:         json['qr_token'],
      escrowReleaseAt: json['escrow_release_at'],
      timeline:        timelineList,
    );
  }

  SubOrderModel copyWith({String? status, String? qrToken}) => SubOrderModel(
    subOrderId:      subOrderId,
    buyerName:       buyerName,
    buyerPhone:      buyerPhone,
    shippingAddress: shippingAddress,
    items:           items,
    itemsTotal:      itemsTotal,
    shippingFee:     shippingFee,
    discount:        discount,
    subtotal:        subtotal,
    status:          status ?? this.status,
    shippingType:    shippingType,
    createdAt:       createdAt,
    qrToken:         qrToken ?? this.qrToken,
    escrowReleaseAt: escrowReleaseAt,
    timeline:        timeline,
  );

  bool get isPending    => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isShipped    => status == 'shipped';
  bool get isDelivered  => status == 'delivered';
  bool get isCancelled  => status == 'cancelled';
  bool get isReturned   => status == 'returned';

  String _formatPrice(int v) =>
      v >= 1000 ? 'SP ${v ~/ 1000}k' : 'SP $v';

  String get formattedTotal => _formatPrice(subtotal);

  static List<SubOrderModel> mockList() => [
    SubOrderModel(
      subOrderId: '#ORD-2847', buyerName: 'Alaa aldoos ',
      buyerPhone: '0911234567', shippingAddress: 'دمشق، المزة، بناء 5',
      items: const [
        OrderItemModel(name: 'حقيبة جلدية', qty: 1, price: 45000, variant: 'بني'),
        OrderItemModel(name: 'إناء خزفي',   qty: 2, price: 15000),
      ],
      itemsTotal: 75000, shippingFee: 5000, discount: 0,
      subtotal: 80000, status: 'pending',
      shippingType: 'delivery', createdAt: 'منذ دقيقتين',
    ),
    SubOrderModel(
      subOrderId: '#ORD-2846', buyerName: 'soso',
      buyerPhone: '0921234567', shippingAddress: 'حلب، العزيزية',
      items: const [
        OrderItemModel(name: 'ساعة حائط خشبية', qty: 2, price: 14000),
      ],
      itemsTotal: 28000, shippingFee: 7000, discount: 0,
      subtotal: 35000, status: 'processing',
      shippingType: 'delivery', createdAt: 'منذ 15 دقيقة',
      qrToken: 'MOCK_QR_TOKEN_2846',
    ),
    SubOrderModel(
      subOrderId: '#ORD-2845', buyerName: 'alaa adf',
      buyerPhone: '0931234567', shippingAddress: 'حمص، وادي الذهب',
      items: const [
        OrderItemModel(name: 'سوار فضي',      qty: 1, price: 32000),
        OrderItemModel(name: 'طقم شموع يدوية', qty: 3, price: 8500),
      ],
      itemsTotal: 57500, shippingFee: 8000, discount: 5000,
      subtotal: 60500, status: 'shipped',
      shippingType: 'delivery', createdAt: 'منذ ساعة',
    ),
    SubOrderModel(
      subOrderId: '#ORD-2844', buyerName: 'soaad',
      buyerPhone: '0941234567', shippingAddress: 'دمشق، باب توما',
      items: const [
        OrderItemModel(name: 'مرآة إطار خشبي', qty: 1, price: 38000),
      ],
      itemsTotal: 38000, shippingFee: 5000, discount: 0,
      subtotal: 43000, status: 'delivered',
      shippingType: 'delivery', createdAt: 'منذ 3 ساعات',
      escrowReleaseAt: 'بعد 18 ساعة',
      timeline: const [
        TimelineStep(step: 'تم الدفع',      time: '09:42', isDone: true),
        TimelineStep(step: 'قيد التجهيز',   time: '09:50', isDone: true),
        TimelineStep(step: 'استلم المندوب', time: '10:30', isDone: true),
        TimelineStep(step: 'تم التسليم',    time: '11:15', isDone: true),
      ],
    ),
    SubOrderModel(
      subOrderId: '#ORD-2843', buyerName: 'rozan',
      buyerPhone: '0951234567', shippingAddress: 'دمشق، الشعلان',
      items: const [
        OrderItemModel(name: 'سلة تخزين منسوجة', qty: 1, price: 22000),
      ],
      itemsTotal: 22000, shippingFee: 5000, discount: 0,
      subtotal: 27000, status: 'cancelled',
      shippingType: 'delivery', createdAt: 'أمس',
    ),
  ];
}


class OrderStatusConfig {
  final String labelKey;
  final Color  bg;
  final Color  text;
  final Color  accent;

  const OrderStatusConfig({
    required this.labelKey,
    required this.bg,
    required this.text,
    required this.accent,
  });

  static final Map<String, OrderStatusConfig> map = {
    'pending': OrderStatusConfig(
      labelKey: 'status_pending',
      bg: Color(0xffFFF3E0), text: Color(0xffE65100),
      accent: Color(0xffE65100),
    ),
    'processing': const OrderStatusConfig(
      labelKey: 'status_processing',
      bg: Color(0xffE3F2FD), text: Color(0xff1565C0),
      accent: Color(0xff1565C0),
    ),
    'shipped': const OrderStatusConfig(
      labelKey: 'status_shipped',
      bg: Color(0xffEEEDFE), text: Color(0xff553C9A),
      accent: Color(0xff553C9A),
    ),
    'delivered': const OrderStatusConfig(
      labelKey: 'status_delivered',
      bg: Color(0xffE8F8F0), text: Color(0xff1B5E20),
      accent: Color(0xff27AE60),
    ),
    'cancelled': const OrderStatusConfig(
      labelKey: 'status_cancelled',
      bg: Color(0xffFEECEC), text: Color(0xffB71C1C),
      accent: Color(0xffE74C3C),
    ),
    'returned': const OrderStatusConfig(
      labelKey: 'status_returned',
      bg: Color(0xffFFF8E1), text: Color(0xffF39C12),
      accent: Color(0xffF39C12),
    ),
  };

  static OrderStatusConfig of(String status) =>
      map[status] ?? map['pending']!;
}
