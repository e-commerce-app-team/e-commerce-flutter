import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_profile_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';

class ShippingSettingsScreen extends StatelessWidget {
  const ShippingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // نستخدم الكنترولر الموجود مسبقاً (تم حقنه في شاشة البروفايل)
    return GetBuilder<SellerProfileController>(
      builder: (ctrl) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        appBar: AppBar(
          backgroundColor: AppColor.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text('shipping_settings'.tr, style: AppTextStyle.appBarTitle),
          centerTitle: true,
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ---------------- كرت طريقة التوصيل ----------------
                  _Card(
                    title: 'delivery_method'.tr,
                    icon: Icons.local_shipping_outlined,
                    child: Column(children: [
                      _MethodTile(
                        title: 'platform_delivery'.tr,
                        subtitle: 'platform_delivery_desc'.tr,
                        value: 'our_delivery',
                        selected: ctrl.shippingMethod,
                        onTap: () => ctrl.setShippingMethod('our_delivery'),
                      ),
                      const SizedBox(height: 8),
                      _MethodTile(
                        title: 'self_shipping'.tr,
                        subtitle: 'self_shipping_desc'.tr,
                        value: 'self_shipping',
                        selected: ctrl.shippingMethod,
                        onTap: () => ctrl.setShippingMethod('self_shipping'),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // ---------------- كروت تفاصيل الدفع (تظهر فقط إذا كان التوصيل عبر المنصة) ----------------
                  if (ctrl.shippingMethod == 'our_delivery') ...[
                    _Card(
                      title: 'who_pays_shipping'.tr,
                      icon: Icons.payments_outlined,
                      child: Column(children: [
                        _RadioTile(
                          label: 'buyer_pays'.tr,
                          value: 'buyer',
                          groupValue: ctrl.whoPaysShipping, // تأكد أن الاسم whoPaysShipping في الكنترولر
                          onChanged: ctrl.setWhoPays,
                        ),
                        _RadioTile(
                          label: 'seller_pays'.tr,
                          value: 'seller',
                          groupValue: ctrl.whoPaysShipping,
                          onChanged: ctrl.setWhoPays,
                        ),
                        _RadioTile(
                          label: 'conditional_free_shipping'.tr,
                          value: 'conditional',
                          groupValue: ctrl.whoPaysShipping,
                          onChanged: ctrl.setWhoPays,
                        ),
                        if (ctrl.whoPaysShipping == 'conditional') ...[
                          const SizedBox(height: 10),
                          _ShipField(
                            controller: ctrl.thresholdCtrl,
                            label: 'free_shipping_threshold'.tr,
                            hint: '100000',
                          ),
                        ],
                      ]),
                    ),
                    const SizedBox(height: 14),

                    // ---------------- كرت حساب رسوم الشحن ----------------
                    _Card(
                      title: 'shipping_fee_calc'.tr,
                      icon: Icons.calculate_outlined,
                      child: Column(children: [
                        _ShipField(
                          controller: ctrl.baseFeeCtrl,
                          label: 'base_fee'.tr,
                          hint: '2000',
                        ),
                        const SizedBox(height: 12),
                        _ShipField(
                          controller: ctrl.perKmCtrl,
                          label: 'price_per_km'.tr,
                          hint: '100',
                        ),
                        const SizedBox(height: 12),
                        _ShipField(
                          controller: ctrl.perKgCtrl,
                          label: 'price_per_kg'.tr,
                          hint: '500',
                        ),
                        const SizedBox(height: 14),

                        // رسالة تنبيهية (Preview) توضح كيفية الحساب
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColor.primarySurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColor.primaryColor.withOpacity(0.2),
                            ),
                          ),
                          child: Row(children: [
                            const Icon(Icons.info_outline_rounded,
                                size: 16, color: AppColor.primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${'shipping_example_prefix'.tr} ${_calcPreview(ctrl)} ${'syp'.tr}',
                                style: AppTextStyle.labelSmall.copyWith(
                                  color: AppColor.primaryColor,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ]),
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _SaveBar(ctrl: ctrl),
      ),
    );
  }

  // دالة صغيرة داخلية لحساب المعاينة (يُفضل لاحقاً نقلها للكنترولر إذا كبرت)
  int _calcPreview(SellerProfileController ctrl) {
    final base  = int.tryParse(ctrl.baseFeeCtrl.text)  ?? 2000;
    final perKm = int.tryParse(ctrl.perKmCtrl.text)    ?? 100;
    final perKg = int.tryParse(ctrl.perKgCtrl.text)    ?? 500;
    return base + (perKm * 4) + (perKg * 2);
  }
}

// =========================================================================
// WIDGETS الخاصة بالشحن (أنيقة ومعزولة)
// =========================================================================

class _MethodTile extends StatelessWidget {
  final String title, subtitle, value, selected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primarySurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColor.primaryColor : AppColor.greyBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColor.primaryColor : AppColor.greyLight,
                width: isSelected ? 5 : 2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyle.labelLarge.copyWith(
                      color: isSelected ? AppColor.primaryColor : AppColor.black,
                      fontSize: 13,
                    )),
                Text(subtitle, style: AppTextStyle.labelSmall.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _RadioTile extends StatelessWidget {
  final String label, value, groupValue;
  final void Function(String) onChanged;

  const _RadioTile({
    required this.label, required this.value,
    required this.groupValue, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => RadioListTile<String>(
    value: value,
    groupValue: groupValue,
    onChanged: (v) { if (v != null) onChanged(v); },
    title: Text(label, style: AppTextStyle.labelLarge.copyWith(fontSize: 13)),
    activeColor: AppColor.primaryColor,
    contentPadding: EdgeInsets.zero,
    visualDensity: VisualDensity.compact,
  );
}

class _ShipField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;

  const _ShipField({
    required this.controller, required this.label, required this.hint,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyle.inputLabel),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppTextStyle.inputText,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyle.inputHint,
          filled: true,
          fillColor: AppColor.secondBackground,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.greyBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.greyBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.primaryColor, width: 1.5)),
          suffixText: 'syp'.tr,
          suffixStyle: AppTextStyle.labelSmall,
        ),
      ),
    ],
  );
}

class _Card extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _Card({
    required this.title, required this.icon, required this.child,
  });

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
      const Divider(height: 16, indent: 16, endIndent: 16, color: AppColor.greyBorder),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: child,
      ),
    ]),
  );
}

class _SaveBar extends StatelessWidget {
  final SellerProfileController ctrl;
  const _SaveBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final loading = ctrl.saveStatusRequest == StatusRequest.loading;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(color: Colors.white, boxShadow: AppColor.bottomNavShadow),
      child: SizedBox(
        width: double.infinity, height: 50,
        child: ElevatedButton(
          onPressed: loading ? null : ctrl.saveShipping,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: loading
              ? const SizedBox(width: 22, height: 22,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text('save_settings'.tr, style: AppTextStyle.buttonLarge),
        ),
      ),
    );
  }
}