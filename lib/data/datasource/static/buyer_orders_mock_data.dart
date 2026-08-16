// lib/data/datasource/static/buyer_orders_mock_data.dart
// TODO: Remove once real API is wired in BuyerOrdersController.

import 'package:e_commerce/data/model/buyer/buyer_orders_model.dart';

abstract class BuyerOrdersMockData {
  static final List<BuyerOrderModel> orders = [
    // ── 1. Pending ────────────────────────────────────────────────────────────
    BuyerOrderModel(
      id: '1',
      orderNumber: 'ORD-78421',
      storeName: 'متجر التقنية الحديثة',
      storeLogoUrl: '',
      totalAmount: 125000,
      status: BuyerOrderStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      items: const [
        BuyerOrderItem(
          id: 'i1',
          name: 'سماعات لاسلكية بلوتوث',
          quantity: 1,
          price: 85000,
          imageUrl: '',
        ),
        BuyerOrderItem(
          id: 'i2',
          name: 'شاحن USB-C سريع',
          quantity: 2,
          price: 20000,
          imageUrl: '',
        ),
      ],
    ),

    // ── 2. Processing ─────────────────────────────────────────────────────────
    BuyerOrderModel(
      id: '2',
      orderNumber: 'ORD-65312',
      storeName: 'متجر الأزياء الراقية',
      storeLogoUrl: '',
      totalAmount: 89500,
      status: BuyerOrderStatus.processing,
      createdAt: DateTime.now().subtract(const Duration(hours: 26)),
      items: const [
        BuyerOrderItem(
          id: 'i3',
          name: 'قميص رجالي قطن فاخر',
          quantity: 2,
          price: 35000,
          imageUrl: '',
        ),
        BuyerOrderItem(
          id: 'i4',
          name: 'بنطال كلاسيكي رجالي',
          quantity: 1,
          price: 19500,
          imageUrl: '',
        ),
      ],
    ),

    // ── 3. Shipped ────────────────────────────────────────────────────────────
    BuyerOrderModel(
      id: '3',
      orderNumber: 'ORD-54879',
      storeName: 'سوق المنزل الذكي',
      storeLogoUrl: '',
      totalAmount: 210000,
      status: BuyerOrderStatus.shipped,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      trackingNumber: 'SYP-2024-8874',
      items: const [
        BuyerOrderItem(
          id: 'i5',
          name: 'طقم مطبخ ستانلس ستيل',
          quantity: 1,
          price: 150000,
          imageUrl: '',
        ),
        BuyerOrderItem(
          id: 'i6',
          name: 'مناشف قطنية فاخرة',
          quantity: 4,
          price: 15000,
          imageUrl: '',
        ),
      ],
    ),

    // ── 4. Delivered ──────────────────────────────────────────────────────────
    BuyerOrderModel(
      id: '4',
      orderNumber: 'ORD-43100',
      storeName: 'متجر الجمال والعناية',
      storeLogoUrl: '',
      totalAmount: 45000,
      status: BuyerOrderStatus.delivered,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      items: const [
        BuyerOrderItem(
          id: 'i7',
          name: 'كريم مرطب فاخر للوجه',
          quantity: 2,
          price: 18000,
          imageUrl: '',
        ),
        BuyerOrderItem(
          id: 'i8',
          name: 'شامبو طبيعي بالأعشاب',
          quantity: 1,
          price: 9000,
          imageUrl: '',
        ),
      ],
    ),

    // ── 5. Cancelled ──────────────────────────────────────────────────────────
    BuyerOrderModel(
      id: '5',
      orderNumber: 'ORD-32055',
      storeName: 'متجر الألعاب والترفيه',
      storeLogoUrl: '',
      totalAmount: 67000,
      status: BuyerOrderStatus.cancelled,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      items: const [
        BuyerOrderItem(
          id: 'i9',
          name: 'لعبة شطرنج خشبية فاخرة',
          quantity: 1,
          price: 67000,
          imageUrl: '',
        ),
      ],
    ),

    // ── 6. Returned ───────────────────────────────────────────────────────────
    BuyerOrderModel(
      id: '6',
      orderNumber: 'ORD-21988',
      storeName: 'متجر البقالة الطازجة',
      storeLogoUrl: '',
      totalAmount: 35000,
      status: BuyerOrderStatus.returned,
      createdAt: DateTime.now().subtract(const Duration(days: 11)),
      items: const [
        BuyerOrderItem(
          id: 'i10',
          name: 'عسل طبيعي أصلي',
          quantity: 2,
          price: 12500,
          imageUrl: '',
        ),
        BuyerOrderItem(
          id: 'i11',
          name: 'زيت زيتون بكر ممتاز',
          quantity: 1,
          price: 10000,
          imageUrl: '',
        ),
      ],
    ),
  ];
}

