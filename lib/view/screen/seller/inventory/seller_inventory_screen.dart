import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_inventory_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/view/screen/seller/inventory/add_edit_product_screen.dart';
import '../../../widget/seller/inventory/inventory_appbar.dart';
import '../../../widget/seller/inventory/inventory_shimmer.dart';
import '../../../widget/seller/inventory/product_list.dart';
import '../../../widget/shared/empty_state.dart';

class SellerInventoryScreen extends StatelessWidget {
  const SellerInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<SellerInventoryController>(
      init: SellerInventoryController(),
      builder: (ctrl) {
        final bool hasSearch = ctrl.searchCtrl.text.isNotEmpty || ctrl.filter.hasActiveFilters;
        return Scaffold(
          backgroundColor: AppColor.secondBackground,

          appBar:InventoryAppBar(ctrl: ctrl),

          body: ctrl.statusRequest == StatusRequest.loading
              ? const InventoryShimmer()
              : RefreshIndicator(
            onRefresh: ctrl.refreshProducts,
            color: AppColor.primaryColor,
            backgroundColor: Colors.white,
            child: ctrl.displayedProducts.isEmpty
                ? EmptyState(
              icon: hasSearch ? Icons.search_off_rounded : Icons.inventory_2_outlined,
              title: hasSearch ? 'no_search_results'.tr : 'no_products_yet'.tr,
              subtitle: hasSearch ? 'try_different_search'.tr : 'click_add_to_start'.tr,
            )
                : ProductList(ctrl: ctrl),
          ),

          floatingActionButton: _AddFAB(ctrl: ctrl),
        );
      },
    );
  }
}
class _AddFAB extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _AddFAB({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        ctrl.prepareAddForm();
        Get.to(() => const AddEditProductScreen(),
            transition: Transition.cupertino);
      },
      backgroundColor: AppColor.primaryColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text('add_product'.tr, style: AppTextStyle.buttonSmall),
    );
  }
}

