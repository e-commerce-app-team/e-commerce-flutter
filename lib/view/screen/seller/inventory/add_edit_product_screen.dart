import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_inventory_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/functions/valid_input.dart';
import 'package:e_commerce/view/screen/seller/inventory/category_management_screen.dart';
import 'package:e_commerce/view/widget/seller/inventory/category_picker_sheet.dart';
import 'package:e_commerce/view/widget/seller/inventory/variant_section.dart';
import 'package:e_commerce/view/widget/seller/inventory/warehouse_stock_section.dart';
import 'package:e_commerce/view/widget/shared/app_text_field.dart';

class AddEditProductScreen extends StatelessWidget {
  const AddEditProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SellerInventoryController>(
      builder: (ctrl) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        appBar: AppBar(
          backgroundColor: AppColor.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text(
            ctrl.isEditing ? 'edit_product_title'.tr : 'add_product_title'.tr,
            style: AppTextStyle.appBarTitle,
          ),
          centerTitle: true,
        ),
        body: Form(
          key: ctrl.formKey,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _SCard(
                      title: 'section_images'.tr,
                      icon: Icons.photo_library_outlined,
                      child: _ImagesSection(ctrl: ctrl),
                    ),
                    const SizedBox(height: 14),
                    _SCard(
                      title: 'section_basic_info'.tr,
                      icon: Icons.info_outline_rounded,
                      child: _BasicInfoSection(ctrl: ctrl),
                    ),
                    const SizedBox(height: 14),
                    _SCard(
                      title: 'section_pricing'.tr,
                      icon: Icons.sell_outlined,
                      child: _PricingSection(ctrl: ctrl),
                    ),
                    const SizedBox(height: 14),
                    _SCard(
                      title: ctrl.isWholesale
                          ? 'section_wholesale_stock'.tr
                          : 'section_stock'.tr,
                      icon: Icons.inventory_2_outlined,
                      child: ctrl.isWholesale
                          ? _WholesaleStockSection(ctrl: ctrl)
                          : _StockSection(ctrl: ctrl),
                    ),
                    const SizedBox(height: 14),
                    if (ctrl.isWholesale) ...[
                      _SCard(
                        title: 'section_shipping_settings'.tr,
                        icon: Icons.local_shipping_outlined,
                        child: _ShippingSection(ctrl: ctrl),
                      ),
                      const SizedBox(height: 14),
                    ],
                    _SCard(
                      title: 'section_variants'.tr,
                      icon: Icons.color_lens_outlined,
                      child: VariantSection(ctrl: ctrl),
                    ),
                    const SizedBox(height: 14),
                    _SCard(
                      title: 'section_status_options'.tr,
                      icon: Icons.toggle_on_outlined,
                      child: _StatusSection(ctrl: ctrl),
                    ),
                    if (ctrl.isWholesale) ...[
                      const SizedBox(height: 14),
                      _SCard(
                        title: 'section_wholesale_pricing'.tr,
                        icon: Icons.business_center_outlined,
                        child: _WholesalePriceSection(ctrl: ctrl),
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _SaveBar(ctrl: ctrl),
      ),
    );
  }
}

class _ImagesSection extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _ImagesSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (ctrl.productImages.isNotEmpty) ...[
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ctrl.productImages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => Stack(children: [
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.greyBorder),
                  image: DecorationImage(
                    image: FileImage(ctrl.productImages[i]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 4, right: 4,
                child: GestureDetector(
                  onTap: () => ctrl.removeImage(i),
                  child: Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: AppColor.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(Icons.close, size: 11, color: Colors.white),
                  ),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 10),
      ],
      if (ctrl.productImages.isEmpty && ctrl.isEditing && ctrl.editingProduct!.serverImages.isNotEmpty) ...[
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ctrl.editingProduct!.serverImages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColor.greyBorder),
                    image: DecorationImage(
                      image: NetworkImage(ctrl.editingProduct!.serverImages[i]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                    ),
                    child: Text(
                      'current_image_hint'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
      GestureDetector(
        onTap: ctrl.pickProductImages,
        child: Container(
          width: double.infinity,
          height: ctrl.productImages.isEmpty ? 120 : 50,
          decoration: BoxDecoration(
            color: AppColor.primarySurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColor.primaryColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: ctrl.productImages.isEmpty ? 30 : 18,
              color: AppColor.primaryColor,
            ),
            if (ctrl.productImages.isEmpty) ...[
              const SizedBox(height: 6),
              Text('tap_to_add_images'.tr,
                  style: AppTextStyle.labelMedium.copyWith(color: AppColor.primaryColor)),
              Text('images_limit_hint'.tr, style: AppTextStyle.labelSmall),
            ] else
              Text('add_more_images_label'.tr,
                  style: AppTextStyle.labelSmall.copyWith(color: AppColor.primaryColor)),
          ]),
        ),
      ),
    ]);
  }
}

