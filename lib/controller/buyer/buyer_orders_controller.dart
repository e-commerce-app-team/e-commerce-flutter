// lib/controller/buyer/buyer_orders_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/data/datasource/remote/buyer/buyer_orders_datasource.dart';
import 'package:e_commerce/data/model/buyer/buyer_orders_model.dart';

class BuyerOrdersController extends GetxController {
  final BuyerOrdersDataSource _dataSource = BuyerOrdersDataSource(
    Get.find<Crud>(),
  );
  final MyServices _services = Get.find<MyServices>();

  List<BuyerOrderModel> _allOrders = [];
  List<BuyerOrderModel> filteredOrders = [];

  bool isLoading = false;
  String? loadError;
  bool _isLoadingOrders = false;

  // GetBuilder is still used by the other order screens, but the list screen
  // also listens to this revision so a fast request cannot finish before its
  // widget subscription is attached.
  final RxInt viewRevision = 0.obs;

  int selectedTabIndex = 0;
  BuyerOrderSort sortBy = BuyerOrderSort.newest;
  RangeValues priceRange = const RangeValues(0, 5000000);

  static const List<BuyerOrderTabFilter> tabFilters = [
    BuyerOrderTabFilter.all,
    BuyerOrderTabFilter.needsAction,
    BuyerOrderTabFilter.processing,
    BuyerOrderTabFilter.shipped,
    BuyerOrderTabFilter.awaitingReceipt,
    BuyerOrderTabFilter.completed,
    BuyerOrderTabFilter.cancelled,
  ];

  static const List<String> tabLabelKeys = [
    'tab_all',
    'buyer_tab_needs_action',
    'buyer_tab_processing',
    'buyer_tab_shipped',
    'buyer_tab_awaiting_receipt',
    'buyer_tab_completed',
    'tab_cancelled',
  ];

  String? get _token {
    final t = _services.sharedPreferences.getString('token');
    if (t == null || t.isEmpty) return null;
    return t;
  }

  int get activeFilterCount {
    var count = 0;
    if (sortBy != BuyerOrderSort.newest) count++;
    if (priceRange.start > 0 || priceRange.end < 5000000) count++;
    return count;
  }

  @override
  void onInit() {
    super.onInit();
    _loadOrders();
  }

  void _notifyUi() {
    viewRevision.value++;
    update();
  }

  Future<void> reloadOrders() => _loadOrders();

  void changeTab(int index) {
    debugPrint('Buyer orders tab tapped: $index');
    if (selectedTabIndex == index) return;
    selectedTabIndex = index;
    _applyFilters();
    _notifyUi();
  }

  void applyFilterSheet({
    required BuyerOrderSort sort,
    required RangeValues price,
  }) {
    sortBy = sort;
    priceRange = price;
    _applyFilters();
    _notifyUi();
  }

  void resetFilters() {
    sortBy = BuyerOrderSort.newest;
    priceRange = const RangeValues(0, 5000000);
    _applyFilters();
    _notifyUi();
  }

