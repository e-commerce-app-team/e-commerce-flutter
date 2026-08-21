import 'package:flutter/material.dart';
import 'package:e_commerce/view/screen/buyer/orders/buyer_orders_screen.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/buyer/buyer_main_controller.dart';
import 'package:e_commerce/controller/buyer/cart_controller.dart';
import 'package:e_commerce/view/screen/buyer/buyer_home_screen.dart';
import 'package:e_commerce/view/screen/buyer/explore/explore_screen.dart';
import 'package:e_commerce/view/widget/buyer/shared/buyer_bottom_nav.dart';
import 'package:e_commerce/controller/buyer/buyer_orders_controller.dart';
import 'package:e_commerce/view/screen/buyer/cart/cart_screen.dart';
import 'package:e_commerce/view/screen/buyer/profile/buyer_profile_screen.dart';

class BuyerMainScreen extends StatefulWidget {
  const BuyerMainScreen({super.key});

  @override
  State<BuyerMainScreen> createState() => _BuyerMainScreenState();
}

class _BuyerMainScreenState extends State<BuyerMainScreen> {
  @override
  void initState() {
    super.initState();
    Get.put(BuyerMainController());
    Get.put(CartController(), permanent: true);

    if (Get.isRegistered<BuyerOrdersController>()) {
      Get.find<BuyerOrdersController>().refresh();
    } else {
      Get.put(BuyerOrdersController(), permanent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BuyerMainController>(
      builder: (controller) {
        final cartCtrl = Get.find<CartController>();
        return Scaffold(
          body: IndexedStack(
            index: controller.currentIndex,
            children: [
              const BuyerHomeScreen(),
              const ExploreScreen(),
              const CartScreen(),
              const BuyerOrdersScreen(),
              const BuyerProfileScreen(),
            ],
          ),
          bottomNavigationBar: Obx(
            () => BuyerBottomNav(
              currentIndex: controller.currentIndex,
              cartCount: cartCtrl.totalItemsCount,
              onTap: (i) {
                controller.changeTab(i);
                if (i == 2) cartCtrl.refreshAll();
              },
            ),
          ),
        );
      },
    );
  }
}
