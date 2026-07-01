import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_inventory_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/inventory_models.dart';

class VariantSection extends StatelessWidget {
  final SellerInventoryController ctrl;
  const VariantSection({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _VariantToggle(ctrl: ctrl),
        if (ctrl.formVariantsEnabled) ...[
          const SizedBox(height: 14),
          _AttributesList(ctrl: ctrl),
          const SizedBox(height: 10),
          _GenerateBtn(ctrl: ctrl),
          if (ctrl.formVariants.isNotEmpty) ...[
            const SizedBox(height: 14),
            _CombinationsTable(ctrl: ctrl),
          ],
        ],
      ],
    );
  }
}

class _VariantToggle extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _VariantToggle({required this.ctrl});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: ctrl.formVariantsEnabled
          ? AppColor.primarySurface
          : AppColor.secondBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: ctrl.formVariantsEnabled
            ? AppColor.primaryColor.withOpacity(0.3)
            : AppColor.greyBorder,
      ),
    ),
    child: Row(children: [
      Icon(
        Icons.color_lens_outlined,
        size: 20,
        color: ctrl.formVariantsEnabled ? AppColor.primaryColor : AppColor.grey,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('variants_toggle'.tr,
              style: AppTextStyle.labelLarge.copyWith(fontSize: 13)),
          Text('variants_toggle_sub'.tr, style: AppTextStyle.labelSmall),
        ]),
      ),
      Switch.adaptive(
        value: ctrl.formVariantsEnabled,
        onChanged: ctrl.toggleVariants,
        activeColor: AppColor.primaryColor,
      ),
    ]),
  );
}

class _AttributesList extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _AttributesList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...ctrl.formAttributeTypes.map((attr) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _AttributeCard(ctrl: ctrl, attr: attr),
        )),
        GestureDetector(
          onTap: ctrl.addAttributeType,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColor.primarySurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.primaryColor.withOpacity(0.25)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.add_rounded, size: 17, color: AppColor.primaryColor),
              const SizedBox(width: 6),
              Text('add_attribute_type'.tr,
                  style: AppTextStyle.labelMedium.copyWith(
                      color: AppColor.primaryColor, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ],
    );
  }
}

class _AttributeCard extends StatefulWidget {
  final SellerInventoryController ctrl;
  final VariantAttributeType attr;
  const _AttributeCard({required this.ctrl, required this.attr});

  @override
  State<_AttributeCard> createState() => _AttributeCardState();
}

class _AttributeCardState extends State<_AttributeCard> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _valueCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.attr.name);
    _valueCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attr = widget.attr;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.greyBorder),
        boxShadow: AppColor.cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _nameCtrl,
                onChanged: (v) => widget.ctrl.updateAttributeName(attr.uid, v),
                style: AppTextStyle.inputText.copyWith(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'attribute_name_hint'.tr,
                  hintStyle: AppTextStyle.inputHint.copyWith(fontSize: 12),
                  labelText: 'attribute_name_label'.tr,
                  labelStyle: AppTextStyle.labelSmall.copyWith(fontSize: 11),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => widget.ctrl.removeAttributeType(attr.uid),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColor.errorLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.close_rounded, size: 13, color: AppColor.error),
              ),
            ),
          ]),
        ),
        const Divider(height: 12, indent: 12, endIndent: 12, color: AppColor.greyBorder),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('attribute_values_label'.tr,
                style: AppTextStyle.labelSmall.copyWith(fontSize: 10)),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: [
              ...attr.values.map((val) => _ValChip(
                value: val,
                onRemove: () => widget.ctrl.removeAttributeValue(attr.uid, val),
              )),
              _AddValField(
                controller: _valueCtrl,
                onAdd: () {
                  widget.ctrl.addAttributeValue(attr.uid, _valueCtrl.text);
                  _valueCtrl.clear();
                },
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _ValChip extends StatelessWidget {
  final String value;
  final VoidCallback onRemove;
  const _ValChip({required this.value, required this.onRemove});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 5),
    decoration: BoxDecoration(
      color: AppColor.primarySurface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColor.primaryColor.withOpacity(0.3)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(value,
          style: AppTextStyle.chip.copyWith(
              color: AppColor.primaryColor, fontWeight: FontWeight.w600)),
      const SizedBox(width: 4),
      GestureDetector(
        onTap: onRemove,
        child: const Icon(Icons.close_rounded, size: 12, color: AppColor.primaryColor),
      ),
    ]),
  );
}

class _AddValField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;
  const _AddValField({required this.controller, required this.onAdd});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 110,
    height: 32,
    child: TextField(
      controller: controller,
      style: AppTextStyle.inputText.copyWith(fontSize: 12),
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => onAdd(),
      decoration: InputDecoration(
        hintText: 'value_hint'.tr,
        hintStyle: AppTextStyle.inputHint.copyWith(fontSize: 11),
        suffixIcon: GestureDetector(
          onTap: onAdd,
          child: const Icon(Icons.add_rounded, size: 16, color: AppColor.primaryColor),
        ),
        filled: true,
        fillColor: AppColor.secondBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColor.greyBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColor.greyBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColor.primaryColor, width: 1.5),
        ),
      ),
    ),
  );
}

