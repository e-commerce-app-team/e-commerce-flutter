import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_inventory_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/functions/valid_input.dart';
import 'package:e_commerce/view/screen/seller/inventory/category_management_screen.dart';
import 'package:e_commerce/view/widget/seller/inventory/warehouse_stock_section.dart';

import '../../../widget/shared/app_text_field.dart';

class AddEditProductScreen extends StatelessWidget {
  const AddEditProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SellerInventoryController>(
      builder: (ctrl) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        appBar: _buildAppBar(ctrl),
        body: Form(
          key: ctrl.formKey,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    _SectionCard(
                      title: 'صور المنتج',
                      icon: Icons.photo_library_outlined,
                      child: _ImagesSection(ctrl: ctrl),
                    ),
                    const SizedBox(height: 14),

                    _SectionCard(
                      title: 'المعلومات الأساسية',
                      icon: Icons.info_outline_rounded,
                      child: _BasicInfoSection(ctrl: ctrl),
                    ),
                    const SizedBox(height: 14),

                    _SectionCard(
                      title: 'السعر والعرض',
                      icon: Icons.sell_outlined,
                      child: _PricingSection(ctrl: ctrl),
                    ),
                    const SizedBox(height: 14),


                    _SectionCard(
                      title: ctrl.isWholesale
                          ? 'توزيع المخزون على المستودعات'
                          : 'المخزون والشحن',
                      icon: Icons.inventory_2_outlined,
                      child: ctrl.isWholesale
                          ? _WholesaleStockSection(ctrl: ctrl)
                          : _StockSection(ctrl: ctrl),
                    ),
                    const SizedBox(height: 14),

                    if (ctrl.isWholesale) ...[
                      _SectionCard(
                        title: 'إعدادات الشحن',
                        icon: Icons.local_shipping_outlined,
                        child: _ShippingOnlySection(ctrl: ctrl),
                      ),
                      const SizedBox(height: 14),
                    ],

                    _SectionCard(
                      title: 'حالة المنتج والخيارات',
                      icon: Icons.toggle_on_outlined,
                      child: _StatusSection(ctrl: ctrl),
                    ),

                    if (ctrl.isWholesale) ...[
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: 'سعر الجملة للتجار (اختياري)',
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

  PreferredSizeWidget _buildAppBar(SellerInventoryController ctrl) =>
      AppBar(
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          ctrl.isEditing ? 'تعديل المنتج' : 'إضافة منتج جديد',
          style: AppTextStyle.appBarTitle,
        ),
        centerTitle: true,
      );
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
                      color: AppColor.error, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(Icons.close,
                        size: 12, color: Colors.white),
                  ),
                ),
              ),
            ]),
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
                color: AppColor.primaryColor.withOpacity(0.3), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined,
                  size: ctrl.productImages.isEmpty ? 32 : 20,
                  color: AppColor.primaryColor),
              if (ctrl.productImages.isEmpty) ...[
                const SizedBox(height: 8),
                Text('اضغط لإضافة صور',
                    style: AppTextStyle.labelMedium
                        .copyWith(color: AppColor.primaryColor)),
                Text('حتى 10 صور · JPG/PNG',
                    style: AppTextStyle.labelSmall),
              ] else
                Text('إضافة المزيد',
                    style: AppTextStyle.labelSmall.copyWith(
                        color: AppColor.primaryColor)),
            ],
          ),
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
        label: 'اسم المنتج *',
        hint: 'مثال: حقيبة جلدية يدوية',
        validator: (v) => validInput(v ?? '', 3, 100, 'name'),
      ),
      const SizedBox(height: 14),
      AppField(
        controller: ctrl.descCtrl,
        label: 'الوصف التفصيلي',
        hint: 'اكتب وصفاً جذاباً للمنتج...',
        maxLines: 4, validator: null,
      ),
      const SizedBox(height: 14),

      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('القسم *', style: AppTextStyle.inputLabel),
            GestureDetector(
    onTap: () async {
    await Get.to(
    () => const CategoryManagementScreen(),
    transition: Transition.cupertino,
    );ctrl.refreshCategories();
    },

              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.settings_outlined,
                    size: 13, color: AppColor.primaryColor),
                const SizedBox(width: 4),
                Text('إدارة الأقسام',
                    style: AppTextStyle.labelSmall.copyWith(
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColor.secondBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.greyBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<int>(
                value: ctrl.formCategoryId,
                isExpanded: true,
                hint: Text('اختر القسم', style: AppTextStyle.inputHint),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColor.grey),
                borderRadius: BorderRadius.circular(12),
                items: ctrl.categories.map((cat) => DropdownMenuItem(
                  value: cat.id,
                  child: Text(cat.name, style: AppTextStyle.inputText),
                )).toList(),
                onChanged: ctrl.setFormCategory,
              ),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 14),
      AppField(
        controller: ctrl.skuCtrl,
        label: 'رقم المنتج (SKU)',
        hint: 'مثال: SKU-0041',
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
      label: 'السعر الأصلي (ل.س) *',
      hint: 'مثال: 45000',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (v) => validInput(v ?? '', 1, 10, 'price'),
    ),
    const SizedBox(height: 14),
    Row(children: [
      Expanded(
        child: AppField(
          controller: ctrl.salePriceCtrl,
          label: 'سعر العرض',
          hint: 'اختياري',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: null,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(child: _DatePickerField(ctrl: ctrl)),
    ]),
  ]);
}

