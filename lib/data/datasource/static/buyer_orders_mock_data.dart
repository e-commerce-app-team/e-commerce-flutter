// lib/data/datasource/static/buyer_orders_mock_data.dart

import 'package:e_commerce/data/model/buyer/buyer_orders_model.dart';

abstract class BuyerOrdersMockData {
  static List<BuyerOrderModel> get orders => [
        _multiStoreActive,
        _shippedOrder,
        _deliveredOrder,
        _cancelledOrder,
        _returnedOrder,
      ];

  static final _multiStoreActive = BuyerOrderModel(
    id: '1001',
    orderNumber: 'ORD-78421',
    totalAmount: 214500,
    status: BuyerOrderStatus.processing,
    paymentStatus: 'paid_escrow',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    subOrders: const [
      BuyerSubOrderModel(
        id: 's1',
        sellerId: '12',
        storeName: 'متجر التقنية الحديثة',
        totalPrice: 125000,
        status: BuyerOrderStatus.processing,
        items: [
          BuyerOrderItem(
            id: 'i1',
            name: 'سماعات لاسلكية بلوتوث',
            quantity: 1,
            price: 85000,
          ),
          BuyerOrderItem(
            id: 'i2',
            name: 'شاحن USB-C سريع',
            quantity: 2,
            price: 20000,
          ),
        ],
      ),
      BuyerSubOrderModel(
        id: 's2',
        sellerId: '18',
        storeName: 'متجر الأزياء الراقية',
        totalPrice: 89500,
        status: BuyerOrderStatus.pending,
        items: [
          BuyerOrderItem(
            id: 'i3',
            name: 'قميص رجالي قطن فاخر',
            quantity: 2,
            price: 35000,
          ),
          BuyerOrderItem(
            id: 'i4',
            name: 'بنطال كلاسيكي رجالي',
            quantity: 1,
            price: 19500,
          ),
        ],
      ),
    ],
  );

  static final _shippedOrder = BuyerOrderModel(
    id: '1002',
    orderNumber: 'ORD-54879',
    totalAmount: 210000,
    status: BuyerOrderStatus.shipped,
    paymentStatus: 'paid_escrow',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    shippedAt: DateTime.now().subtract(const Duration(hours: 6)),
    subOrders: const [
      BuyerSubOrderModel(
        id: 's3',
        sellerId: '22',
        storeName: 'سوق المنزل الذكي',
        totalPrice: 210000,
        status: BuyerOrderStatus.shipped,
        items: [
          BuyerOrderItem(
            id: 'i5',
            name: 'طقم مطبخ ستانلس ستيل',
            quantity: 1,
            price: 150000,
          ),
          BuyerOrderItem(
            id: 'i6',
            name: 'مناشف قطنية فاخرة',
            quantity: 4,
            price: 15000,
          ),
        ],
      ),
    ],
  );

  static final _deliveredOrder = BuyerOrderModel(
    id: '1003',
    orderNumber: 'ORD-43100',
    totalAmount: 45000,
    status: BuyerOrderStatus.delivered,
    paymentStatus: 'released',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    shippedAt: DateTime.now().subtract(const Duration(days: 4)),
    deliveredAt: DateTime.now().subtract(const Duration(days: 3)),
    subOrders: const [
      BuyerSubOrderModel(
        id: 's4',
        sellerId: '9',
        storeName: 'متجر الجمال والعناية',
        totalPrice: 45000,
        status: BuyerOrderStatus.delivered,
        items: [
          BuyerOrderItem(
            id: 'i7',
            name: 'كريم مرطب فاخر للوجه',
            quantity: 2,
            price: 18000,
          ),
          BuyerOrderItem(
            id: 'i8',
            name: 'شامبو طبيعي بالأعشاب',
            quantity: 1,
            price: 9000,
          ),
        ],
      ),
    ],
  );

  static final _cancelledOrder = BuyerOrderModel(
    id: '1004',
    orderNumber: 'ORD-32055',
    totalAmount: 67000,
    status: BuyerOrderStatus.cancelled,
    paymentStatus: 'refunded',
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    subOrders: const [
      BuyerSubOrderModel(
        id: 's5',
        sellerId: '31',
        storeName: 'متجر الألعاب والترفيه',
        totalPrice: 67000,
        status: BuyerOrderStatus.cancelled,
        items: [
          BuyerOrderItem(
            id: 'i9',
            name: 'لعبة شطرنج خشبية فاخرة',
            quantity: 1,
            price: 67000,
          ),
        ],
      ),
    ],
  );

  static final _returnedOrder = BuyerOrderModel(
    id: '1005',
    orderNumber: 'ORD-21988',
    totalAmount: 35000,
    status: BuyerOrderStatus.returned,
    paymentStatus: 'refunded',
    createdAt: DateTime.now().subtract(const Duration(days: 11)),
    subOrders: const [
      BuyerSubOrderModel(
        id: 's6',
        sellerId: '44',
        storeName: 'متجر البقالة الطازجة',
        totalPrice: 35000,
        status: BuyerOrderStatus.returned,
        items: [
          BuyerOrderItem(
            id: 'i10',
            name: 'عسل طبيعي أصلي',
            quantity: 2,
            price: 12500,
          ),
          BuyerOrderItem(
            id: 'i11',
            name: 'زيت زيتون بكر ممتاز',
            quantity: 1,
            price: 10000,
          ),
        ],
      ),
    ],
    returnRequest: BuyerReturnRequest(
      status: BuyerReturnStatus.rejected,
      reason: 'damaged_product',
      description: 'العبوة وصلت مكسورة',
      timeline: [
        BuyerTimelineStep(
          status: 'submitted',
          title: 'submitted',
          isDone: true,
        ),
        BuyerTimelineStep(
          status: 'under_review',
          title: 'under_review',
          isDone: true,
        ),
        BuyerTimelineStep(
          status: 'rejected',
          title: 'rejected',
          isDone: true,
          isCurrent: true,
        ),
      ],
    ),
  );
}
