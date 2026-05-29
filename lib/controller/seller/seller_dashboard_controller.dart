import 'package:get/get.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/data/model/seller/dashboard_models.dart';

class SellerDashboardController extends GetxController {
  StatusRequest statusRequest = StatusRequest.none;

  DashboardStatsModel? stats;
  SalesChartModel?     chartData;
  List<RecentOrderModel> recentOrders = [];

  String selectedPeriod = 'today';
  final List<String> periods = ['today', 'weekly', 'monthly'];

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



    await Future.delayed(const Duration(milliseconds: 800));

    stats       = DashboardStatsModel.mock();
    chartData   = SalesChartModel.mock();
    recentOrders = RecentOrderModel.mockList();

    statusRequest = StatusRequest.success;
    update();
  }

  void acceptOrder(String orderId) {
    final idx = recentOrders.indexWhere((o) => o.subOrderId == orderId);
    if (idx != -1) {
      recentOrders[idx] = RecentOrderModel(
        subOrderId: recentOrders[idx].subOrderId,
        buyerName:  recentOrders[idx].buyerName,
        total:      recentOrders[idx].total,
        status:     'processing',
        createdAt:  recentOrders[idx].createdAt,
      );
      update();
    }
  }

  void rejectOrder(String orderId) {
    recentOrders.removeWhere((o) => o.subOrderId == orderId);
    update();
  }


  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }
}