class _BasicInfoSection extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _BasicInfoSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AppField(
        controller: ctrl.nameCtrl,
        label: 'product_name_label'.tr,
        hint: 'product_name_hint'.tr,
        validator: (v) => validInput(v ?? '', 3, 100, 'name'),
      ),
      const SizedBox(height: 14),
      AppField(
        controller: ctrl.descCtrl,
        label: 'product_desc_label'.tr,
        hint: 'product_desc_hint'.tr,
        maxLines: 4,
        validator: null,
      ),
      const SizedBox(height: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('category_field_label'.tr, style: AppTextStyle.inputLabel),
          GestureDetector(
            onTap: () async {
              await Get.to(
                    () => const CategoryManagementScreen(),
                transition: Transition.cupertino,
              );
              ctrl.refreshCategories();
            },
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.settings_outlined, size: 12, color: AppColor.primaryColor),
              const SizedBox(width: 4),
              Text('manage_categories_btn'.tr,
                  style: AppTextStyle.labelSmall.copyWith(
                      color: AppColor.primaryColor, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: CategoryPickerSheet(
                categoryTree: ctrl.categoryTree,
                selectedId: ctrl.formCategoryId,
                onSelect: (cat) => ctrl.setFormCategory(cat.id),
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: AppColor.secondBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ctrl.formCategoryId != null
                    ? AppColor.primaryColor.withOpacity(0.4)
                    : AppColor.greyBorder,
              ),
            ),
            child: Row(children: [
              Icon(
                ctrl.formCategoryId != null
                    ? Icons.label_outline_rounded
                    : Icons.category_outlined,
                size: 16,
                color: ctrl.formCategoryId != null
                    ? AppColor.primaryColor
                    : AppColor.greyLight,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ctrl.formCategoryId != null
                      ? (ctrl.getCategoryName(ctrl.formCategoryId) ?? 'browse_categories_hint'.tr)
                      : 'browse_categories_hint'.tr,
                  style: ctrl.formCategoryId != null
                      ? AppTextStyle.inputText.copyWith(color: AppColor.primaryColor, fontWeight: FontWeight.w600)
                      : AppTextStyle.inputHint,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: ctrl.formCategoryId != null ? AppColor.primaryColor : AppColor.greyLight,
              ),
            ]),
          ),
        ),
      ]),
      const SizedBox(height: 14),
      AppField(
        controller: ctrl.skuCtrl,
        label: 'sku_label'.tr,
        hint: 'sku_hint'.tr,
        validator: null,
      ),
    ]);
  }
}

class _PricingSection extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _PricingSection({required this.ctrl});

  @override
  Widget build(BuildContext context) => Column(children: [
    AppField(
      controller: ctrl.priceCtrl,
      label: 'original_price_label'.tr,
      hint: 'original_price_hint'.tr,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (v) => validInput(v ?? '', 1, 10, 'price'),
    ),
    const SizedBox(height: 14),
    Row(children: [
      Expanded(
        child: AppField(
          controller: ctrl.salePriceCtrl,
          label: 'sale_price_label'.tr,
          hint: 'sale_price_hint'.tr,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: null,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(child: _DatePickerBtn(ctrl: ctrl)),
    ]),
  ]);
}

class _DatePickerBtn extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _DatePickerBtn({required this.ctrl});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () async {
      final d = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 7)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(primary: AppColor.primaryColor)),
          child: child!,
        ),
      );
      if (d != null) {
        ctrl.setSaleEndsAt(
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
      }
    },
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('sale_ends_label'.tr, style: AppTextStyle.inputLabel),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColor.secondBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.greyBorder),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined, size: 15, color: AppColor.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ctrl.formSaleEndsAt ?? 'sale_ends_label'.tr,
              style: ctrl.formSaleEndsAt != null
                  ? AppTextStyle.inputText.copyWith(fontSize: 12)
                  : AppTextStyle.inputHint.copyWith(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
      ),
    ]),
  );
}

