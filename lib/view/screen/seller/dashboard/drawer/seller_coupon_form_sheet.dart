import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_coupons_controller.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/class/status_request.dart';

void showCouponFormSheet(SellerCouponsController ctrl) {
  Get.bottomSheet(
    _CouponFormSheet(ctrl: ctrl),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
  );
}

class _CouponFormSheet extends StatelessWidget {
  final SellerCouponsController ctrl;
  const _CouponFormSheet({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return GetBuilder<SellerCouponsController>(
      builder: (c) => Container(
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: BoxDecoration(
          color: AppColor.backgroundScaffold,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _SheetHandle(),
            _SheetHeader(ctrl: c),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 0, 16, bottom + 16),
                child: Form(
                  key: c.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Section(label: 'section_basic'.tr, children: [
                        _CodeField(ctrl: c),
                        const SizedBox(height: 12),
                        _TypeSelector(ctrl: c),
                        if (c.formType != 'free_shipping') ...[
                          const SizedBox(height: 12),
                          _ValueField(ctrl: c),
                        ],
                      ]),
                      const SizedBox(height: 16),
                      _Section(label: 'section_limits'.tr, children: [
                        _LimitsFields(ctrl: c),
                      ]),
                      const SizedBox(height: 16),
                      _Section(label: 'section_applies'.tr, children: [
                        _AppliesToSelector(ctrl: c),
                        if (c.formAppliesTo == 'category') ...[
                          const SizedBox(height: 12),
                          _CategoryDropdown(ctrl: c),
                        ],
                      ]),
                      const SizedBox(height: 16),
                      _Section(label: 'section_validity'.tr, children: [
                        _DateRow(ctrl: c),
                      ]),
                      const SizedBox(height: 16),
                      _Section(label: 'section_status'.tr, children: [
                        _StatusToggle(ctrl: c),
                      ]),
                      const SizedBox(height: 24),
                      _SubmitButton(ctrl: c),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Center(
        child: Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: AppColor.greyBorder,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final SellerCouponsController ctrl;
  const _SheetHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      decoration: BoxDecoration(
        color: AppColor.white,
        boxShadow: [BoxShadow(color: AppColor.shadow, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColor.primaryColor, AppColor.primaryDark],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(ctrl.isEditing ? Icons.edit_rounded : Icons.add_rounded,
              color: AppColor.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ctrl.isEditing ? 'edit_coupon'.tr : 'add_coupon'.tr,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColor.textPrimary)),
            Text(ctrl.isEditing ? 'edit_coupon_sub'.tr : 'add_coupon_sub'.tr,
                style: TextStyle(fontSize: 11, color: AppColor.greyText)),
          ],
        )),
        IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.close_rounded, color: AppColor.greyText),
        ),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const _Section({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColor.shadow, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
              color: AppColor.primaryColor)),
        ),
        Divider(height: 14, color: AppColor.greyBorder.withOpacity(0.5)),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ]),
    );
  }
}

class _CodeField extends StatelessWidget {
  final SellerCouponsController ctrl;
  const _CodeField({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: TextFormField(
          controller: ctrl.codeCtrl,
          textDirection: TextDirection.ltr,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            LengthLimitingTextInputFormatter(16),
          ],
          style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700,
              letterSpacing: 1.5, fontSize: 14, color: AppColor.textPrimary),
          decoration: _inputDeco('coupon_code'.tr, Icons.local_offer_rounded),
          validator: (v) => v == null || v.isEmpty ? 'field_required'.tr : null,
        ),
      ),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: ctrl.autoGenerateCode,
        child: Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: AppColor.primarySurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.primaryColor.withOpacity(0.3)),
          ),
          child: Icon(Icons.auto_fix_high_rounded, color: AppColor.primaryColor, size: 20),
        ),
      ),
    ]);
  }
}

