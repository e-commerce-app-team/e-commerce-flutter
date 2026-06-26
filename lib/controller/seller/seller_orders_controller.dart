import 'package:get/get.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/data/model/seller/chat_models.dart';
import 'package:e_commerce/data/model/seller/orders_models.dart';
import 'package:e_commerce/data/datasource/remote/seller/seller_orders_data.dart';
import 'package:e_commerce/view/screen/seller/chat/chat_room_screen.dart';
import 'package:e_commerce/controller/seller/seller_chat_controller.dart';

class SellerOrdersController extends GetxController {
  final MyServices _myServices = Get.find();
  late final SellerOrdersData _ordersData;

  StatusRequest statusRequest = StatusRequest.none;
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

  String searchQuery = '';

  String get _token => _myServices.sharedPreferences.getString('token') ?? '';
  int get _sellerId =>
      int.tryParse(_myServices.sharedPreferences.getString('id') ?? '0') ?? 0;

  List<SubOrderModel> get filteredOrders {
    final status = _tabStatuses[selectedTab];
    if (status == null) return _allOrders;
    return _allOrders.where((o) => o.status == status).toList();
  }

  List<SubOrderModel> get searchResults {
    if (searchQuery.isEmpty) return filteredOrders;
    final q = searchQuery.toLowerCase();
    return filteredOrders
        .where((o) =>
    o.subOrderId.toLowerCase().contains(q) ||
        o.buyerName.toLowerCase().contains(q))
        .toList();
  }

  int get pendingCount => _allOrders.where((o) => o.isPending).length;
  int get processingCount => _allOrders.where((o) => o.isProcessing).length;
  int get shippedCount => _allOrders.where((o) => o.isShipped).length;
  int get deliveredCount => _allOrders.where((o) => o.isDelivered).length;
  int get cancelledCount => _allOrders.where((o) => o.isCancelled).length;

  void changeTab(int i) {
    selectedTab = i;
    update();
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

  Future<void> acceptOrder(
      SubOrderModel order, {
        int estimatedMinutes = 30,
      }) async {
    actionStatusRequest = StatusRequest.loading;
    update();
    await Future.delayed(const Duration(milliseconds: 600));
    final idx = _allOrders.indexWhere((o) => o.subOrderId == order.subOrderId);
    if (idx != -1) {
      _allOrders[idx] = order.copyWith(
        status: 'processing',
        qrToken: order.isOurDelivery
            ? 'QR_${order.subOrderId}_${DateTime.now().millisecondsSinceEpoch}'
            : null,
      );
    }
    actionStatusRequest = StatusRequest.success;
    update();
    if (order.isOurDelivery) {
      customSnackbar(
        'order_accept'.tr,
        'order_accept_qr_msg'.tr,
        isError: false,
      );
    } else {
      customSnackbar(
        'order_accept'.tr,
        'order_accept_self_msg'.tr,
        isError: false,
      );
    }
  }

  Future<void> rejectOrder(SubOrderModel order, String reason) async {
    actionStatusRequest = StatusRequest.loading;
    update();
    await Future.delayed(const Duration(milliseconds: 600));
    final idx = _allOrders.indexWhere((o) => o.subOrderId == order.subOrderId);
    if (idx != -1) {
      _allOrders[idx] = order.copyWith(status: 'cancelled');
    }
    actionStatusRequest = StatusRequest.success;
    customSnackbar(
      'order_reject'.tr,
      'order_reject_msg'.tr,
      isError: false,
    );
    update();
  }

  void messageBuyer(SubOrderModel order) {
    ConversationModel? existing;
    if (Get.isRegistered<SellerChatController>()) {
      final chatCtrl = Get.find<SellerChatController>();
      try {
        existing = chatCtrl.conversations
            .firstWhere((c) => c.buyerId == order.buyerId);
      } catch (_) {
        existing = null;
      }
    }
    final conversation = existing ??
        ConversationModel(
          id: 'conv_${order.buyerId}_$_sellerId',
          sellerId: _sellerId,
          buyerId: order.buyerId,
          buyerName: order.buyerName,
          orderId: order.subOrderId,
          lastMessage: '',
          lastTime: DateTime.now(),
          unreadSeller: 0,
        );
    Get.to(
          () => ChatRoomScreen(conversation: conversation),
      transition: Transition.cupertino,
    );
  }

  @override
  void onInit() {
    super.onInit();
    _ordersData = SellerOrdersData(Get.find<Crud>());
    loadOrders();
  }
}