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
    return GetBuilder<SellerProfileController>(
      builder: (ctrl) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        appBar: AppBar(
          backgroundColor: AppColor.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text('إعدادات الشحن',
              style: AppTextStyle.appBarTitle),
          centerTitle: true,
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding:
                  const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  _Card(
                    title: 'طريقة التوصيل',
                    icon: Icons.local_shipping_outlined,
                    child: Column(children: [
                      _MethodTile(
                        title: 'توصيل من خلال المنصة',
                        subtitle: 'سائقو المنصة يتولون التوصيل',
                        value: 'our_delivery',
                        selected: ctrl.shippingMethod,
                        onTap: () => ctrl.setShippingMethod('our_delivery'),
                      ),
                      const SizedBox(height: 8),
                      _MethodTile(
                        title: 'شحن ذاتي',
                        subtitle: 'أنت تتولى عملية التوصيل',
                        value: 'self_shipping',
                        selected: ctrl.shippingMethod,
                        onTap: () => ctrl.setShippingMethod('self_shipping'),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  if (ctrl.shippingMethod == 'our_delivery') ...[
                    _Card(
                      title: 'من يدفع رسوم الشحن؟',
                      icon: Icons.payments_outlined,
                      child: Column(children: [
                        _RadioTile(
                          label: 'المشتري يدفع',
                          value: 'buyer',
                          groupValue: ctrl.whoPaysSipping,
                          onChanged: ctrl.setWhoPays,
                        ),
                        _RadioTile(
                          label: 'التاجر يدفع',
                          value: 'seller',
                          groupValue: ctrl.whoPaysSipping,
                          onChanged: ctrl.setWhoPays,
                        ),
                        _RadioTile(
                          label: 'شحن مجاني عند تجاوز مبلغ معين',
                          value: 'conditional',
                          groupValue: ctrl.whoPaysSipping,
                          onChanged: ctrl.setWhoPays,
                        ),
                        if (ctrl.whoPaysSipping == 'conditional') ...[
                          const SizedBox(height: 10),
                          _ShipField(
                            controller: ctrl.thresholdCtrl,
                            label: 'المبلغ الأدنى للشحن المجاني (ل.س)',
                            hint: 'مثال: 100000',
                          ),
                        ],
                      ]),
                    ),
                    const SizedBox(height: 14),

                    _Card(
                      title: 'حساب رسوم الشحن',
                      icon: Icons.calculate_outlined,
                      child: Column(children: [
                        _ShipField(
                          controller: ctrl.baseFeeCtrl,
                          label: 'رسوم أساسية ثابتة (ل.س)',
                          hint: 'مثال: 2000',
                        ),
                        const SizedBox(height: 12),
                        _ShipField(
                          controller: ctrl.perKmCtrl,
                          label: 'سعر الكيلومتر (ل.س)',
                          hint: 'مثال: 100',
                        ),
                        const SizedBox(height: 12),
                        _ShipField(
                          controller: ctrl.perKgCtrl,
                          label: 'سعر الكيلوغرام (ل.س)',
                          hint: 'مثال: 500',
                        ),
                        const SizedBox(height: 14),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColor.primarySurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColor.primaryColor
                                  .withOpacity(0.2),
                            ),
                          ),
                          child: Row(children: [
                            const Icon(Icons.info_outline_rounded,
                                size: 16,
                                color: AppColor.primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'مثال: طلب 1.5 كغ · مسافة 4 كم = '
                                '${_calcPreview(ctrl)} ل.س',
                                style: AppTextStyle.labelSmall
                                    .copyWith(
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

  int _calcPreview(SellerProfileController ctrl) {
    final base  = int.tryParse(ctrl.baseFeeCtrl.text)  ?? 2000;
    final perKm = int.tryParse(ctrl.perKmCtrl.text)    ?? 100;
    final perKg = int.tryParse(ctrl.perKgCtrl.text)    ?? 500;
    return base + (perKm * 4) + (perKg * 2);
  }
}

class _MethodTile extends StatelessWidget {
  final String title, subtitle, value, selected;
  final VoidCallback onTap;
  const _MethodTile({
    required this.title, required this.subtitle,
    required this.value, required this.selected, required this.onTap,
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
            color: isSelected
                ? AppColor.primaryColor : AppColor.greyBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppColor.primaryColor : AppColor.greyLight,
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
                      color: isSelected
                          ? AppColor.primaryColor : AppColor.black,
                      fontSize: 13,
                    )),
                Text(subtitle,
                    style: AppTextStyle.labelSmall
                        .copyWith(fontSize: 11)),
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
    value: value, groupValue: groupValue,
    onChanged: (v) { if (v != null) onChanged(v); },
    title: Text(label,
        style: AppTextStyle.labelLarge.copyWith(fontSize: 13)),
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
          hintText: hint, hintStyle: AppTextStyle.inputHint,
          filled: true, fillColor: AppColor.secondBackground,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.greyBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.greyBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColor.primaryColor, width: 1.5)),
          suffixText: 'ل.س',
          suffixStyle: AppTextStyle.labelSmall,
        ),
      ),
    ],
  );
}

class _Card extends StatelessWidget {
  final String title; final IconData icon; final Widget child;
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
          Text(title,
              style: AppTextStyle.heading3.copyWith(fontSize: 14)),
        ]),
      ),
      const Divider(height: 16, indent: 16, endIndent: 16,
          color: AppColor.greyBorder),
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
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: Colors.white, boxShadow: AppColor.bottomNavShadow),
      child: SizedBox(
        width: double.infinity, height: 50,
        child: ElevatedButton(
          onPressed: loading ? null : ctrl.saveShipping,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: loading
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Text('حفظ الإعدادات',
                  style: AppTextStyle.buttonLarge),
        ),
      ),
    );
  }
}


