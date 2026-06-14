class WalletModel {
  final int available;
  final int reserved;

  const WalletModel({
    required this.available,
    required this.reserved,
  });

  factory WalletModel.fromJson(Map json) => WalletModel(
        available: json['available'] ?? 0,
        reserved:  json['reserved']  ?? 0,
      );

  WalletModel copyWith({int? available, int? reserved}) => WalletModel(
        available: available ?? this.available,
        reserved:  reserved  ?? this.reserved,
      );

  static WalletModel mock() => const WalletModel(
        available: 315000,
        reserved:  82500,
      );
}

class WalletTransaction {
  final int    id;
  final String type;
  final int    amount;
  final String description;
  final String reference;
  final String date;
  final String status;

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

  factory WalletTransaction.fromJson(Map json) => WalletTransaction(
        id:          json['id']          ?? 0,
        type:        json['type']        ?? 'credit',
        amount:      json['amount']      ?? 0,
        description: json['description'] ?? '',
        reference:   json['reference']   ?? '',
        date:        json['date']        ?? '',
        status:      json['status']      ?? 'done',
      );

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
        WalletTransaction(
          id: 4, type: 'credit', amount: 38850,
          description: 'تسليم طلب ناجح',
          reference: '#ORD-2846', date: '4 يونيو 2025', status: 'done',
        ),
        WalletTransaction(
          id: 5, type: 'debit', amount: 3850,
          description: 'عمولة منصة (10%)',
          reference: '#COM-2846', date: '4 يونيو 2025', status: 'done',
        ),
        WalletTransaction(
          id: 6, type: 'debit', amount: 100000,
          description: 'سحب — تحويل بنكي',
          reference: '#WD-4798', date: '2 يونيو 2025', status: 'done',
        ),
        WalletTransaction(
          id: 7, type: 'credit', amount: 67155,
          description: 'تسليم طلب ناجح',
          reference: '#ORD-2845', date: '3 يونيو 2025', status: 'done',
        ),
        WalletTransaction(
          id: 8, type: 'credit', amount: 47730,
          description: 'تسليم طلب ناجح',
          reference: '#ORD-2844', date: '2 يونيو 2025', status: 'done',
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
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  String get methodLabel =>
      method == 'shaam_cash' ? 'شام كاش' : 'تحويل بنكي';

  factory PendingWithdrawalModel.fromJson(Map json) => PendingWithdrawalModel(
        id:          json['id']           ?? 0,
        amount:      json['amount']       ?? 0,
        method:      json['method']       ?? 'bank_transfer',
        methodInfo:  json['method_info']  ?? '',
        status:      json['status']       ?? 'pending',
        requestedAt: json['requested_at'] ?? '',
      );

  static List<PendingWithdrawalModel> mockList() => const [
        PendingWithdrawalModel(
          id:          1,
          amount:      50000,
          method:      'bank_transfer',
          methodInfo:  'بنك سورية الدولي',
          status:      'pending',
          requestedAt: 'منذ ساعتين',
        ),
      ];
}