class _DatePickerField extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _DatePickerField({required this.ctrl});

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
              colorScheme: const ColorScheme.light(
                  primary: AppColor.primaryColor)),
          child: child!,
        ),
      );
      if (d != null) ctrl.setSaleEndsAt(
          '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}');
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColor.secondBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.greyBorder),
      ),
      child: Row(children: [
        const Icon(Icons.calendar_today_outlined,
            size: 16, color: AppColor.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            ctrl.formSaleEndsAt ?? 'تاريخ انتهاء العرض',
            style: ctrl.formSaleEndsAt != null
                ? AppTextStyle.inputText.copyWith(fontSize: 12)
                : AppTextStyle.inputHint.copyWith(fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    ),
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
          label: 'الكمية المتاحة *',
          hint: '0',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) => validInput(v ?? '', 1, 6, 'stock'),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: AppField(
          controller: ctrl.alertCtrl,
          label: 'حد التنبيه',
          hint: '5',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: null,
        ),
      ),
    ]),
    const SizedBox(height: 14),
    AppField(
      controller: ctrl.weightCtrl,
      label: 'الوزن بالغرام *',
      hint: 'مثال: 900',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (v) => validInput(v ?? '', 1, 6, 'weight'),
      helperText: 'يُستخدم لحساب رسوم الشحن تلقائياً',
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
      label: 'حد التنبيه الإجمالي',
      hint: '5',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: null,
      helperText: 'تنبيه عندما يصل إجمالي المخزون لهذا الرقم',
    ),
  ]);
}