class _StockSection extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _StockSection({required this.ctrl});

  @override
  Widget build(BuildContext context) => Column(children: [
    Row(children: [
      Expanded(
        child: AppField(
          controller: ctrl.stockCtrl,
          label: 'available_qty_label'.tr,
          hint: 'available_qty_hint'.tr,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) => validInput(v ?? '', 1, 6, 'stock'),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: AppField(
          controller: ctrl.alertCtrl,
          label: 'alert_qty_label'.tr,
          hint: 'alert_qty_hint'.tr,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: null,
        ),
      ),
    ]),
    const SizedBox(height: 14),
    AppField(
      controller: ctrl.weightCtrl,
      label: 'weight_label'.tr,
      hint: 'weight_hint'.tr,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (v) => validInput(v ?? '', 1, 6, 'stock'),
      helperText: 'weight_helper'.tr,
    ),
  ]);
}

class _WholesaleStockSection extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _WholesaleStockSection({required this.ctrl});

  @override
  Widget build(BuildContext context) => Column(children: [
    WarehouseStockSection(
      warehouses: ctrl.warehouses,
      warehouseQty: ctrl.formData.warehouseQty,
      onQtyChanged: ctrl.setWarehouseQty,
    ),
    const SizedBox(height: 14),
    AppField(
      controller: ctrl.alertCtrl,
      label: 'total_alert_label'.tr,
      hint: 'alert_qty_hint'.tr,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: null,
      helperText: 'total_alert_helper'.tr,
    ),
  ]);
}

class _ShippingSection extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _ShippingSection({required this.ctrl});

  @override
  Widget build(BuildContext context) => Column(children: [
    AppField(
      controller: ctrl.weightCtrl,
      label: 'weight_label'.tr,
      hint: 'weight_hint'.tr,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (v) => validInput(v ?? '', 1, 6, 'stock'),
      helperText: 'weight_helper'.tr,
    ),
    const SizedBox(height: 14),
    _ToggleTile(
      icon: Icons.local_shipping_outlined,
      title: 'free_shipping_title'.tr,
      subtitle: 'free_shipping_sub'.tr,
      value: ctrl.formFreeShipping,
      onChanged: (_) => ctrl.toggleFreeShipping(),
    ),
  ]);
}

class _StatusSection extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _StatusSection({required this.ctrl});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('status_label'.tr, style: AppTextStyle.inputLabel),
      const SizedBox(height: 8),
      Row(children: [
        _StatusToggle(label: 'product_active'.tr, value: 'active', selected: ctrl.formStatus, color: AppColor.success, onTap: () => ctrl.setFormStatus('active')),
        const SizedBox(width: 8),
        _StatusToggle(label: 'product_draft'.tr, value: 'draft', selected: ctrl.formStatus, color: AppColor.grey, onTap: () => ctrl.setFormStatus('draft')),
        const SizedBox(width: 8),
        _StatusToggle(label: 'product_hidden'.tr, value: 'hidden', selected: ctrl.formStatus, color: AppColor.warning, onTap: () => ctrl.setFormStatus('hidden')),
      ]),
      if (!ctrl.isWholesale) ...[
        const SizedBox(height: 14),
        _ToggleTile(
          icon: Icons.local_shipping_outlined,
          title: 'free_shipping_title'.tr,
          subtitle: 'free_shipping_sub'.tr,
          value: ctrl.formFreeShipping,
          onChanged: (_) => ctrl.toggleFreeShipping(),
        ),
      ],
      const SizedBox(height: 14),
      _ToggleTile(
        icon: Icons.money_off_outlined,
        title: 'tax_exempt_title'.tr,
        subtitle: 'tax_exempt_sub'.tr,
        value: ctrl.formTaxExempt,
        onChanged: (_) => ctrl.toggleTaxExempt(),
      ),
      if (ctrl.formTaxExempt) ...[
        const SizedBox(height: 14),
        AppField(
          controller: ctrl.taxExemptReasonCtrl,
          label: 'tax_exempt_reason_label'.tr,
          hint: 'tax_exempt_reason_hint'.tr,
          keyboardType: TextInputType.text,
          validator: (v) => validInput(v ?? '', 3, 200, 'text'),
        ),
      ],
    ],
  );
}

