import 'package:flutter/material.dart' hide SearchBar;
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_inventory_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/view/widget/seller/inventory/inventory_filter_sheet.dart';
import 'package:e_commerce/view/widget/seller/inventory/inventory_tabs.dart';
import 'package:e_commerce/view/widget/shared/search_bar.dart';

class InventorySliverAppBar extends StatelessWidget {
  final SellerInventoryController ctrl;
  const InventorySliverAppBar({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: 154 ,
      toolbarHeight: 56,
      backgroundColor: AppColor.primaryColor,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Text('Inventory'.tr, style: AppTextStyle.appBarTitle),
          const Spacer(),
          _IconBtn(
            icon: ctrl.isGridView ? Icons.list_rounded : Icons.grid_view_rounded,
            onTap: ctrl.toggleViewMode,
          ),
          const SizedBox(width: 8),
          _FilterBadgeBtn(ctrl: ctrl),
        ],
      ),
      centerTitle: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(gradient: AppColor.headerGradient),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomSearchBar(
                  controller: ctrl.searchCtrl,
                  hintText: 'search_inventory_hint'.tr,
                  onChanged: ctrl.onSearchChanged,
                  onClear: ctrl.clearSearch,
                ),
              ),

              const SizedBox(height: 56),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(46),
        child: Container(
          height: 46,
          decoration: const BoxDecoration(gradient: AppColor.headerGradient),
          child: InventoryTabs(ctrl: ctrl),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    ),
  );
}

class _FilterBadgeBtn extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _FilterBadgeBtn({required this.ctrl});

  void _openFilter() {
    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, sc) => InventoryFilterSheet(
          scrollCtrl: sc,
          currentFilter: ctrl.filter,
          categoryTree: ctrl.categoryTree,
          onApply: ctrl.applyFilter,
          onReset: ctrl.resetFilter,
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
      enterBottomSheetDuration: const Duration(milliseconds: 400),
      exitBottomSheetDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: _openFilter,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
        ),
        if (ctrl.filter.activeCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 17,
              height: 17,
              decoration: const BoxDecoration(
                color: Color(0xffFFD700),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${ctrl.filter.activeCount}',
                  style: AppTextStyle.badge.copyWith(
                    color: AppColor.black,
                    fontSize: 9,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}