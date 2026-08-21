class WalletSnapshot {
  final double total;
  final double available;
  final double locked;
  final double commission;
  final double incoming;
  final double outgoing;

  const WalletSnapshot({
    required this.total,
    required this.available,
    required this.locked,
    required this.commission,
    required this.incoming,
    required this.outgoing,
  });

  factory WalletSnapshot.fromJson(Map json) => WalletSnapshot(
    total: _number(json['total_balance']),
    available: _number(json['available_balance']),
    locked: _number(json['locked_balance']),
    commission: _number(json['commission']),
    incoming: _number(json['incoming']),
    outgoing: _number(json['outgoing']),
  );

  static double _number(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ?? 0;
}

class WalletLedgerEntry {
  final int id;
  final String type;
  final String direction;
  final String status;
  final double amount;
  final String description;
  final String createdAt;
  final int? orderId;

  const WalletLedgerEntry({
    required this.id,
    required this.type,
    required this.direction,
    required this.status,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.orderId,
  });

  bool get isCredit => direction == 'credit';

  factory WalletLedgerEntry.fromJson(Map json) => WalletLedgerEntry(
    id: int.tryParse('${json['id'] ?? 0}') ?? 0,
    type: json['type']?.toString() ?? '',
    direction: json['direction']?.toString() ?? 'debit',
    status: json['status']?.toString() ?? 'completed',
    amount: WalletSnapshot._number(json['amount']),
    description: json['description']?.toString() ?? '',
    createdAt: json['created_at']?.toString() ?? '',
    orderId: int.tryParse('${json['order_id'] ?? ''}'),
  );
}