class _ShippingOnlySection extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _ShippingOnlySection({required this.ctrl});

  @override
  Widget build(BuildContext context) => Column(children: [
    AppField(
      controller: ctrl.weightCtrl,
      label: 'الوزن بالغرام *',
      hint: 'مثال: 900',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (v) => validInput(v ?? '', 1, 6, 'weight'),
      helperText: 'يُستخدم لحساب رسوم الشحن',
    ),
    const SizedBox(height: 14),
    _ToggleTile(
      icon: Icons.local_shipping_outlined,
      title: 'شحن مجاني لهذا المنتج',
      subtitle: 'لن يُضاف رسم شحن عند الطلب',
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
      Text('حالة المنتج', style: AppTextStyle.inputLabel),
      const SizedBox(height: 8),
      Row(children: [
        _StatusToggle(label:'نشط',   value:'active', selected:ctrl.formStatus, color:AppColor.success, onTap:()=>ctrl.setFormStatus('active')),
        const SizedBox(width:8),
        _StatusToggle(label:'مسودة', value:'draft',  selected:ctrl.formStatus, color:AppColor.grey,    onTap:()=>ctrl.setFormStatus('draft')),
        const SizedBox(width:8),
        _StatusToggle(label:'مخفي',  value:'hidden', selected:ctrl.formStatus, color:AppColor.warning, onTap:()=>ctrl.setFormStatus('hidden')),
      ]),
      const SizedBox(height: 14),
      if (!ctrl.isWholesale)
        _ToggleTile(
          icon: Icons.local_shipping_outlined,
          title: 'شحن مجاني لهذا المنتج',
          subtitle: 'لن يُضاف رسم شحن عند الطلب',
          value: ctrl.formFreeShipping,
          onChanged: (_) => ctrl.toggleFreeShipping(),
        ),
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
      title: 'تفعيل سعر الجملة',
      subtitle: 'يظهر فقط للتجار المسجلين في المنصة',
      value: ctrl.formWholesale,
      onChanged: (_) => ctrl.toggleWholesale(),
    ),
    if (ctrl.formWholesale) ...[
      const SizedBox(height: 14),
      Row(children: [
        Expanded(
          child: AppField(
            controller: ctrl.wsPrice,
            label: 'سعر الجملة (ل.س)',
            hint: 'مثال: 35000',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) => validInput(v ?? '', 1, 10, 'price'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppField(
            controller: ctrl.wsMinQty,
            label: 'الحد الأدنى للكمية',
            hint: 'مثال: 5',
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
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
          color: Colors.white, boxShadow: AppColor.bottomNavShadow),
      child: SizedBox(
        width: double.infinity, height: 52,
        child: ElevatedButton(
          onPressed: loading ? null : ctrl.submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
            disabledBackgroundColor:
            AppColor.primaryColor.withOpacity(0.6),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: loading
              ? const SizedBox(width: 22, height: 22,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5))
              : Text(
              ctrl.isEditing ? 'حفظ التعديلات' : 'إضافة المنتج',
              style: AppTextStyle.buttonLarge),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title; final IconData icon; final Widget child;
  const _SectionCard({required this.title, required this.icon, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: AppColor.cardShadow),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Row(children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
                color: AppColor.primarySurface,
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 15, color: AppColor.primaryColor),
          ),
          const SizedBox(width: 10),
          Text(title, style: AppTextStyle.heading3.copyWith(fontSize: 14)),
        ]),
      ),
      const Divider(height: 18, indent: 16, endIndent: 16,
          color: AppColor.greyBorder),
      Padding(padding: const EdgeInsets.fromLTRB(16,0,16,16), child: child),
    ]),
  );
}


class _StatusToggle extends StatelessWidget {
  final String label, value, selected; final Color color;
  final VoidCallback onTap;
  const _StatusToggle({required this.label, required this.value,
    required this.selected, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final isSel = value == selected;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSel ? color : AppColor.greyBorder,
              width: isSel ? 1.5 : 1),
          boxShadow: isSel ? AppColor.cardShadow : null,
        ),
        child: Text(label, style: AppTextStyle.chip.copyWith(
          color: isSel ? Colors.white : AppColor.grey,
          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
        )),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon; final String title, subtitle;
  final bool value; final void Function(bool) onChanged;
  const _ToggleTile({required this.icon, required this.title,
    required this.subtitle, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: value ? AppColor.primarySurface : AppColor.secondBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
          color: value
              ? AppColor.primaryColor.withOpacity(0.3) : AppColor.greyBorder),
    ),
    child: Row(children: [
      Icon(icon, size: 20,
          color: value ? AppColor.primaryColor : AppColor.grey),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: AppTextStyle.labelLarge.copyWith(fontSize: 13)),
          Text(subtitle, style: AppTextStyle.labelSmall),
        ]),
      ),
      Switch.adaptive(value: value, onChanged: onChanged,
          activeColor: AppColor.primaryColor),
    ]),
  );
}