class WithdrawalSheet extends StatelessWidget {
  const WithdrawalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SellerProfileController>(
      builder: (ctrl) => Container(
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColor.greyBorder,
                borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),

            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: const BoxDecoration(
                  color: AppColor.successLight, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_upward_rounded,
                    size: 18, color: AppColor.success),
              ),
              const SizedBox(width: 10),
              Text('طلب سحب',
                  style: AppTextStyle.heading3),
            ]),
            const SizedBox(height: 4),
            if (ctrl.wallet != null)
              Text(
                'الرصيد المتاح: SP ${ctrl.wallet!.balance ~/ 1000}k',
                style: AppTextStyle.bodySmall.copyWith(
                    color: AppColor.success, fontSize: 12),
              ),
            const SizedBox(height: 16),
            const Divider(color: AppColor.greyBorder),
            const SizedBox(height: 14),

            _WithdrawField(
              controller: ctrl.withdrawAmountCtrl,
              label: 'المبلغ (ل.س) *',
              hint: 'الحد الأدنى: SP 10,000',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('طريقة الاستلام',
                    style: AppTextStyle.inputLabel),
                const SizedBox(height: 8),
                Row(children: [
                  _MethodChip(
                    label: 'تحويل بنكي',
                    icon: Icons.account_balance_outlined,
                    value: 'bank_transfer',
                    selected: ctrl.withdrawMethod,
                    onTap: () {
                      ctrl.withdrawMethod = 'bank_transfer';
                      ctrl.update();
                    },
                  ),
                  const SizedBox(width: 10),
                  _MethodChip(
                    label: 'كاش',
                    icon: Icons.payments_outlined,
                    value: 'cash',
                    selected: ctrl.withdrawMethod,
                    onTap: () {
                      ctrl.withdrawMethod = 'cash';
                      ctrl.update();
                    },
                  ),
                ]),
              ],
            ),
            const SizedBox(height: 12),

            if (ctrl.withdrawMethod == 'bank_transfer') ...[
              _WithdrawField(
                controller: ctrl.bankNameCtrl,
                label: 'اسم البنك *',
                hint: 'مثال: بنك سورية',
              ),
              const SizedBox(height: 10),
              _WithdrawField(
                controller: ctrl.accountNumCtrl,
                label: 'رقم الحساب *',
                hint: 'XXXXXXXXXXXX',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 10),
              _WithdrawField(
                controller: ctrl.accountNameCtrl,
                label: 'اسم صاحب الحساب',
                hint: 'كما هو في البنك',
              ),
              const SizedBox(height: 14),
            ],

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColor.warningLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColor.warning.withOpacity(0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColor.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تتم معالجة طلبات السحب خلال 24-48 ساعة عمل',
                    style: AppTextStyle.labelSmall
                        .copyWith(color: AppColor.warningDark, fontSize: 11),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: ctrl.saveStatusRequest == StatusRequest.loading
                    ? null : ctrl.requestWithdrawal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.success,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: ctrl.saveStatusRequest == StatusRequest.loading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Text('تأكيد طلب السحب',
                        style: AppTextStyle.buttonLarge),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _WithdrawField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  const _WithdrawField({
    required this.controller, required this.label, required this.hint,
    this.keyboardType, this.inputFormatters,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyle.inputLabel),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: AppTextStyle.inputText,
        decoration: InputDecoration(
          hintText: hint, hintStyle: AppTextStyle.inputHint,
          filled: true, fillColor: AppColor.secondBackground,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.greyBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.greyBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColor.primaryColor, width: 1.5)),
        ),
      ),
    ],
  );
}

class _MethodChip extends StatelessWidget {
  final String label, value, selected;
  final IconData icon;
  final VoidCallback onTap;
  const _MethodChip({
    required this.label, required this.value,
    required this.selected, required this.icon, required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primarySurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColor.primaryColor : AppColor.greyBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16,
              color: isSelected
                  ? AppColor.primaryColor : AppColor.grey),
          const SizedBox(width: 6),
          Text(label,
              style: AppTextStyle.chip.copyWith(
                color: isSelected
                    ? AppColor.primaryColor : AppColor.grey,
                fontWeight: isSelected
                    ? FontWeight.w700 : FontWeight.w500,
              )),
        ]),
      ),
    );
  }
}
