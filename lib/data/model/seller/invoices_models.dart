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
    vatRate:       (json['vat_rate']      ?? 0.11).toDouble(),
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
    legalName:     'شركة أحمد للحرف اليدوية',
    address:       'دمشق، المزة، شارع الزهراء، بناء 7',
    vatRate:       0.11,
    vatRegistered: true,
  );
}

// ─────────────────────────────────────────────────────────────

class InvoiceModel {
  final int    id;
  final String invoiceNumber;
  final String orderId;
  final String buyerName;
  final String buyerAddress;
  final int    subtotal;
  final int    vatAmount;
  final int    total;
  final int    commission;
  final String issuedAt;
  final String status; // issued | cancelled

  const InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.orderId,
    required this.buyerName,
    required this.buyerAddress,
    required this.subtotal,
    required this.vatAmount,
    required this.total,
    required this.commission,
    required this.issuedAt,
    required this.status,
  });

  bool get isCancelled => status == 'cancelled';
  bool get isIssued    => status == 'issued';

  factory InvoiceModel.fromJson(Map json) => InvoiceModel(
    id:            json['id']             ?? 0,
    invoiceNumber: json['invoice_number'] ?? '',
    orderId:       json['order_id']       ?? '',
    buyerName:     json['buyer_name']     ?? '',
    buyerAddress:  json['buyer_address']  ?? '',
    subtotal:      json['subtotal']       ?? 0,
    vatAmount:     json['vat_amount']     ?? 0,
    total:         json['total']          ?? 0,
    commission:    json['commission']     ?? 0,
    issuedAt:      json['issued_at']      ?? '',
    status:        json['status']         ?? 'issued',
  );

  static List<InvoiceModel> mockList() => const [
    InvoiceModel(
      id: 1, invoiceNumber: 'INV-2025-051', orderId: '#ORD-2847',
      buyerName: 'Alaa aldoos',  buyerAddress: 'دمشق، المزة',
      subtotal: 80000, vatAmount: 8800, total: 88800, commission: 8000,
      issuedAt: '05 يونيو 2025، 14:32', status: 'issued',
    ),
    InvoiceModel(
      id: 2, invoiceNumber: 'INV-2025-050', orderId: '#ORD-2846',
      buyerName: 'Sdra safar', buyerAddress: 'حلب، العزيزية',
      subtotal: 35000, vatAmount: 3850, total: 38850, commission: 3500,
      issuedAt: '04 يونيو 2025، 10:15', status: 'issued',
    ),
    InvoiceModel(
      id: 3, invoiceNumber: 'INV-2025-049', orderId: '#ORD-2845',
      buyerName: 'Ahmad almokdad', buyerAddress: 'حمص، وادي الذهب',
      subtotal: 60500, vatAmount: 6655, total: 67155, commission: 6050,
      issuedAt: '03 يونيو 2025، 16:48', status: 'issued',
    ),
    InvoiceModel(
      id: 4, invoiceNumber: 'INV-2025-048', orderId: '#ORD-2844',
      buyerName: 'maream', buyerAddress: 'دمشق، باب توما',
      subtotal: 43000, vatAmount: 4730, total: 47730, commission: 4300,
      issuedAt: '02 يونيو 2025، 09:22', status: 'issued',
    ),
    InvoiceModel(
      id: 5, invoiceNumber: 'INV-2025-047', orderId: '#ORD-2843',
      buyerName: 'Sedra', buyerAddress: 'دمشق، الشعلان',
      subtotal: 27000, vatAmount: 2970, total: 29970, commission: 2700,
      issuedAt: '01 يونيو 2025، 11:05', status: 'cancelled',
    ),
    InvoiceModel(
      id: 6, invoiceNumber: 'INV-2025-046', orderId: '#ORD-2842',
      buyerName: 'محمد علي', buyerAddress: 'دمشق، المزرعة',
      subtotal: 55000, vatAmount: 6050, total: 61050, commission: 5500,
      issuedAt: '30 مايو 2025، 13:40', status: 'issued',
    ),
    InvoiceModel(
      id: 7, invoiceNumber: 'INV-2025-045', orderId: '#ORD-2841',
      buyerName: 'سارة خالد', buyerAddress: 'حلب، الفرقان',
      subtotal: 18000, vatAmount: 1980, total: 19980, commission: 1800,
      issuedAt: '29 مايو 2025، 08:17', status: 'issued',
    ),
  ];
}

// ─────────────────────────────────────────────────────────────

class VatReportModel {
  final String monthLabel;
  final String monthKey; // YYYY-MM
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
    VatReportModel(monthLabel: 'يونيو 2025',  monthKey: '2025-06', totalSales: 318500, totalVat: 35035, invoiceCount: 5,  cancelledCount: 1),
    VatReportModel(monthLabel: 'مايو 2025',   monthKey: '2025-05', totalSales: 521000, totalVat: 57310, invoiceCount: 11, cancelledCount: 2),
    VatReportModel(monthLabel: 'أبريل 2025',  monthKey: '2025-04', totalSales: 445000, totalVat: 48950, invoiceCount: 9,  cancelledCount: 1),
    VatReportModel(monthLabel: 'مارس 2025',   monthKey: '2025-03', totalSales: 389000, totalVat: 42790, invoiceCount: 8,  cancelledCount: 0),
    VatReportModel(monthLabel: 'فبراير 2025', monthKey: '2025-02', totalSales: 290000, totalVat: 31900, invoiceCount: 6,  cancelledCount: 1),
    VatReportModel(monthLabel: 'يناير 2025',  monthKey: '2025-01', totalSales: 412000, totalVat: 45320, invoiceCount: 9,  cancelledCount: 0),
  ];
}
