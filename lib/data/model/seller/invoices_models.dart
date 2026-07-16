// ─── Invoice Type Enum ────────────────────────────────────────────────────────
enum InvoiceType { order, commission }

// ─── Tax Settings (seller info display) ──────────────────────────────────────

class TaxSettingsModel {
  final String? vatNumber;
  final String? crNumber;
  final String  legalName;
  final String  address;
  final double  vatRate;
  final bool    vatRegistered;

  const TaxSettingsModel({
    this.vatNumber,
    this.crNumber,
    required this.legalName,
    required this.address,
    required this.vatRate,
    required this.vatRegistered,
  });

  bool get isComplete =>
      vatNumber != null && vatNumber!.isNotEmpty &&
      crNumber  != null && crNumber!.isNotEmpty &&
      legalName.isNotEmpty;

  factory TaxSettingsModel.fromJson(Map json) => TaxSettingsModel(
    vatNumber:     json['vat_number'],
    crNumber:      json['cr_number'],
    legalName:     json['legal_name']     ?? '',
    address:       json['address']        ?? '',
    vatRate:       (json['vat_rate']      ?? 5.0).toDouble(),
    vatRegistered: json['vat_registered'] ?? false,
  );

  TaxSettingsModel copyWith({
    String? vatNumber,
    String? crNumber,
    String? legalName,
    String? address,
  }) => TaxSettingsModel(
    vatNumber:    vatNumber  ?? this.vatNumber,
    crNumber:     crNumber   ?? this.crNumber,
    legalName:    legalName  ?? this.legalName,
    address:      address    ?? this.address,
    vatRate:      vatRate,
    vatRegistered: vatRegistered,
  );

  static TaxSettingsModel mock() => const TaxSettingsModel(
    vatNumber:     '300123456789012',
    crNumber:      '1234567890',
    legalName:     'شركة علاء',
    address:       'دمشق، المزة',
    vatRate:       5.0,
    vatRegistered: true,
  );
}

// ─── Tax Breakdown Item (per product line) ────────────────────────────────────

class TaxBreakdownItem {
  final int    productId;
  final String productName;
  final int    quantity;
  final double unitPrice;
  final double taxRate;    // e.g. 5.0, 10.0, 0.0
  final double taxAmount;
  final bool   taxExempt;

  const TaxBreakdownItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.taxRate,
    required this.taxAmount,
    required this.taxExempt,
  });

  factory TaxBreakdownItem.fromJson(Map json) => TaxBreakdownItem(
    productId:   json['product_id']   ?? 0,
    productName: json['product_name'] ?? '',
    quantity:    json['quantity']     ?? 1,
    unitPrice:   (json['unit_price']  ?? 0).toDouble(),
    taxRate:     (json['tax_rate']    ?? 0).toDouble(),
    taxAmount:   (json['tax_amount']  ?? 0).toDouble(),
    taxExempt:   json['tax_exempt']   ?? false,
  );
}

// ─── Order Tax Summary ────────────────────────────────────────────────────────

class OrderTaxSummary {
  final double subtotalBeforeTax;
  final double taxAmount;
  final double discountAmount;
  final double finalTotal;
  final double platformCommission;
  final double commissionRate;
  final List<TaxBreakdownItem> breakdown;

  const OrderTaxSummary({
    required this.subtotalBeforeTax,
    required this.taxAmount,
    required this.discountAmount,
    required this.finalTotal,
    required this.platformCommission,
    required this.commissionRate,
    required this.breakdown,
  });

  double get netSellerAmount => finalTotal - platformCommission;

  factory OrderTaxSummary.fromJson(Map json) => OrderTaxSummary(
    subtotalBeforeTax:  (json['subtotal_before_tax']        ?? 0).toDouble(),
    taxAmount:          (json['tax_amount']                  ?? 0).toDouble(),
    discountAmount:     (json['discount_amount']             ?? 0).toDouble(),
    finalTotal:         (json['total_price']                 ?? 0).toDouble(),
    platformCommission: (json['platform_commission']         ?? 0).toDouble(),
    commissionRate:     (json['commission_rate_snapshot']    ?? 0).toDouble(),
    breakdown: (json['tax_breakdown'] as List? ?? [])
        .map((e) => TaxBreakdownItem.fromJson(e as Map))
        .toList(),
  );
}