class _TypeSelector extends StatelessWidget {
  final SellerCouponsController ctrl;
  const _TypeSelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final types = [
      {'key': 'percentage',    'label': 'type_pct'.tr,      'icon': Icons.percent_rounded},
      {'key': 'fixed',         'label': 'type_fixed'.tr,     'icon': Icons.attach_money_rounded},
      {'key': 'free_shipping', 'label': 'type_shipping'.tr,  'icon': Icons.local_shipping_rounded},
    ];
    return Row(
      children: types.map((t) {
        final active = ctrl.formType == t['key'];
        return Expanded(
          child: GestureDetector(
            onTap: () => ctrl.setFormType(t['key'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsetsDirectional.only(
                  end: t == types.last ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: active ? AppColor.primaryColor : AppColor.backgroundScaffold,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: active ? AppColor.primaryColor : AppColor.greyBorder,
                    width: active ? 1.5 : 1),
              ),
              child: Column(children: [
                Icon(t['icon'] as IconData,
                    size: 18,
                    color: active ? AppColor.white : AppColor.greyText),
                const SizedBox(height: 4),
                Text(t['label'] as String,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: active ? AppColor.white : AppColor.greyText)),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ValueField extends StatelessWidget {
  final SellerCouponsController ctrl;
  const _ValueField({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl.valueCtrl,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: _inputDeco(
        ctrl.formType == 'percentage' ? 'value_pct'.tr : 'value_fixed'.tr,
        ctrl.formType == 'percentage' ? Icons.percent_rounded : Icons.attach_money_rounded,
        suffix: ctrl.formType == 'percentage'
            ? Text('%', style: TextStyle(fontWeight: FontWeight.w700, color: AppColor.primaryColor))
            : Text('currency'.tr, style: TextStyle(fontSize: 11, color: AppColor.greyText)),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'field_required'.tr;
        final n = double.tryParse(v) ?? -1;
        if (n <= 0) return 'invalid_value'.tr;
        if (ctrl.formType == 'percentage' && n > 100) return 'max_100'.tr;
        return null;
      },
    );
  }
}

class _LimitsFields extends StatelessWidget {
  final SellerCouponsController ctrl;
  const _LimitsFields({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextFormField(
        controller: ctrl.minOrderCtrl,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: _inputDeco('min_order_field'.tr, Icons.shopping_cart_outlined,
            suffix: Text('currency'.tr, style: TextStyle(fontSize: 11, color: AppColor.greyText))),
      ),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: TextFormField(
          controller: ctrl.maxUsageCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _inputDeco('max_usage_field'.tr, Icons.bar_chart_rounded),
        )),
        const SizedBox(width: 10),
        Expanded(child: TextFormField(
          controller: ctrl.maxPerUserCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _inputDeco('max_per_user'.tr, Icons.person_outline_rounded),
          validator: (v) {
            if (v == null || v.isEmpty) return 'field_required'.tr;
            return null;
          },
        )),
      ]),
    ]);
  }
}

class _AppliesToSelector extends StatelessWidget {
  final SellerCouponsController ctrl;
  const _AppliesToSelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _ChoiceTile(
        label: 'applies_all'.tr,
        icon: Icons.store_rounded,
        active: ctrl.formAppliesTo == 'all',
        onTap: () => ctrl.setAppliesTo('all'),
      ),
      const SizedBox(width: 10),
      _ChoiceTile(
        label: 'applies_cat'.tr,
        icon: Icons.category_rounded,
        active: ctrl.formAppliesTo == 'category',
        onTap: () => ctrl.setAppliesTo('category'),
      ),
    ]);
  }
}

class _ChoiceTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _ChoiceTile({required this.label, required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColor.primarySurface : AppColor.backgroundScaffold,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: active ? AppColor.primaryColor : AppColor.greyBorder,
                width: active ? 1.5 : 1),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 16, color: active ? AppColor.primaryColor : AppColor.greyText),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? AppColor.primaryColor : AppColor.greyText)),
          ]),
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final SellerCouponsController ctrl;
  const _CategoryDropdown({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: ctrl.formCategoryId,
      items: ctrl.categories
          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 13))))
          .toList(),
      onChanged: ctrl.setFormCategory,
      decoration: _inputDeco('select_category'.tr, Icons.category_rounded),
      validator: (v) => v == null ? 'field_required'.tr : null,
    );
  }
}

