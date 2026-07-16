import 'package:get/get.dart';
import 'package:e_commerce/core/services/services.dart';

class SellerMainController extends GetxController {
  int currentIndex = 0;

  void changeTab(int index) {
    currentIndex = index;
    update();
  }

  int newOrdersCount = 0;
  int unreadMessagesCount = 0;

  void incrementOrders() {
    newOrdersCount++;
    update();
  }

  void clearOrdersBadge() {
    newOrdersCount = 0;
    update();
  }

  void setUnreadMessages(int count) {
    unreadMessagesCount = count;
    update();
  }

  MyServices myServices = Get.find();

  String get sellerName =>
      myServices.sharedPreferences.getString("store_name") ?? "My Store";
  String get sellerEmail =>
      myServices.sharedPreferences.getString("email") ?? "";
  String get sellerType =>
      myServices.sharedPreferences.getString("seller_type") ?? "wholesale";
  String get token =>
      myServices.sharedPreferences.getString("token") ?? "";

  bool get isWholesale => sellerType == "wholesale";

  // ─── Permission Helpers ────────────────────────────────────────────────────

  /// Whether the current user is a staff member (not the store owner)
  bool get isStaff => myServices.isStaff;

  /// Dashboard tab is visible for owners OR staff with view_reports permission
  bool get showDashboard => myServices.canViewDashboard;

  /// Inventory tab is visible for owners OR staff with manage_inventory
  bool get showInventory => myServices.canManageInventory;

  /// Orders tab is visible for owners OR staff with view_orders
  bool get showOrders => myServices.canViewOrders;

  /// Chat tab is visible for owners OR staff with chat_with_buyers
  bool get showChat => myServices.canChatWithBuyers;

  /// Profile tab is always visible (password change + logout)
  bool get showProfile => true;

  /// Returns the list of enabled tab indices in order:
  /// 0=Dashboard, 1=Inventory, 2=Orders, 3=Chat, 4=Profile
  /// Used to map a visual index to a logical screen index.
  List<int> get enabledTabIndices {
    final indices = <int>[];
    if (showDashboard) indices.add(0);
    if (showInventory) indices.add(1);
    if (showOrders)    indices.add(2);
    if (showChat)      indices.add(3);
    indices.add(4); // Profile always enabled
    return indices;
  }

  /// Maps an enabled-tab position to the actual screen index (0-4).
  int screenIndexForTab(int tabPosition) {
    final indices = enabledTabIndices;
    if (tabPosition < indices.length) return indices[tabPosition];
    return 4; // Fallback to profile
  }

  @override
  void onInit() {
    super.onInit();
  }
}