// ─── Invoice Model ────────────────────────────────────────────────────────────

class InvoiceModel {
  final int     id;
  final String  invoiceNumber;
  final int?    orderId;
  final String  type;        // 'order' | 'commission'
  final String? sellerName;
  final String? sellerTaxNumber;
  final String? sellerCr;
  final double  subtotal;
  final double  vatAmount;
  final double  commissionAmount;
  final double  total;
  final String  status;      // 'issued' | 'cancelled'
  final String? notes;
  final String  createdAt;
  final List<TaxBreakdownItem> lineItems;

  // ── Legacy fields kept for backward compat with existing UI screens ──
  /// The order reference shown in old UI. Falls back to orderId string.
  String get orderRef => orderId != null ? '#ORD-$orderId' : '';
  /// Alias used by old UI screens (buyerName → sellerName for order invoices).
  String get buyerName => sellerName ?? '';
  String get buyerAddress => '';
  /// Old int-style amounts (rounded); existing widgets that used int amounts work.
  int get subtotalInt      => subtotal.round();
  int get vatAmountInt     => vatAmount.round();
  int get totalInt         => total.round();
  int get commissionInt    => commissionAmount.round();
  /// issuedAt alias (createdAt).
  String get issuedAt => createdAt;

  const InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    this.orderId,
    required this.type,
    this.sellerName,
    this.sellerTaxNumber,
    this.sellerCr,
    required this.subtotal,
    required this.vatAmount,
    required this.commissionAmount,
    required this.total,
    required this.status,
    this.notes,
    required this.createdAt,
    this.lineItems = const [],
  });

  bool get isOrderInvoice      => type == 'order';
  bool get isCommissionInvoice => type == 'commission';
  bool get isCancelled         => status == 'cancelled';
  bool get isIssued            => status == 'issued';

  InvoiceType get invoiceType =>
      type == 'commission' ? InvoiceType.commission : InvoiceType.order;

  factory InvoiceModel.fromJson(Map json) => InvoiceModel(
    id:               json['id']                ?? 0,
    invoiceNumber:    json['invoice_number']    ?? '',
    orderId:          json['order_id'] is int
        ? json['order_id']
        : int.tryParse(json['order_id']?.toString() ?? ''),
    type:             json['type']              ?? 'order',
    sellerName:       json['seller_name']?.toString(),
    sellerTaxNumber:  json['seller_tax_number']?.toString(),
    sellerCr:         json['seller_cr']?.toString(),
    subtotal:         (json['subtotal']          ?? 0).toDouble(),
    vatAmount:        (json['vat_amount']         ?? 0).toDouble(),
    commissionAmount: (json['commission_amount']  ?? 0).toDouble(),
    total:            (json['total']              ?? 0).toDouble(),
    status:           json['status']             ?? 'issued',
    notes:            json['notes']?.toString(),
    createdAt:        json['created_at']?.toString() ?? '',
    lineItems:        (json['line_items'] as List? ?? [])
        .map((e) => TaxBreakdownItem.fromJson(e as Map))
        .toList(),
  );

  // ── Legacy mock data (backward compat) ──────────────────────────────────────
  static List<InvoiceModel> mockList() => const [
    InvoiceModel(
      id: 1, invoiceNumber: 'INV-2025-051', orderId: 2847, type: 'order',
      sellerName: 'Alaa aldoos',
      subtotal: 80000, vatAmount: 4000, commissionAmount: 8000, total: 84000,
      createdAt: '05 يونيو 2025، 14:32', status: 'issued',
    ),
    InvoiceModel(
      id: 2, invoiceNumber: 'INV-2025-050', orderId: 2846, type: 'order',
      sellerName: 'Sdra safar',
      subtotal: 35000, vatAmount: 1750, commissionAmount: 3500, total: 36750,
      createdAt: '04 يونيو 2025، 10:15', status: 'issued',
    ),
    InvoiceModel(
      id: 3, invoiceNumber: 'COM-2025-049', type: 'commission',
      sellerName: 'Ahmad almokdad',
      subtotal: 60500, vatAmount: 0, commissionAmount: 6050, total: 6050,
      createdAt: '03 يونيو 2025، 16:48', status: 'issued',
    ),
    InvoiceModel(
      id: 4, invoiceNumber: 'INV-2025-048', orderId: 2844, type: 'order',
      sellerName: 'maream',
      subtotal: 43000, vatAmount: 2150, commissionAmount: 4300, total: 45150,
      createdAt: '02 يونيو 2025، 09:22', status: 'issued',
    ),
    InvoiceModel(
      id: 5, invoiceNumber: 'INV-2025-047', orderId: 2843, type: 'order',
      sellerName: 'Sedra',
      subtotal: 27000, vatAmount: 1350, commissionAmount: 2700, total: 28350,
      createdAt: '01 يونيو 2025، 11:05', status: 'cancelled',
    ),
  ];
}