  BuyerOrderModel? findOrder(String id) {
    try {
      return _allOrders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  void patchOrder(BuyerOrderModel updated) {
    _allOrders = _allOrders
        .map((o) => o.id == updated.id ? updated : o)
        .toList();
    _applyFilters();
    _notifyUi();
  }

  Future<bool> confirmDelivery(String orderId, {String? subOrderId}) async {
    final token = _token;
    if (token == null) {
      _applyLocalDelivery(orderId);
      return true;
    }

    final result = await _dataSource.confirmDelivery(
      token,
      orderId,
      subOrderId: subOrderId,
    );
    return result.fold(
      (_) {
        customSnackbar('error'.tr, 'buyer_confirm_delivery_failed'.tr);
        return false;
      },
      (response) {
        if (response['success'] == true) {
          _applyLocalDelivery(orderId);
          return true;
        }
        customSnackbar(
          'error'.tr,
          response['message']?.toString() ?? 'buyer_confirm_delivery_failed'.tr,
        );
        return false;
      },
    );
  }

  void _applyLocalDelivery(String orderId) {
    final order = findOrder(orderId);
    if (order == null) return;
    patchOrder(
      order.copyWith(
        status: BuyerOrderStatus.delivered,
        deliveredAt: DateTime.now(),
      ),
    );
  }

  Future<bool> submitRating({
    required String orderId,
    required String storeId,
    required double rating,
    required String comment,
  }) async {
    final token = _token;
    if (token != null) {
      final result = await _dataSource.rateStore(
        token,
        storeId,
        rating: rating,
        comment: comment,
      );
      final failed = result.fold((_) => true, (r) => r['success'] != true);
      if (failed) {
        customSnackbar('error'.tr, 'buyer_rating_failed'.tr);
        return false;
      }
    }

    final order = findOrder(orderId);
    if (order != null) {
      patchOrder(order.copyWith(isRated: true));
    }
    customSnackbar('success'.tr, 'buyer_rating_success'.tr, isError: false);
    return true;
  }

  Future<void> submitReturnRequest({
    required String orderId,
    required String reason,
    required String description,
    List<String> imagePaths = const [],
  }) async {
    final order = findOrder(orderId);
    if (order == null) return;

    final request = BuyerReturnRequest(
      status: BuyerReturnStatus.submitted,
      reason: reason,
      description: description,
      imageUrls: imagePaths,
      timeline: const [
        BuyerTimelineStep(
          status: 'submitted',
          title: 'submitted',
          isDone: true,
          isCurrent: true,
        ),
      ],
    );

    patchOrder(order.copyWith(returnRequest: request));
    customSnackbar('success'.tr, 'buyer_return_submitted'.tr, isError: false);
  }

  void escalateReturn(String orderId) {
    final order = findOrder(orderId);
    if (order?.returnRequest == null) return;

    final updated = BuyerReturnRequest(
      status: BuyerReturnStatus.underReview,
      reason: order!.returnRequest!.reason,
      description: order.returnRequest!.description,
      imageUrls: order.returnRequest!.imageUrls,
      timeline: [
        ...order.returnRequest!.timeline,
        const BuyerTimelineStep(
          status: 'escalated',
          title: 'escalated',
          isDone: true,
          isCurrent: true,
        ),
      ],
    );
    patchOrder(order.copyWith(returnRequest: updated));
    customSnackbar('success'.tr, 'buyer_return_escalated'.tr, isError: false);
  }

  Future<void> _loadOrders() async {
    if (_isLoadingOrders) return;
    final token = _token;

    // Resolve the empty/unauthenticated state before showing a loading frame.
    // This also avoids losing the final update while the controller is being
    // created inside the buyer main screen.
    if (token == null) {
      _allOrders = [];
      _applyFilters();
      loadError = 'login_required'.tr;
      isLoading = false;
      _isLoadingOrders = false;
      _notifyUi();
      return;
    }

    _isLoadingOrders = true;
    isLoading = true;
    loadError = null;
    debugPrint('Buyer orders loading started');
    _notifyUi();
    try {
      final result = await _dataSource
          .getOrders(token)
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () => const Left(StatusRequest.serverfailure),
          );
      result.fold(
        (status) {
          debugPrint(
            'Buyer orders request failed with status request: $status',
          );
          _allOrders = [];
          loadError = 'buyer_orders_load_failed'.tr;
        },
        (response) {
          try {
            final httpStatus = response['_http_status'] is num
                ? (response['_http_status'] as num).toInt()
                : 200;
            final hasOrderList =
                response['data'] is List ||
                (response['data'] is Map &&
                    (response['data'] as Map)['data'] is List);
            if (httpStatus >= 400 || !hasOrderList) {
              _allOrders = [];
              loadError = httpStatus >= 400
                  ? '${'buyer_orders_load_failed'.tr} (HTTP $httpStatus)'
                  : 'buyer_orders_load_failed'.tr;
            } else {
              _allOrders = _parseOrdersResponse(response);
            }
          } catch (e, stackTrace) {
            debugPrint('Buyer orders parsing exception: $e');
            debugPrintStack(stackTrace: stackTrace);
            _allOrders = [];
            loadError = 'buyer_orders_load_failed'.tr;
          }
        },
      );
    } on TimeoutException catch (e, stackTrace) {
      debugPrint('Buyer orders timeout exception: $e');
      debugPrintStack(stackTrace: stackTrace);
      _allOrders = [];
      loadError = 'buyer_orders_load_failed'.tr;
    } catch (e, stackTrace) {
      debugPrint('Buyer orders exception: $e');
      debugPrintStack(stackTrace: stackTrace);
      _allOrders = [];
      loadError = 'buyer_orders_load_failed'.tr;
    } finally {
      _applyFilters();
      isLoading = false;
      _isLoadingOrders = false;
      debugPrint(
        'Buyer orders loading finished: '
        'orders=${_allOrders.length}, error=$loadError',
      );
      _notifyUi();
    }
  }

  Future<bool> approveShipping(String orderId, String subOrderId) async {
    final token = _token;
    if (token == null) return false;
    final result = await _dataSource.approveShipping(
      token,
      orderId,
      subOrderId: subOrderId,
    );
    var shouldPay = false;
    final approved = result.fold(
      (_) {
        customSnackbar('error'.tr, 'buyer_shipping_approval_failed'.tr);
        return false;
      },
      (response) {
        if (response['success'] == true) {
          customSnackbar(
            'success'.tr,
            'buyer_shipping_approved'.tr,
            isError: false,
          );
          shouldPay = response['shipping_ready_for_payment'] == true;
          _loadOrders();
          return true;
        }
        customSnackbar(
          'error'.tr,
          response['message']?.toString() ??
              'buyer_shipping_approval_failed'.tr,
        );
        return false;
      },
    );
    if (approved && shouldPay) return payOrder(orderId);
    return approved;
  }

  Future<bool> payOrder(String orderId) async {
    final token = _token;
    if (token == null) return false;
    final result = await _dataSource.payOrder(token, orderId);
    return result.fold(
      (_) {
        customSnackbar('error'.tr, 'server_error'.tr);
        return false;
      },
      (response) {
        if (response['success'] == true) {
          customSnackbar('success'.tr, 'wallet_order_paid'.tr, isError: false);
          _loadOrders();
          return true;
        }
        customSnackbar(
          'error'.tr,
          response['message']?.toString() ?? 'server_error'.tr,
        );
        return false;
      },
    );
  }

  List<BuyerOrderModel> _parseOrdersResponse(Map response) {
    dynamic data = response['data'] ?? response;
    if (data is Map && data['data'] is List) {
      data = data['data'];
    }
    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map((e) => BuyerOrderModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  void _applyFilters() {
    final tab = tabFilters[selectedTabIndex];
    Iterable<BuyerOrderModel> list = _allOrders;

    list = list.where((order) {
      switch (tab) {
        case BuyerOrderTabFilter.all:
          return true;
        case BuyerOrderTabFilter.needsAction:
          return order.isNeedsAction;
        case BuyerOrderTabFilter.processing:
          return order.isProcessingGroup && !order.isNeedsAction;
        case BuyerOrderTabFilter.shipped:
          return order.isShippedGroup;
        case BuyerOrderTabFilter.awaitingReceipt:
          return order.isShippedGroup && order.canConfirmDelivery;
        case BuyerOrderTabFilter.completed:
          return order.isCompleted;
        case BuyerOrderTabFilter.cancelled:
          return order.isCancelledGroup;
      }
    });

    final hasPriceFilter = priceRange.start > 0 || priceRange.end < 5000000;
    if (hasPriceFilter) {
      list = list.where((order) {
        final total = order.totalAmount;
        return total >= priceRange.start && total <= priceRange.end;
      });
    }

    final sorted = list.toList();
    switch (sortBy) {
      case BuyerOrderSort.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case BuyerOrderSort.oldest:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case BuyerOrderSort.priceHigh:
        sorted.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;
      case BuyerOrderSort.priceLow:
        sorted.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
        break;
    }

    filteredOrders = sorted;
  }
}
