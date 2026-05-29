
class DashboardStatsModel {
  final int revenue;
  final double revenueChange;
  final int ordersCount;
  final int ordersNew;
  final int storeViews;
  final double viewsChange;
  final int avgOrderValue;
  final int walletBalance;
  final int heldBalance;

  DashboardStatsModel({
    required this.revenue,
    required this.revenueChange,
    required this.ordersCount,
    required this.ordersNew,
    required this.storeViews,
    required this.viewsChange,
    required this.avgOrderValue,
    required this.walletBalance,
    required this.heldBalance,
  });

  factory DashboardStatsModel.fromJson(Map json) {
    return DashboardStatsModel(
      revenue:       json['revenue']         ?? 0,
      revenueChange: (json['revenue_change'] ?? 0).toDouble(),
      ordersCount:   json['orders_count']    ?? 0,
      ordersNew:     json['orders_new']      ?? 0,
      storeViews:    json['store_views']     ?? 0,
      viewsChange:   (json['views_change']   ?? 0).toDouble(),
      avgOrderValue: json['avg_order_value'] ?? 0,
      walletBalance: json['wallet_balance']  ?? 0,
      heldBalance:   json['held_balance']    ?? 0,
    );
  }

  factory DashboardStatsModel.mock() {
    return DashboardStatsModel(
      revenue:       124000,
      revenueChange: 18.5,
      ordersCount:   47,
      ordersNew:     3,
      storeViews:    1240,
      viewsChange:   -3.1,
      avgOrderValue: 38000,
      walletBalance: 342000,
      heldBalance:   45000,
    );
  }
}


class RecentOrderModel {
  final String subOrderId;
  final String buyerName;
  final int total;
  final String status;
  final String createdAt;

  RecentOrderModel({
    required this.subOrderId,
    required this.buyerName,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory RecentOrderModel.fromJson(Map json) {
    return RecentOrderModel(
      subOrderId: json['sub_order_id'] ?? '',
      buyerName:  json['buyer_name']   ?? '',
      total:      json['total']        ?? 0,
      status:     json['status']       ?? 'pending',
      createdAt:  json['created_at']   ?? '',
    );
  }

  static List<RecentOrderModel> mockList() {
    return [
      RecentOrderModel(subOrderId: '#ORD-2847', buyerName: 'محمد الراشد',    total: 45000, status: 'pending',    createdAt: 'منذ دقيقتين'),
      RecentOrderModel(subOrderId: '#ORD-2846', buyerName: 'سارة إبراهيم',   total: 28000, status: 'processing', createdAt: 'منذ 15 دقيقة'),
      RecentOrderModel(subOrderId: '#ORD-2845', buyerName: 'أحمد خليل',      total: 57500, status: 'shipped',    createdAt: 'منذ ساعة'),
      RecentOrderModel(subOrderId: '#ORD-2844', buyerName: 'فاطمة حسن',      total: 15000, status: 'delivered',  createdAt: 'منذ 3 ساعات'),
      RecentOrderModel(subOrderId: '#ORD-2843', buyerName: 'رانيا الأمين',   total: 32000, status: 'cancelled',  createdAt: 'أمس'),
    ];
  }
}


class SalesChartModel {
  final List<String> labels;
  final List<int> revenue;
  final List<int> orders;

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
