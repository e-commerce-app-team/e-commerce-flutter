class DashboardStatsModel {
  final int revenue;
  final double revenueChange;
  final int ordersCount;
  final int ordersNew;
  final int viewsCount;
  final double viewsChange;
  final int inventoryValue;
  final int walletBalance;
  final int heldBalance;

  DashboardStatsModel({
    required this.revenue,
    required this.revenueChange,
    required this.ordersCount,
    required this.ordersNew,
    required this.viewsCount,
    required this.viewsChange,
    required this.inventoryValue,
    required this.walletBalance,
    required this.heldBalance,
  });

  factory DashboardStatsModel.fromJson(Map json) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.round();
      if (v is String) return (double.tryParse(v) ?? 0).round();
      return 0;
    }

    return DashboardStatsModel(
      revenue:        toInt(json['revenue']),
      revenueChange:  (json['revenue_change'] ?? 0).toDouble(),
      ordersCount:    toInt(json['orders_count']),
      ordersNew:      toInt(json['orders_new']),
      viewsCount:     toInt(json['views_count']),
      viewsChange:    (json['views_change'] ?? 0).toDouble(),
      inventoryValue: toInt(json['inventory_value']),
      walletBalance:  toInt(json['wallet_balance']),
      heldBalance:    toInt(json['held_balance']),
    );
  }

  /// يُبنى من بيانات /orders/badges المتاحة على الباك
  factory DashboardStatsModel.fromBadgesJson(Map json) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.round();
      if (v is String) return (double.tryParse(v) ?? 0).round();
      return 0;
    }

    return DashboardStatsModel(
      revenue:        0,   // الباك لا يُرجع إيرادات في badges
      revenueChange:  0,
      ordersCount:    toInt(json['total']),
      ordersNew:      toInt(json['pending']),
      viewsCount:     0,
      viewsChange:    0,
      inventoryValue: 0,
      walletBalance:  0,
      heldBalance:    0,
    );
  }

  factory DashboardStatsModel.mock() {
    return DashboardStatsModel(
      revenue:        124000,
      revenueChange:  18.5,
      ordersCount:    47,
      ordersNew:      3,
      viewsCount:     1240,
      viewsChange:    -3.1,
      inventoryValue: 38000,
      walletBalance:  342000,
      heldBalance:    45000,
    );
  }
}


/// يُمثّل طلباً مختصراً للعرض في بطاقات الداشبورد
class RecentOrderModel {
  final String subOrderId;
  final int    rawId;      // الـ ID الحقيقي للإرسال للباك
  final String buyerName;
  final int    total;
  final String status;
  final String createdAt;

  RecentOrderModel({
    required this.subOrderId,
    required this.rawId,
    required this.buyerName,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory RecentOrderModel.fromJson(Map json) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.round();
      if (v is String) return (double.tryParse(v) ?? 0).round();
      return 0;
    }

    final buyerMap = json['buyer'] is Map ? json['buyer'] as Map : null;
    final buyerName = buyerMap != null
        ? '${buyerMap['first_name'] ?? ''} ${buyerMap['last_name'] ?? ''}'.trim()
        : (json['buyer_name']?.toString() ?? '');

    final rawId = toInt(json['id']);

    return RecentOrderModel(
      subOrderId: rawId > 0 ? '#ORD-$rawId' : (json['sub_order_id']?.toString() ?? ''),
      rawId:      rawId,
      buyerName:  buyerName,
      total:      toInt(json['total_price']),
      status:     json['status']?.toString() ?? 'pending',
      createdAt:  _relativeTime(json['created_at']?.toString()),
    );
  }

  static String _relativeTime(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'الآن';
      if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
      if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
      return 'منذ ${diff.inDays} يوم';
    } catch (_) {
      return raw ?? '';
    }
  }

  static List<RecentOrderModel> mockList() {
    return [
      RecentOrderModel(subOrderId: '#ORD-2847', rawId: 2847, buyerName: 'Alaa aldoos',    total: 45000, status: 'pending',    createdAt: 'منذ دقيقتين'),
      RecentOrderModel(subOrderId: '#ORD-2846', rawId: 2846, buyerName: 'Sdra safar',      total: 28000, status: 'processing', createdAt: 'منذ 15 دقيقة'),
      RecentOrderModel(subOrderId: '#ORD-2845', rawId: 2845, buyerName: 'Ahmad almokdad', total: 57500, status: 'shipped',    createdAt: 'منذ ساعة'),
    ];
  }
}


class SalesChartModel {
  final List<String> labels;
  final List<int>    revenue;
  final List<int>    orders;

  SalesChartModel({
    required this.labels,
    required this.revenue,
    required this.orders,
  });

  factory SalesChartModel.fromJson(Map json) {
    return SalesChartModel(
      labels:  List<String>.from(json['labels']  ?? []),
      revenue: List<int>.from(json['revenue']?.map((v) => v as int) ?? []),
      orders:  List<int>.from(json['orders']?.map((v) => v as int)  ?? []),
    );
  }

  factory SalesChartModel.mock() {
    return SalesChartModel(
      labels:  ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'],
      revenue: [45000, 62000, 38000, 89000, 55000, 112000, 72000],
      orders:  [3, 5, 2, 7, 4, 9, 5],
    );
  }

  int get totalRevenue => revenue.fold(0, (a, b) => a + b);
  int get maxRevenue   => revenue.isEmpty ? 1 : revenue.reduce((a, b) => a > b ? a : b);
}
