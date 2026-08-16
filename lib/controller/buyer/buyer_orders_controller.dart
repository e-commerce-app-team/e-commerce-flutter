// lib/controller/buyer/buyer_orders_controller.dart

import 'package:get/get.dart';
import 'package:e_commerce/data/model/buyer/buyer_orders_model.dart';
import 'package:e_commerce/data/datasource/static/buyer_orders_mock_data.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// TODO: TRANSLATIONS — Add these keys to translation.dart before final release:
//   'my_orders_title'          → ar: 'طلباتي'                  en: 'My Orders'
//   'buyer_orders_empty_title' → ar: 'لا توجد طلبات بعد'       en: 'No orders yet'
//   'buyer_orders_empty_body'  → ar: 'ستظهر طلباتك هنا'        en: 'Your orders will appear here'
//   'buyer_tab_pending'        → ar: 'قيد الانتظار'            en: 'Pending'
//   'cancel_order'             → ar: 'إلغاء الطلب'             en: 'Cancel Order'
//   'track_order'              → ar: 'تتبع الطلب'              en: 'Track Order'
//   'reorder'                  → ar: 'إعادة الطلب'             en: 'Reorder'
//   'order_items_count'        → ar: 'منتج'                    en: 'item(s)'
// ═══════════════════════════════════════════════════════════════════════════════

class BuyerOrdersController extends GetxController {
  // ── State ──────────────────────────────────────────────────────────────────
  List<BuyerOrderModel> _allOrders = [];
  List<BuyerOrderModel> filteredOrders = [];

  bool isLoading = false;
  int selectedTabIndex = 0;

  // ── Tab → status mapping (index must mirror _OrderTabsBar._tabKeys) ────────
  static const List<BuyerOrderStatus?> tabStatusFilters = [
    null,                        // 0 → الكل
    BuyerOrderStatus.pending,    // 1 → قيد الانتظار
    BuyerOrderStatus.processing, // 2 → قيد التجهيز
    BuyerOrderStatus.shipped,    // 3 → مشحون
    BuyerOrderStatus.delivered,  // 4 → مكتمل
    BuyerOrderStatus.cancelled,  // 5 → ملغى
  ];

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadOrders();
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Called by RefreshIndicator's onRefresh callback.
  Future<void> refresh() => _loadOrders();

  /// Switches the active filter tab and re-applies the filter.
  void changeTab(int index) {
    if (selectedTabIndex == index) return;
    selectedTabIndex = index;
    _applyFilter();
    update();
  }

  /// Marks an order as cancelled locally and notifies the API.
  /// TODO: Replace stub with real POST /buyer/orders/{id}/cancel via Crud.
  Future<void> cancelOrder(String orderId) async {
    _allOrders = _allOrders.map((o) {
      if (o.id != orderId) return o;
      return BuyerOrderModel(
        id: o.id,
        orderNumber: o.orderNumber,
        storeName: o.storeName,
        storeLogoUrl: o.storeLogoUrl,
        totalAmount: o.totalAmount,
        status: BuyerOrderStatus.cancelled,
        createdAt: o.createdAt,
        items: o.items,
        trackingNumber: o.trackingNumber,
      );
    }).toList();
    _applyFilter();
    update();
  }

  /// TODO: Wire to cart controller to push items back to the cart.
  Future<void> reorder(String orderId) async {}

  // ── Private ────────────────────────────────────────────────────────────────

  Future<void> _loadOrders() async {
    isLoading = true;

    // TODO: Replace with Crud.getData(AppLink.buyerOrders, headers: {...})
    // await Future.delayed(const Duration(milliseconds: 750));
    _allOrders = BuyerOrdersMockData.orders;

    _applyFilter();
    isLoading = false;
    update();
  }

  void _applyFilter() {
    final statusFilter = tabStatusFilters[selectedTabIndex];
    filteredOrders = statusFilter == null
        ? List<BuyerOrderModel>.from(_allOrders)
        : _allOrders.where((o) => o.status == statusFilter).toList();
  }
}