class _DateRow extends StatelessWidget {
  final SellerCouponsController ctrl;
  const _DateRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _DatePicker(
        label: 'start_date'.tr,
        value: ctrl.formStartDate,
        icon: Icons.calendar_today_rounded,
        onPick: (d) => ctrl.setStartDate(d),
        firstDate: DateTime(2024),
        lastDate: DateTime(2030),
      )),
      const SizedBox(width: 10),
      Expanded(child: _DatePicker(
        label: 'end_date'.tr,
        value: ctrl.formEndDate,
        icon: Icons.event_rounded,
        onPick: (d) => ctrl.setEndDate(d),
        firstDate: DateTime.now(),
        lastDate: DateTime(2030),
      )),
    ]);
  }
}

class _DatePicker extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;
  final Function(String) onPick;
  final DateTime firstDate;
  final DateTime lastDate;
  const _DatePicker({
    required this.label, required this.value, required this.icon,
    required this.onPick, required this.firstDate, required this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    final parts     = hasValue ? value!.split('-') : null;
    final display   = parts != null ? '${parts[2]}/${parts[1]}/${parts[0]}' : '';

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: hasValue ? DateTime.parse(value!) : DateTime.now(),
          firstDate: firstDate,
          lastDate: lastDate,
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: ColorScheme.light(primary: AppColor.primaryColor),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          onPick(
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}',
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: AppColor.backgroundScaffold,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.greyBorder),
        ),
        child: Row(children: [
          Icon(icon, size: 16, color: hasValue ? AppColor.primaryColor : AppColor.greyText),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              hasValue ? display : label,
              style: TextStyle(
                  fontSize: 12,
                  color: hasValue ? AppColor.textPrimary : AppColor.greyText,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
      ),
    );
  }
}

class _StatusToggle extends StatelessWidget {
  final SellerCouponsController ctrl;
  const _StatusToggle({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final statuses = ['active', 'paused'];
    return Row(
      children: statuses.map((s) {
        final active = ctrl.formStatus == s;
        final color  = s == 'active' ? AppColor.success : AppColor.warning;
        return Expanded(child: GestureDetector(
          onTap: () => ctrl.setFormStatus(s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: s == 'active' ? EdgeInsetsDirectional.only(end: 8) : EdgeInsets.zero,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: active ? color.withOpacity(0.12) : AppColor.backgroundScaffold,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: active ? color : AppColor.greyBorder, width: active ? 1.5 : 1),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 8, height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(s == 'active' ? 'active'.tr : 'paused'.tr,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                      color: active ? color : AppColor.greyText)),
            ]),
          ),
        ));
      }).toList(),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final SellerCouponsController ctrl;
  const _SubmitButton({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final loading = ctrl.formStatusRequest == StatusRequest.loading;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : ctrl.submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          disabledBackgroundColor: AppColor.primaryColor.withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: loading
            ? SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: AppColor.white),
              )
            : Text(
                ctrl.isEditing ? 'save_changes'.tr : 'add_coupon'.tr,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColor.white,
                    letterSpacing: 0.3),
              ),
      ),
    );
  }
}

InputDecoration _inputDeco(String label, IconData icon, {Widget? suffix}) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(fontSize: 13, color: AppColor.greyText),
    prefixIcon: Icon(icon, size: 18, color: AppColor.greyText),
    suffixIcon: suffix != null ? Padding(padding: const EdgeInsets.only(left: 12, right: 8), child: suffix) : null,
    suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
    filled: true,
    fillColor: AppColor.backgroundScaffold,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColor.greyBorder)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColor.greyBorder)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColor.primaryColor, width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColor.danger)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColor.danger, width: 1.5)),
  );
}
