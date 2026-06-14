import 'package:get/get.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/data/model/seller/orders_models.dart';

class SellerOrdersController extends GetxController {

  StatusRequest statusRequest       = StatusRequest.none;
  StatusRequest actionStatusRequest = StatusRequest.none;

  List<SubOrderModel> _allOrders = [];

  int selectedTab = 0;
  static const List<String?> _tabStatuses = [
    null,
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];

  List<SubOrderModel> get filteredOrders {
    final status = _tabStatuses[selectedTab];
    if (status == null) return _allOrders;
    return _allOrders.where((o) => o.status == status).toList();
  }

  void changeTab(int i) {
    selectedTab = i;
    update();
  }

  int get pendingCount    => _allOrders.where((o) => o.isPending).length;
  int get processingCount => _allOrders.where((o) => o.isProcessing).length;
  int get shippedCount    => _allOrders.where((o) => o.isShipped).length;
  int get deliveredCount  => _allOrders.where((o) => o.isDelivered).length;
  int get cancelledCount  => _allOrders.where((o) => o.isCancelled).length;


  String  searchQuery = '';
  List<SubOrderModel> get searchResults {
    if ( searchQuery.isEmpty) return filteredOrders;
    final q =  searchQuery.toLowerCase();
    return filteredOrders.where((o) =>
        o.subOrderId.toLowerCase().contains(q) ||
        o.buyerName.toLowerCase().contains(q)).toList();
  }

  void onSearch(String q) {
     searchQuery = q.trim();
    update();
  }


  Future<void> loadOrders() async {
    statusRequest = StatusRequest.loading;
    update();

    await Future.delayed(const Duration(milliseconds: 700));
    _allOrders = SubOrderModel.mockList();

    statusRequest = StatusRequest.success;
    update();
  }

  Future<void> refreshOrders() => loadOrders();

  Future<void> acceptOrder(SubOrderModel order,
      {int estimatedMinutes = 30}) async {
    actionStatusRequest = StatusRequest.loading;
    update();

    await Future.delayed(const Duration(milliseconds: 600));

    // TODO: await ordersData.acceptOrder(order.subOrderId, estimatedMinutes);

    final idx = _allOrders.indexWhere((o) => o.subOrderId == order.subOrderId);
    if (idx != -1) {
      _allOrders[idx] = order.copyWith(
        status:  'processing',
        qrToken: 'MOCK_QR_${order.subOrderId}',
      );
    }
    actionStatusRequest = StatusRequest.success;
    customSnackbar('تم القبول', 'تم قبول الطلب وتوليد رمز QR', isError: false);
    update();
  }

  Future<void> rejectOrder(SubOrderModel order, String reason) async {
    actionStatusRequest = StatusRequest.loading;
    update();

    await Future.delayed(const Duration(milliseconds: 600));

    // await ordersData.rejectOrder(order.subOrderId, reason);

    final idx = _allOrders.indexWhere((o) => o.subOrderId == order.subOrderId);
    if (idx != -1) {
      _allOrders[idx] = order.copyWith(status: 'cancelled');
    }
    actionStatusRequest = StatusRequest.success;
    customSnackbar('تم الرفض', 'تم رفض الطلب وإعادة المبلغ للمشتري',
        isError: false);
    update();
  }

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }
}
