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




  @override
  void onInit() {
    super.onInit();
  }
}