class _GenerateBtn extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _GenerateBtn({required this.ctrl});

  int get _count {
    if (ctrl.formAttributeTypes.isEmpty) return 0;
    return ctrl.formAttributeTypes.fold(
      1, (c, a) => c * (a.values.isEmpty ? 1 : a.values.length),
    );
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: ctrl.generateVariants,
      icon: const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
      label: Text(
        _count > 0
            ? '${'generate_variants_btn'.tr} ($_count ${'variant_count_badge'.tr})'
            : 'generate_variants_btn'.tr,
        style: AppTextStyle.buttonMedium,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primaryDark,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

class _CombinationsTable extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _CombinationsTable({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.greyBorder),
        boxShadow: AppColor.cardShadow,
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
          child: Row(children: [
            const Icon(Icons.table_chart_outlined, size: 15, color: AppColor.primaryColor),
            const SizedBox(width: 7),
            Text('variant_combinations_title'.tr,
                style: AppTextStyle.heading3.copyWith(fontSize: 13)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColor.primarySurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${ctrl.formVariants.length} ${'variant_count_badge'.tr}',
                style: AppTextStyle.chip.copyWith(
                    color: AppColor.primaryColor, fontWeight: FontWeight.w700, fontSize: 10),
              ),
            ),
          ]),
        ),
        const Divider(height: 12, indent: 14, endIndent: 14, color: AppColor.greyBorder),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          color: AppColor.secondBackground,
          child: Row(children: [
            Expanded(flex: 3, child: Text('variant_col_combination'.tr,
                style: AppTextStyle.labelSmall.copyWith(fontWeight: FontWeight.w700))),
            Expanded(flex: 2, child: Text('variant_col_stock'.tr,
                style: AppTextStyle.labelSmall.copyWith(fontWeight: FontWeight.w700, color: AppColor.error),
                textAlign: TextAlign.center)),
            Expanded(flex: 2, child: Text('variant_col_price'.tr,
                style: AppTextStyle.labelSmall.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center)),
            SizedBox(width: 44, child: Text('variant_col_image'.tr,
                style: AppTextStyle.labelSmall.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center)),
          ]),
        ),
        ...ctrl.formVariants.asMap().entries.map((e) => _VarRow(
          variant: e.value,
          ctrl: ctrl,
          isLast: e.key == ctrl.formVariants.length - 1,
        )),
      ]),
    );
  }
}

class _VarRow extends StatelessWidget {
  final ProductVariantModel variant;
  final SellerInventoryController ctrl;
  final bool isLast;
  const _VarRow({required this.variant, required this.ctrl, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final stockCtrl = ctrl.variantStockCtrls[variant.combinationKey];
    final priceCtrl = ctrl.variantPriceCtrls[variant.combinationKey];
    final hasImage = variant.localImage != null || variant.serverImageUrl != null;

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColor.greyBorder, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(children: [
        Expanded(
          flex: 3,
          child: Text(
            variant.combinationKey,
            style: AppTextStyle.labelMedium.copyWith(fontSize: 11, color: AppColor.black),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _VarField(controller: stockCtrl, hint: '0', isRequired: true),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _VarField(controller: priceCtrl, hint: 'variant_price_hint'.tr, isRequired: false),
          ),
        ),
        SizedBox(
          width: 44,
          child: Center(
            child: GestureDetector(
              onTap: () => ctrl.pickVariantImage(variant.combinationKey),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: hasImage ? AppColor.primarySurface : AppColor.secondBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasImage
                        ? AppColor.primaryColor.withOpacity(0.4)
                        : AppColor.greyBorder,
                  ),
                ),
                child: hasImage
                    ? variant.localImage != null
                    ? ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.file(variant.localImage!, fit: BoxFit.cover))
                    : const Icon(Icons.check_rounded, size: 15, color: AppColor.primaryColor)
                    : const Icon(Icons.camera_alt_outlined, size: 13, color: AppColor.greyLight),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _VarField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final bool isRequired;
  const _VarField({required this.controller, required this.hint, required this.isRequired});

  @override
  Widget build(BuildContext context) {
    final isEmpty = controller?.text.isEmpty ?? true;
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      style: AppTextStyle.inputText.copyWith(fontSize: 12, fontFamily: 'PlayfairDisplay'),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyle.inputHint.copyWith(fontSize: 10),
        filled: true,
        fillColor: isRequired && isEmpty
            ? AppColor.errorLight.withOpacity(0.5)
            : AppColor.secondBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isRequired && isEmpty
                ? AppColor.error.withOpacity(0.4)
                : AppColor.greyBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isRequired && isEmpty
                ? AppColor.error.withOpacity(0.4)
                : AppColor.greyBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColor.primaryColor, width: 1.5),
        ),
      ),
    );
  }
}