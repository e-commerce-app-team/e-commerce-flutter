import 'package:get/get.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/data/datasource/remote/seller/seller_dashboard_data.dart';
import 'package:e_commerce/data/datasource/remote/seller/seller_orders_data.dart';
import 'package:e_commerce/data/model/seller/dashboard_models.dart';

class SellerDashboardController extends GetxController {
  final MyServices _myServices = Get.find();
  late final SellerDashboardData  _dashData;
  late final SellerOrdersData     _ordersData;

  StatusRequest statusRequest = StatusRequest.none;

  DashboardStatsModel?       stats;
  SalesChartModel?           chartData;
  List<RecentOrderModel>     recentOrders = [];

  String selectedPeriod = 'today';
  final List<String> periods = ['today', 'weekly', 'monthly'];

  String get _token => _myServices.sharedPreferences.getString('token') ?? '';

  void changePeriod(String period) {
    selectedPeriod = period;
    loadDashboard();
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning'.tr;
    if (hour < 17) return 'good_afternoon'.tr;
    return 'good_evening'.tr;
  }

  Future<void> loadDashboard() async {
    statusRequest = StatusRequest.loading;
    update();

    // ─── 1. جلب إحصائيات الطلبات من /orders/badges ────────────────────────
    // هذا الـ endpoint موجود فعلاً على الباك ويُرجع عدد الطلبات بكل حالة
    final badgesResult = await _dashData.getOrderBadges(_token);
    badgesResult.fold(
      (failure) {
        // في حال الفشل نستخدم mock لإحصائيات الـ stats
        stats     = DashboardStatsModel.mock();
        chartData = SalesChartModel.mock();
      },
      (data) {
        // نبني stats من بيانات الـ badges المتاحة + mock للإيرادات والمشاهدات
        // (الباك لم ينفّذ endpoints الإيرادات/المشاهدات بعد)
        final badgesStats = DashboardStatsModel.fromBadgesJson(data);
        stats = DashboardStatsModel(
          revenue:        DashboardStatsModel.mock().revenue,        // mock - pending backend
          revenueChange:  DashboardStatsModel.mock().revenueChange,  // mock - pending backend
          ordersCount:    badgesStats.ordersCount,  // حقيقي من /orders/badges
          ordersNew:      badgesStats.ordersNew,    // حقيقي من /orders/badges
          viewsCount:     DashboardStatsModel.mock().viewsCount,     // mock - pending backend
          viewsChange:    DashboardStatsModel.mock().viewsChange,    // mock - pending backend
          inventoryValue: DashboardStatsModel.mock().inventoryValue, // mock - pending backend
          walletBalance:  DashboardStatsModel.mock().walletBalance,  // mock - pending backend
          heldBalance:    DashboardStatsModel.mock().heldBalance,    // mock - pending backend
        );
        chartData = SalesChartModel.mock(); // mock - pending backend
      },
    );

    // ─── 2. جلب أحدث الطلبات من /my-orders ──────────────────────────────
    final ordersResult = await _dashData.getRecentOrders(_token);
    ordersResult.fold(
      (failure) {
        // في حال الفشل نُبقي قائمة فارغة
        recentOrders = [];
      },
      (data) {
        try {
          final rawData = data['data'];
          final List rawList = rawData is Map
              ? ((rawData['data'] as List?) ?? [])
              : ((rawData as List?) ?? []);

          recentOrders = rawList
              .map((o) => RecentOrderModel.fromJson(o as Map))
              .toList();
        } catch (e) {
          recentOrders = [];
        }
      },
    );

    statusRequest = StatusRequest.success;
    update();
  }

  /// قبول طلب من بطاقة الداشبورد
  void acceptOrder(String orderId) async {
    final idx = recentOrders.indexWhere((o) => o.subOrderId == orderId);
    if (idx == -1) return;

    final order = recentOrders[idx];
    final result = await _ordersData.acceptOrder(
      orderId: order.rawId,
      token:   _token,
    );

    result.fold(
      (_) => customSnackbar('error'.tr, 'server_error'.tr),
      (res) {
        if (res['success'] == true) {
          recentOrders[idx] = RecentOrderModel(
            subOrderId: order.subOrderId,
            rawId:      order.rawId,
            buyerName:  order.buyerName,
            total:      order.total,
            status:     'processing',
            createdAt:  order.createdAt,
          );
          update();
          customSnackbar('order_accept'.tr, 'order_accept_msg'.tr, isError: false);
        } else {
          customSnackbar('warning'.tr, (res['message'] ?? '').toString());
        }
      },
    );
  }

  /// رفض طلب من بطاقة الداشبورد
  void rejectOrder(String orderId) async {
    final idx = recentOrders.indexWhere((o) => o.subOrderId == orderId);
    if (idx == -1) return;

    final order = recentOrders[idx];
    final result = await _ordersData.rejectOrder(
      orderId: order.rawId,
      reason:  'رُفض من داشبورد البائع',
      token:   _token,
    );

    result.fold(
      (_) => customSnackbar('error'.tr, 'server_error'.tr),
      (res) {
        if (res['success'] == true) {
          recentOrders.removeAt(idx);
          update();
          customSnackbar('order_reject'.tr, 'order_reject_msg'.tr, isError: false);
        } else {
          customSnackbar('warning'.tr, (res['message'] ?? '').toString());
        }
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
    _dashData   = SellerDashboardData(Get.find<Crud>());
    _ordersData = SellerOrdersData(Get.find<Crud>());
    loadDashboard();
  }
}
