import 'package:flutter/material.dart' hide SearchBar;
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_inventory_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/view/widget/shared/search_bar.dart';
import 'package:e_commerce/view/widget/seller/inventory/inventory_filter_sheet.dart';
import 'inventory_tabs.dart';

class InventoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SellerInventoryController ctrl;
  const InventoryAppBar({super.key, required this.ctrl});

  @override
  Size get preferredSize => const Size.fromHeight(155);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColor.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  Text("inventory".tr, style: AppTextStyle.appBarTitle),
                  const Spacer(),

                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _AppBarBtn(
                        icon: Icons.tune_rounded,
                        onTap: () => _showFilterSheet(ctrl),
                      ),
                      if (ctrl.filter.activeCount > 0)
                        Positioned(
                          top: -3, right: -3,
                          child: Container(
                            width: 16, height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xffFFD700),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${ctrl.filter.activeCount}',
                                style: AppTextStyle.buttonMedium.copyWith(fontSize: 9,color: AppColor.black)
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),

                  _AppBarBtn(
                    icon: ctrl.isGridView ? Icons.list_rounded : Icons.grid_view_rounded,
                    onTap: ctrl.toggleViewMode,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: SearchBar(
                controller: ctrl.searchCtrl,
                hintText: 'search_inventory_hint'.tr,
                onChanged: ctrl.onSearchChanged,
                onClear: ctrl.clearSearch,
              ),
            ),

            InventoryTabs(ctrl: ctrl),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(SellerInventoryController ctrl) {
    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, scrollController) => InventoryFilterSheet(
          scrollCtrl: scrollController,
          currentFilter: ctrl.filter,
          categories: ctrl.categories,
          onApply: ctrl.applyFilter,
          onReset: ctrl.resetFilter,
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
       exitBottomSheetDuration: Duration(milliseconds:700),
      enterBottomSheetDuration: Duration(milliseconds: 500)
    );
  }
}

class _AppBarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AppBarBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white.withOpacity(0.3),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}