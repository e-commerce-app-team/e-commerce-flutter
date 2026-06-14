import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../../controller/seller/seller_inventory_controller.dart';
import '../../../../core/constant/app_text_style.dart';
import '../../../../core/constant/color.dart';

class InventoryTabDef {
  final String label;
  final int count;
  final Color? alertColor;
  InventoryTabDef({required this.label, required this.count, this.alertColor});
}
class InventoryTabs extends StatelessWidget {
  final SellerInventoryController ctrl;
  const InventoryTabs({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      InventoryTabDef(label: 'tab_all'.tr, count: ctrl.allCount),
      InventoryTabDef(label: 'tab_active'.tr, count: ctrl.activeCount),
      InventoryTabDef(label: 'tab_low_stock'.tr, count: ctrl.lowStockCount, alertColor: ctrl.lowStockCount > 0 ? AppColor.error : null), // منخفض
      InventoryTabDef(label: 'tab_draft'.tr, count: ctrl.draftCount),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final isActive = ctrl.selectedTabIndex == i;
          final t = tabs[i];

          return GestureDetector(
            onTap: () => ctrl.changeTab(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isActive ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.label,
                    style: AppTextStyle.chip.copyWith(
                      color: isActive ? AppColor.primaryColor : Colors.white,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  if (t.count > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isActive
                            ? (t.alertColor ?? AppColor.primaryColor)
                            : Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${t.count}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'PlayfairDisplay',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}