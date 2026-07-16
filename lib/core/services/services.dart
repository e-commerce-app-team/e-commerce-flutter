import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../class/crud.dart';
import 'fcm_service.dart';

class MyServices extends GetxService{

 late SharedPreferences sharedPreferences ;

  Future<MyServices> init() async {
    await Firebase.initializeApp();
    sharedPreferences = await SharedPreferences.getInstance();
    return this;
  }

  // ─── User Role & Identity ─────────────────────────────────────────────────
  String get userRole => sharedPreferences.getString('role') ?? '';
  String get userId   => sharedPreferences.getString('id')   ?? '';
  String get userEmail=> sharedPreferences.getString('email')  ?? '';

  /// Returns true if the logged-in user is a staff member (not the store owner)
  bool get isStaff =>
      userRole == 'staff';

  /// Returns true if the logged-in user is a store owner (vendor / wholesale)
  bool get isOwner =>
      userRole == 'vendor' || userRole == 'wholesale';

  // ─── Permissions ──────────────────────────────────────────────────────────
  /// The list of permissions granted to this staff member.
  /// Empty for store owners (they have implicit full access).
  List<String> get userPermissions =>
      sharedPreferences.getStringList('permissions') ?? [];

  /// Save permissions list to SharedPreferences.
  Future<void> savePermissions(List<String> permissions) async =>
      sharedPreferences.setStringList('permissions', permissions);

  /// Returns true if the current user has the given permission.
  /// Store owners always return true (full access).
  bool hasPermission(String permission) {
    if (isOwner) return true;    // Owners have all permissions
    if (!isStaff) return false;  // Unknown role → deny
    return userPermissions.contains(permission);
  }

  /// Returns true if user can see the Dashboard tab
  bool get canViewDashboard => isOwner || hasPermission('view_reports');

  /// Returns true if user can see the Inventory tab
  bool get canManageInventory => isOwner || hasPermission('manage_inventory');

  /// Returns true if user can see the Orders tab
  bool get canViewOrders => isOwner || hasPermission('view_orders');

  /// Returns true if user can see the Chat tab
  bool get canChatWithBuyers => isOwner || hasPermission('chat_with_buyers');

  /// Clear all session data on logout
  Future<void> clearSession() async {
    await sharedPreferences.remove('id');
    await sharedPreferences.remove('role');
    await sharedPreferences.remove('token');
    await sharedPreferences.remove('email');
    await sharedPreferences.remove('permissions');
    await sharedPreferences.remove('onboarding');
  }
}

Future<void> initialServices() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Get.putAsync(() => MyServices().init());

  Get.put(Crud());


  Get.put(FCMService()).init();
}