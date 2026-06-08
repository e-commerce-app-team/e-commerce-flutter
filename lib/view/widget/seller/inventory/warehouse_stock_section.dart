import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/inventory_models.dart';

class WarehouseStockSection extends StatelessWidget {
  final List<WarehouseModel>    warehouses;
  final Map<int, String>        warehouseQty;
  final void Function(int id, String qty) onQtyChanged;

  const WarehouseStockSection({
    super.key,
    required this.warehouses,
    required this.warehouseQty,
    required this.onQtyChanged,
  });

  int get _totalQty => warehouseQty.values
      .fold(0, (sum, q) => sum + (int.tryParse(q) ?? 0));

  @override
  Widget build(BuildContext context) {
    if (warehouses.isEmpty) {
      return _EmptyWarehouses();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColor.infoLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.info.withOpacity(0.2)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded,
                size: 16, color: AppColor.info),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'وزّع الكمية على مستودعاتك وفروعك. '
                'الإجمالي سيُحسب تلقائياً.',
                style: AppTextStyle.labelSmall.copyWith(
                    color: AppColor.infoDark, fontSize: 11),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 14),

        ...warehouses.where((w) => w.isActive).map((w) =>
            _WarehouseRow(
              warehouse: w,
              qty: warehouseQty[w.id] ?? '',
              onChanged: (v) => onQtyChanged(w.id, v),
            )),

        const Divider(height: 20, color: AppColor.greyBorder),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('الإجمالي الكلي',
                style: AppTextStyle.labelLarge
                    .copyWith(fontSize: 13)),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _totalQty > 0
                    ? AppColor.primarySurface
                    : AppColor.secondBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _totalQty > 0
                      ? AppColor.primaryColor.withOpacity(0.3)
                      : AppColor.greyBorder,
                ),
              ),
              child: Text(
                '$_totalQty قطعة',
                style: AppTextStyle.price.copyWith(
                  fontSize: 14,
                  color: _totalQty > 0
                      ? AppColor.primaryColor
                      : AppColor.greyLight,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WarehouseRow extends StatelessWidget {
  final WarehouseModel warehouse;
  final String         qty;
  final void Function(String) onChanged;

  const _WarehouseRow({
    required this.warehouse,
    required this.qty,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isBranch = warehouse.type == 'branch';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: isBranch
                  ? AppColor.infoLight
                  : AppColor.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isBranch
                  ? Icons.store_outlined
                  : Icons.warehouse_outlined,
              size: 18,
              color: isBranch
                  ? AppColor.info
                  : AppColor.primaryColor,
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  warehouse.name,
                  style: AppTextStyle.labelLarge
                      .copyWith(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: isBranch
                          ? AppColor.infoLight
                          : AppColor.primarySurface,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      warehouse.typeLabel,
                      style: AppTextStyle.labelSmall.copyWith(
                        fontSize: 9,
                        color: isBranch
                            ? AppColor.info
                            : AppColor.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    warehouse.city,
                    style: AppTextStyle.labelSmall
                        .copyWith(fontSize: 10),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 10),

          SizedBox(
            width: 90,
            child: TextField(
              onChanged: onChanged,
              controller: TextEditingController(text: qty)
                ..selection = TextSelection.fromPosition(
                    TextPosition(offset: qty.length)),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ],
              textAlign: TextAlign.center,
              style: AppTextStyle.inputText.copyWith(
                  fontSize: 14, fontFamily: 'PlayfairDisplay'),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: AppTextStyle.inputHint
                    .copyWith(fontSize: 13),
                filled: true,
                fillColor: (int.tryParse(qty) ?? 0) > 0
                    ? AppColor.primarySurface
                    : AppColor.secondBackground,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: (int.tryParse(qty) ?? 0) > 0
                        ? AppColor.primaryColor.withOpacity(0.4)
                        : AppColor.greyBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: (int.tryParse(qty) ?? 0) > 0
                        ? AppColor.primaryColor.withOpacity(0.4)
                        : AppColor.greyBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppColor.primaryColor, width: 1.5),
                ),
                suffixText: 'قطعة',
                suffixStyle: AppTextStyle.labelSmall
                    .copyWith(fontSize: 9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _EmptyWarehouses extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColor.warningLight,
      borderRadius: BorderRadius.circular(12),
      border:
          Border.all(color: AppColor.warning.withOpacity(0.3)),
    ),
    child: Row(children: [
      const Icon(Icons.warning_amber_rounded,
          size: 18, color: AppColor.warning),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('لا توجد مستودعات أو فروع',
                style: AppTextStyle.labelLarge.copyWith(
                    color: AppColor.warningDark, fontSize: 13)),
            Text(
              'أضف مستودعاتك وفروعك من قسم حسابي → الفروع والمستودعات',
              style: AppTextStyle.labelSmall
                  .copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    ]),
  );
}