class _WholesalePriceSection extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _WholesalePriceSection({required this.ctrl});

  @override
  Widget build(BuildContext context) => Column(children: [
    _ToggleTile(
      icon: Icons.business_center_outlined,
      title: 'wholesale_toggle_title'.tr,
      subtitle: 'wholesale_toggle_sub'.tr,
      value: ctrl.formWholesale,
      onChanged: (_) => ctrl.toggleWholesale(),
    ),
    if (ctrl.formWholesale) ...[
      const SizedBox(height: 14),
      Row(children: [
        Expanded(
          child: AppField(
            controller: ctrl.wsPrice,
            label: 'wholesale_price_label'.tr,
            hint: 'wholesale_price_hint'.tr,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) => validInput(v ?? '', 1, 10, 'price'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppField(
            controller: ctrl.wsMinQty,
            label: 'wholesale_min_qty_label'.tr,
            hint: 'wholesale_min_qty_hint'.tr,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: null,
          ),
        ),
      ]),
    ],
  ]);
}

class _SaveBar extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _SaveBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final loading = ctrl.formStatusRequest == StatusRequest.loading;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(color: Colors.white, boxShadow: AppColor.bottomNavShadow),
      child: SizedBox(
        width: double.infinity, height: 52,
        child: ElevatedButton(
          onPressed: loading ? null : ctrl.submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
            disabledBackgroundColor: AppColor.primaryColor.withOpacity(0.6),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: loading
              ? const SizedBox(width: 22, height: 22,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text(
            ctrl.isEditing ? 'save_changes_btn'.tr : 'add_product_btn_submit'.tr,
            style: AppTextStyle.buttonLarge,
          ),
        ),
      ),
    );
  }
}

class _SCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppColor.cardShadow,
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Row(children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: AppColor.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: AppColor.primaryColor),
          ),
          const SizedBox(width: 10),
          Text(title, style: AppTextStyle.heading3.copyWith(fontSize: 14)),
        ]),
      ),
      const Divider(height: 18, indent: 16, endIndent: 16, color: AppColor.greyBorder),
      Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: child),
    ]),
  );
}

class _StatusToggle extends StatelessWidget {
  final String label, value, selected;
  final Color color;
  final VoidCallback onTap;
  const _StatusToggle({
    required this.label, required this.value,
    required this.selected, required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSel = value == selected;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(

        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal:8, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSel ? color : AppColor.greyBorder, width: isSel ? 1.5 : 1),
          boxShadow: isSel ? AppColor.cardShadow : null,
        ),
        child: Text(label, style: AppTextStyle.chip.copyWith(
          color: isSel ? Colors.white : AppColor.grey,
          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,fontSize: 11
        )),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool value;
  final void Function(bool) onChanged;
  const _ToggleTile({
    required this.icon, required this.title,
    required this.subtitle, required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 180),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: value ? AppColor.primarySurface : AppColor.secondBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: value ? AppColor.primaryColor.withOpacity(0.3) : AppColor.greyBorder,
      ),
    ),
    child: Row(children: [
      Icon(icon, size: 20, color: value ? AppColor.primaryColor : AppColor.grey),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppTextStyle.labelLarge.copyWith(fontSize: 13)),
        Text(subtitle, style: AppTextStyle.labelSmall),
      ])),
      Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColor.primaryColor),
    ]),
  );
}