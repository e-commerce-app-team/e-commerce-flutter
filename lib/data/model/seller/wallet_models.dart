/// WalletModel - يُبنى من استجابة GET /balance
/// { total_balance, locked_balance, available_balance, payout_method, payout_account }
class WalletModel {
  final int available; // available_balance  (قابل للسحب)
  final int reserved;  // locked_balance     (محجوز بالضمان)
  final int total;     // total_balance      (الكلي)
  final String? payoutMethod;
  final String? payoutAccount;

  const WalletModel({
    required this.available,
    required this.reserved,
    required this.total,
    this.payoutMethod,
    this.payoutAccount,
  });

  factory WalletModel.fromJson(Map json) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.round();
      if (v is String) return (double.tryParse(v) ?? 0).round();
      return 0;
    }

    return WalletModel(
      available:     toInt(json['available_balance']),
      reserved:      toInt(json['locked_balance']),
      total:         toInt(json['total_balance']),
      payoutMethod:  json['payout_method']?.toString(),
      payoutAccount: json['payout_account']?.toString(),
    );
  }

  WalletModel copyWith({int? available, int? reserved, int? total}) => WalletModel(
        available:     available     ?? this.available,
        reserved:      reserved      ?? this.reserved,
        total:         total         ?? this.total,
        payoutMethod:  payoutMethod,
        payoutAccount: payoutAccount,
      );

  static WalletModel mock() => const WalletModel(
        available: 315000,
        reserved:  82500,
        total:     397500,
      );
}

/// WalletTransaction - يُبنى من عنصر في استجابة GET /history (PayoutRequest)
/// كل عنصر: { id, user_id, amount, payout_method, payout_account,
///             sham_code, qr_image, status, admin_notes, created_at }
class WalletTransaction {
  final int    id;
  final String type;        // 'debit' دائماً (سحب)
  final int    amount;
  final String description; // نُبنيها من payout_method
  final String reference;   // رقم الطلب
  final String date;
  final String status;      // pending / completed / rejected

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.reference,
    required this.date,
    required this.status,
  });

  bool get isCredit => type == 'credit';

  factory WalletTransaction.fromPayoutJson(Map json) {
    final method = json['payout_method']?.toString() ?? '';
    final desc = method == 'sham cash'
        ? 'سحب - شام كاش'
        : method == 'bank account'
            ? 'سحب - تحويل بنكي'
            : 'طلب سحب';

    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.round();
      if (v is String) return (double.tryParse(v) ?? 0).round();
      return 0;
    }

    return WalletTransaction(
      id:          json['id'] ?? 0,
      type:        'debit',
      amount:      toInt(json['amount']),
      description: desc,
      reference:   '#WD-${json['id'] ?? 0}',
      date:        _formatDate(json['created_at']?.toString()),
      status:      json['status']?.toString() ?? 'pending',
    );
  }

  /// للعمليات المحلية المؤقتة (بعد submit ناجح)
  factory WalletTransaction.fromJson(Map json) => WalletTransaction(
        id:          json['id']          ?? 0,
        type:        json['type']        ?? 'debit',
        amount:      json['amount']      ?? 0,
        description: json['description'] ?? '',
        reference:   json['reference']   ?? '',
        date:        json['date']        ?? '',
        status:      json['status']      ?? 'pending',
      );

  static String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  static List<WalletTransaction> mockList() => const [
        WalletTransaction(
          id: 1, type: 'debit', amount: 50000,
          description: 'طلب سحب — شام كاش',
          reference: '#WD-4821', date: 'منذ ساعتين', status: 'pending',
        ),
        WalletTransaction(
          id: 2, type: 'credit', amount: 88800,
          description: 'تسليم طلب ناجح',
          reference: '#ORD-2847', date: '5 يونيو 2025', status: 'done',
        ),
        WalletTransaction(
          id: 3, type: 'debit', amount: 8800,
          description: 'عمولة منصة (10%)',
          reference: '#COM-2847', date: '5 يونيو 2025', status: 'done',
        ),
      ];
}

class WalletStatsModel {
  final int receivedThisMonth;
  final int commissionThisMonth;
  final int withdrawnThisMonth;

  const WalletStatsModel({
    required this.receivedThisMonth,
    required this.commissionThisMonth,
    required this.withdrawnThisMonth,
  });

  factory WalletStatsModel.fromJson(Map json) => WalletStatsModel(
        receivedThisMonth:   json['received_this_month']   ?? 0,
        commissionThisMonth: json['commission_this_month'] ?? 0,
        withdrawnThisMonth:  json['withdrawn_this_month']  ?? 0,
      );

  static WalletStatsModel mock() => const WalletStatsModel(
        receivedThisMonth:   195000,
        commissionThisMonth: 19500,
        withdrawnThisMonth:  100000,
      );
}

class PendingWithdrawalModel {
  final int    id;
  final int    amount;
  final String method;
  final String methodInfo;
  final String status;
  final String requestedAt;

  const PendingWithdrawalModel({
    required this.id,
    required this.amount,
    required this.method,
    required this.methodInfo,
    required this.status,
    required this.requestedAt,
  });

  bool get isPending  => status == 'pending';
  bool get isApproved => status == 'completed';
  bool get isRejected => status == 'rejected';

  String get methodLabel =>
      method == 'sham cash' ? 'شام كاش' : 'تحويل بنكي';

  factory PendingWithdrawalModel.fromPayoutJson(Map json) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.round();
      if (v is String) return (double.tryParse(v) ?? 0).round();
      return 0;
    }

    return PendingWithdrawalModel(
      id:          json['id']             ?? 0,
      amount:      toInt(json['amount']),
      method:      json['payout_method']  ?? 'bank account',
      methodInfo:  json['payout_account'] ?? json['sham_code'] ?? '',
      status:      json['status']         ?? 'pending',
      requestedAt: WalletTransaction._formatDate(json['created_at']?.toString()),
    );
  }

  factory PendingWithdrawalModel.fromJson(Map json) => PendingWithdrawalModel(
        id:          json['id']           ?? 0,
        amount:      json['amount']       ?? 0,
        method:      json['method']       ?? 'bank account',
        methodInfo:  json['method_info']  ?? '',
        status:      json['status']       ?? 'pending',
        requestedAt: json['requested_at'] ?? '',
      );

  static List<PendingWithdrawalModel> mockList() => const [
        PendingWithdrawalModel(
          id:          1,
          amount:      50000,
          method:      'bank account',
          methodInfo:  'بنك سورية الدولي',
          status:      'pending',
          requestedAt: 'منذ ساعتين',
        ),
      ];
}