// ─── Tax Report Model ─────────────────────────────────────────────────────────

class TaxReportModel {
  final int    month;
  final int    year;
  final double totalSalesBeforeTax;
  final double totalTaxCollected;
  final int    orderInvoiceCount;
  final double totalCommissionPaid;
  final int    commissionCount;

  const TaxReportModel({
    required this.month,
    required this.year,
    required this.totalSalesBeforeTax,
    required this.totalTaxCollected,
    required this.orderInvoiceCount,
    required this.totalCommissionPaid,
    required this.commissionCount,
  });

  factory TaxReportModel.fromJson(Map json) {
    final report = json['report'] as Map? ?? {};
    final period = json['period'] as Map? ?? {};
    return TaxReportModel(
      month:               period['month'] ?? DateTime.now().month,
      year:                period['year']  ?? DateTime.now().year,
      totalSalesBeforeTax: (report['total_sales_before_tax'] ?? 0).toDouble(),
      totalTaxCollected:   (report['total_tax_collected']    ?? 0).toDouble(),
      orderInvoiceCount:    report['order_invoice_count']    ?? 0,
      totalCommissionPaid: (report['total_commission_paid']  ?? 0).toDouble(),
      commissionCount:      report['commission_count']       ?? 0,
    );
  }

  /// Convenience mock for empty / fallback state.
  static TaxReportModel mock() => TaxReportModel(
    month: DateTime.now().month,
    year:  DateTime.now().year,
    totalSalesBeforeTax: 0,
    totalTaxCollected:   0,
    orderInvoiceCount:   0,
    totalCommissionPaid: 0,
    commissionCount:     0,
  );
}

// ─── VAT Report Model (backward compat — keeps mockList used by old screens) ──

class VatReportModel {
  final String monthLabel;
  final String monthKey;
  final int    totalSales;
  final int    totalVat;
  final int    invoiceCount;
  final int    cancelledCount;

  const VatReportModel({
    required this.monthLabel,
    required this.monthKey,
    required this.totalSales,
    required this.totalVat,
    required this.invoiceCount,
    required this.cancelledCount,
  });

  factory VatReportModel.fromJson(Map json) => VatReportModel(
    monthLabel:     json['month_label']     ?? '',
    monthKey:       json['month_key']       ?? '',
    totalSales:     json['total_sales']     ?? 0,
    totalVat:       json['total_vat']       ?? 0,
    invoiceCount:   json['invoice_count']   ?? 0,
    cancelledCount: json['cancelled_count'] ?? 0,
  );

  static List<VatReportModel> mockList() => const [
    VatReportModel(monthLabel: 'يونيو 2025',  monthKey: '2025-06', totalSales: 318500, totalVat: 15925, invoiceCount: 5,  cancelledCount: 1),
    VatReportModel(monthLabel: 'مايو 2025',   monthKey: '2025-05', totalSales: 521000, totalVat: 26050, invoiceCount: 11, cancelledCount: 2),
    VatReportModel(monthLabel: 'أبريل 2025',  monthKey: '2025-04', totalSales: 445000, totalVat: 22250, invoiceCount: 9,  cancelledCount: 1),
    VatReportModel(monthLabel: 'مارس 2025',   monthKey: '2025-03', totalSales: 389000, totalVat: 19450, invoiceCount: 8,  cancelledCount: 0),
    VatReportModel(monthLabel: 'فبراير 2025', monthKey: '2025-02', totalSales: 290000, totalVat: 14500, invoiceCount: 6,  cancelledCount: 1),
    VatReportModel(monthLabel: 'يناير 2025',  monthKey: '2025-01', totalSales: 412000, totalVat: 20600, invoiceCount: 9,  cancelledCount: 0),
  ];
}
