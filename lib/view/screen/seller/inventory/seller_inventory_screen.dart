import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_inventory_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/view/screen/seller/inventory/add_edit_product_screen.dart';
import 'package:e_commerce/view/widget/seller/inventory/inventory_appbar.dart';
import 'package:e_commerce/view/widget/seller/inventory/inventory_shimmer.dart';
import 'package:e_commerce/view/widget/seller/inventory/product_list.dart';
import 'package:e_commerce/view/widget/shared/empty_state.dart';

class SellerInventoryScreen extends StatelessWidget {
  const SellerInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SellerInventoryController>(
      init: SellerInventoryController(),
      builder: (ctrl) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        body: RefreshIndicator(
          onRefresh: ctrl.refreshProducts,
          color: AppColor.primaryColor,
          backgroundColor: Colors.white,
          displacement: 80,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              InventorySliverAppBar(ctrl: ctrl),
              if (ctrl.statusRequest == StatusRequest.loading)
                const SliverToBoxAdapter(child: InventoryShimmer())
              else if (ctrl.displayedProducts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: ctrl.searchCtrl.text.isNotEmpty ||
                        ctrl.filter.hasActiveFilters
                        ? Icons.search_off_rounded
                        : Icons.inventory_2_outlined,
                    title: ctrl.searchCtrl.text.isNotEmpty ||
                        ctrl.filter.hasActiveFilters
                        ? 'no_search_results'.tr
                        : 'no_products_yet'.tr,
                    subtitle: ctrl.searchCtrl.text.isNotEmpty ||
                        ctrl.filter.hasActiveFilters
                        ? 'try_different_search'.tr
                        : 'click_add_to_start'.tr,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                  sliver: ProductSliverList(ctrl: ctrl),
                ),
            ],
          ),
        ),
        floatingActionButton: _AddFAB(ctrl: ctrl),
      ),
    );
  }
}

class _AddFAB extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _AddFAB({required this.ctrl});

  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
    onPressed: () async {
      await ctrl.prepareAddForm();
      Get.to(() => const AddEditProductScreen(), transition: Transition.cupertino);
    },
    backgroundColor: AppColor.primaryColor,
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    icon: const Icon(Icons.add_rounded, color: Colors.white),
    label: Text('add_product'.tr, style: AppTextStyle.buttonSmall),
  );
}