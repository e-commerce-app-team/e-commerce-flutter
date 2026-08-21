import 'package:get/get.dart';
import 'package:dartz/dartz.dart';
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

  String searchQuery = '';

  String get _token => _myServices.sharedPreferences.getString('token') ?? '';
  int get _sellerId =>
      int.tryParse(_myServices.sharedPreferences.getString('id') ?? '0') ?? 0;

  List<SubOrderModel> get filteredOrders {
    return _allOrders.where((order) {
      switch (selectedTab) {
        case 1:
          return order.isPending &&
              (order.isShippingQuotePending || order.canStartPreparation);
        case 2:
          return order.isPending && order.isAwaitingBuyerApproval;
        case 3:
          return order.isPending && order.isAwaitingPayment;
        case 4:
          return order.isProcessing && order.shipmentState == 'pending';
        case 5:
          return order.isProcessing &&
              order.shipmentState == 'ready_for_shipping';
        case 6:
          return order.isShipped && order.escrowReleaseAt == null;
        case 7:
          return order.isShipped && order.escrowReleaseAt != null;
        case 8:
          return order.isDelivered;
        case 9:
          return order.isCancelled || order.isReturned;
        default:
          return true;
      }
    }).toList();
  }

  List<SubOrderModel> get searchResults {
    if (searchQuery.isEmpty) return filteredOrders;
    final q = searchQuery.toLowerCase();
    return filteredOrders
        .where(
          (o) =>
              o.subOrderId.toLowerCase().contains(q) ||
              o.buyerName.toLowerCase().contains(q),
        )
        .toList();
  }

  int get newCount =>
      _allOrders
          .where(
            (o) =>
                o.isPending &&
                (o.isShippingQuotePending || o.canStartPreparation),
          )
          .length;
  int get awaitingBuyerApprovalCount =>
      _allOrders.where((o) => o.isPending && o.isAwaitingBuyerApproval).length;
  int get awaitingPaymentCount =>
      _allOrders.where((o) => o.isPending && o.isAwaitingPayment).length;
  int get processingCount => _allOrders
      .where((o) => o.isProcessing && o.shipmentState == 'pending')
      .length;
  int get readyForShippingCount => _allOrders
      .where((o) => o.isProcessing && o.shipmentState == 'ready_for_shipping')
      .length;
  int get shippedCount =>
      _allOrders.where((o) => o.isShipped && o.escrowReleaseAt == null).length;
  int get awaitingReceiptCount =>
      _allOrders.where((o) => o.isShipped && o.escrowReleaseAt != null).length;
  int get deliveredCount => _allOrders.where((o) => o.isDelivered).length;
  int get cancelledCount =>
      _allOrders.where((o) => o.isCancelled || o.isReturned).length;

  int get pendingCount =>
      newCount + awaitingBuyerApprovalCount + awaitingPaymentCount;

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

    final result = await _ordersData.getOrders(token: _token);
    result.fold(
      (failure) {
        statusRequest = failure;
        update();
      },
      (response) {
        if (response['success'] == true) {
          try {
            final rawData = response['data'];
            // Handle both paginated ({ data: [...] }) and direct list responses
            final List rawList = rawData is Map
                ? ((rawData['data'] as List?) ?? [])
                : ((rawData as List?) ?? []);
            _allOrders = _flattenSellerOrders(rawList);
            statusRequest = StatusRequest.success;
          } catch (_) {
            customSnackbar(
              'error'.tr,
              'تعذر تحميل الطلبات، يرجى المحاولة مجددًا',
            );
            statusRequest = StatusRequest.serverfailure;
          }
        } else {
          statusRequest = StatusRequest.none;
        }
        update();
      },
    );
  }

  Future<void> refreshOrders() => loadOrders();

  Future<void> acceptOrder(
    SubOrderModel order, {
    int estimatedMinutes = 30,
  }) async {
    actionStatusRequest = StatusRequest.loading;
    update();

    final result = await _ordersData.acceptOrder(
      orderId: order.rawId,
      token: _token,
    );
    result.fold(
      (failure) {
        actionStatusRequest = failure;
        update();
        customSnackbar('error'.tr, 'server_error'.tr);
      },
      (response) {
        if (response['success'] == true) {
          actionStatusRequest = StatusRequest.success;
          customSnackbar(
            'order_accept'.tr,
            response['message']?.toString() ?? 'order_accept_msg'.tr,
            isError: false,
          );
          loadOrders(); // Refresh from server
        } else {
          actionStatusRequest = StatusRequest.none;
          customSnackbar('warning'.tr, response['message']?.toString() ?? '');
        }
        update();
      },
    );
  }

  Future<void> rejectOrder(SubOrderModel order, String reason) async {
    actionStatusRequest = StatusRequest.loading;
    update();

    final result = await _ordersData.rejectOrder(
      orderId: order.rawId,
      reason: reason,
      token: _token,
    );
    result.fold(
      (failure) {
        actionStatusRequest = failure;
        update();
        customSnackbar('error'.tr, 'server_error'.tr);
      },
      (response) {
        if (response['success'] == true) {
          actionStatusRequest = StatusRequest.success;
          customSnackbar(
            'order_reject'.tr,
            response['message']?.toString() ?? 'order_reject_msg'.tr,
            isError: false,
          );
          loadOrders(); // Refresh from server
        } else {
          actionStatusRequest = StatusRequest.none;
          customSnackbar('warning'.tr, response['message']?.toString() ?? '');
        }
        update();
      },
    );
  }

  List<SubOrderModel> _flattenSellerOrders(List rawList) {
    final rows = <SubOrderModel>[];
    for (final raw in rawList) {
      if (raw is! Map) continue;
      final order = Map<String, dynamic>.from(raw);
      final rawSubOrders = order['sub_orders'];
      final subOrders = rawSubOrders is List ? rawSubOrders : const [];

      if (subOrders.isEmpty) {
        rows.add(SubOrderModel.fromJson(order));
        continue;
      }

      for (final rawSub in subOrders) {
        if (rawSub is! Map) continue;
        final sub = Map<String, dynamic>.from(rawSub);
        final sellerId = '${sub['seller_id'] ?? ''}';
        if (_sellerId > 0 && sellerId.isNotEmpty && sellerId != '$_sellerId') {
          continue;
        }

        final merged = <String, dynamic>{
          ...sub,
          'sub_order_id': sub['id'],
          'parent_order_id': order['id'],
          'buyer': order['buyer'],
          'buyer_id': order['user_id'],
          'payment_status': order['payment_status'],
          'payment_method': order['payment_method'],
          'customer_notes': order['customer_notes'],
          'created_at': order['created_at'],
          'status_timeline': sub['status_timeline'] ?? order['status_timeline'],
          'shipping_address_details':
              sub['shipping_address_details'] ??
              order['shipping_address_details'],
        };
        rows.add(SubOrderModel.fromJson(merged));
      }
    }
    return rows;
  }

  Future<void> setShippingDetails(
    SubOrderModel order, {
    required String method,
    required double cost,
    required String estimatedDelivery,
  }) async {
    actionStatusRequest = StatusRequest.loading;
    update();
    final result = await _ordersData.setShippingDetails(
      orderId: order.rawId,
      method: method,
      cost: cost,
      estimatedDelivery: estimatedDelivery,
      token: _token,
    );
    result.fold(
      (failure) {
        actionStatusRequest = failure;
        customSnackbar('error'.tr, 'server_error'.tr);
      },
      (body) {
        if (body['success'] == true) {
          actionStatusRequest = StatusRequest.success;
          customSnackbar(
            'success'.tr,
            'seller_shipping_saved'.tr,
            isError: false,
          );
          loadOrders();
        } else {
          actionStatusRequest = StatusRequest.none;
          customSnackbar(
            'warning'.tr,
            body['message']?.toString() ?? 'error'.tr,
          );
        }
      },
    );
    update();
  }

  Future<void> markReadyForShipping(SubOrderModel order) async {
    await _runOrderAction(
      action: () =>
          _ordersData.readyForShipping(orderId: order.rawId, token: _token),
      successKey: 'seller_order_ready_for_shipping',
    );
  }

  Future<void> markShipped(SubOrderModel order) async {
    await _runOrderAction(
      action: () => _ordersData.shipOrder(orderId: order.rawId, token: _token),
      successKey: 'seller_order_marked_shipped',
    );
  }

  Future<void> _runOrderAction({
    required Future<Either<StatusRequest, Map>> Function() action,
    required String successKey,
  }) async {
    actionStatusRequest = StatusRequest.loading;
    update();
    final result = await action();
    result.fold(
      (failure) {
        actionStatusRequest = failure;
        customSnackbar('error'.tr, 'server_error'.tr);
      },
      (body) {
        if (body['success'] == true) {
          actionStatusRequest = StatusRequest.success;
          customSnackbar('success'.tr, successKey.tr, isError: false);
          loadOrders();
        } else {
          actionStatusRequest = StatusRequest.none;
          customSnackbar(
            'warning'.tr,
            body['message']?.toString() ?? 'server_error'.tr,
          );
        }
      },
    );
    update();
  }

  void messageBuyer(SubOrderModel order) {
    ConversationModel? existing;
    if (Get.isRegistered<SellerChatController>()) {
      final chatCtrl = Get.find<SellerChatController>();
      try {
        existing = chatCtrl.conversations.firstWhere(
          (c) => c.buyerId == order.buyerId,
        );
      } catch (_) {
        existing = null;
      }
    }
    final conversation =
        existing ??
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
