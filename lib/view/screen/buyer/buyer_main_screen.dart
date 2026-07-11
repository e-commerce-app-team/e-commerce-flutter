import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/buyer/buyer_main_controller.dart';
import 'package:e_commerce/view/screen/buyer/buyer_home_screen.dart';
import 'package:e_commerce/view/screen/buyer/explore/explore_screen.dart';
import 'package:e_commerce/view/widget/buyer/shared/buyer_bottom_nav.dart';

class BuyerMainScreen extends StatelessWidget {
  const BuyerMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(BuyerMainController());

    return GetBuilder<BuyerMainController>(
      builder: (controller) {
        return Scaffold(
          body: IndexedStack(
            index: controller.currentIndex,
            children: [
              const BuyerHomeScreen(),
              const ExploreScreen(),
              // Placeholder for Cart Screen
              const Scaffold(body: Center(child: Text("Cart Screen"))),
              // Placeholder for Orders Screen
              const Scaffold(body: Center(child: Text("Orders Screen"))),
              // Placeholder for Account Screen
              const Scaffold(body: Center(child: Text("Account Screen"))),
            ],
          ),
          bottomNavigationBar: BuyerBottomNav(
            currentIndex: controller.currentIndex,
            cartCount: 2, // You can connect this to a cart controller later
            onTap: (i) => controller.changeTab(i),
          ),
        );
      },
    );
  }
}
