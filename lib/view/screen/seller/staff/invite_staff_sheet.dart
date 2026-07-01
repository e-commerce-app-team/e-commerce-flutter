// lib/view/screen/seller/staff/invite_staff_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_staff_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/staff_model.dart';

void showInviteStaffSheet(SellerStaffController ctrl) {
  Get.bottomSheet(
    _InviteStaffSheet(ctrl: ctrl),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
  );
}

class _InviteStaffSheet extends StatelessWidget {
  final SellerStaffController ctrl;
  const _InviteStaffSheet({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return GetBuilder<SellerStaffController>(
      builder: (c) => Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: AppColor.secondBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(children: [
          _SheetHandle(),
          _SheetHeader(ctrl: c),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 8, 16, bottom + 16),
              child: Form(
                key: c.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _EmailSection(ctrl: c),
                    const SizedBox(height: 16),
                    _RoleSection(ctrl: c),
                    const SizedBox(height: 16),
                    _PermissionsSection(ctrl: c),
                    const SizedBox(height: 20),
                    _SubmitButton(ctrl: c),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Handle & Header ───────────────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 4),
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: AppColor.greyBorder,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
}

class _SheetHeader extends StatelessWidget {
  final SellerStaffController ctrl;
  const _SheetHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: AppColor.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColor.primaryColor, AppColor.primaryDark],
                begin: Alignment.topLeft,
                end:   Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              ctrl.isEditing
                  ? Icons.manage_accounts_rounded
                  : Icons.person_add_rounded,
              color: Colors.white, size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                ctrl.isEditing
                    ? 'staff_edit_title'.tr
                    : 'staff_invite_title'.tr,
                style: AppTextStyle.heading3.copyWith(fontSize: 16),
              ),
              Text(
                ctrl.isEditing
                    ? 'staff_edit_sub'.tr
                    : 'staff_invite_sub'.tr,
                style: AppTextStyle.labelSmall.copyWith(fontSize: 11),
              ),
            ]),
          ),
          GestureDetector(
            onTap: Get.back,
            child: const Icon(Icons.close_rounded,
                color: AppColor.grey, size: 22),
          ),
        ]),
      );
}

// ─── Email Section ─────────────────────────────────────────────────────────────

class _EmailSection extends StatelessWidget {
  final SellerStaffController ctrl;
  const _EmailSection({required this.ctrl});

  @override
  Widget build(BuildContext context) => _FormCard(
        icon:  Icons.email_outlined,
        title: 'staff_section_email'.tr,
        child: TextFormField(
          controller:      ctrl.emailCtrl,
          keyboardType:    TextInputType.emailAddress,
          readOnly:        ctrl.isEditing,
          textDirection:   TextDirection.ltr,
          style: AppTextStyle.inputText.copyWith(
              fontFamily: 'PlayfairDisplay', fontSize: 14),
          decoration: _fieldDeco(
            label: 'staff_email_label'.tr,
            hint:  'staff_email_hint'.tr,
            icon:  Icons.alternate_email_rounded,
            suffixWidget: ctrl.isEditing
                ? Container(
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColor.successLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('staff_cannot_edit_email'.tr,
                        style: AppTextStyle.badge.copyWith(
                            color: AppColor.successDark, fontSize: 9)),
                  )
                : null,
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'field_required'.tr;
            if (!GetUtils.isEmail(v.trim())) return 'البريد الإلكتروني غير صالح'.tr;
            return null;
          },
        ),
      );
}

// ─── Role Section ─────────────────────────────────────────────────────────────

class _RoleSection extends StatelessWidget {
  final SellerStaffController ctrl;
  const _RoleSection({required this.ctrl});

  @override
  Widget build(BuildContext context) => _FormCard(
        icon:  Icons.badge_outlined,
        title: 'staff_section_role'.tr,
        child: Column(children: [
          Text(
            'staff_role_hint'.tr,
            style: AppTextStyle.bodySmall.copyWith(fontSize: 11.5),
          ),
          const SizedBox(height: 12),
          Row(children: StaffRole.all.map((role) {
            final cfg      = _roleCfg(role);
            final isActive = ctrl.formRole == role;
            return Expanded(
              child: GestureDetector(
                onTap: () => ctrl.setRole(role),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsetsDirectional.only(
                      end: role == StaffRole.all.last ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isActive ? cfg.color : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive ? cfg.color : AppColor.greyBorder,
                      width: isActive ? 1.5 : 1,
                    ),
                    boxShadow: isActive ? [
                      BoxShadow(
                        color:      cfg.color.withOpacity(0.3),
                        blurRadius: 10,
                        offset:     const Offset(0, 4),
                      )
                    ] : null,
                  ),
                  child: Column(children: [
                    Icon(cfg.icon,
                        size:  22,
                        color: isActive ? Colors.white : cfg.color),
                    const SizedBox(height: 5),
                    Text(
                      cfg.labelKey.tr,
                      style: AppTextStyle.chip.copyWith(
                        color: isActive ? Colors.white : AppColor.grey,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ]),
                ),
              ),
            );
          }).toList()),
        ]),
      );

  _RoleVisual _roleCfg(String role) {
    switch (role) {
      case StaffRole.manager:
        return _RoleVisual(
          labelKey: 'staff_role_manager',
          color:    AppColor.statOrders,
          icon:     Icons.manage_accounts_rounded,
        );
      case StaffRole.warehouse:
        return _RoleVisual(
          labelKey: 'staff_role_warehouse',
          color:    AppColor.info,
          icon:     Icons.warehouse_outlined,
        );
      default:
        return _RoleVisual(
          labelKey: 'staff_role_support',
          color:    AppColor.success,
          icon:     Icons.headset_mic_outlined,
        );
    }
  }
}

class _RoleVisual {
  final String  labelKey;
  final Color   color;
  final IconData icon;
  const _RoleVisual({
    required this.labelKey,
    required this.color,
    required this.icon,
  });
}

// ─── Permissions Section ───────────────────────────────────────────────────────

class _PermissionsSection extends StatelessWidget {
  final SellerStaffController ctrl;
  const _PermissionsSection({required this.ctrl});

  @override
  Widget build(BuildContext context) => _FormCard(
        icon:  Icons.lock_outline_rounded,
        title: 'staff_section_permissions'.tr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'staff_permissions_hint'.tr,
              style: AppTextStyle.bodySmall.copyWith(fontSize: 11.5),
            ),
            const SizedBox(height: 12),
            ...StaffPermission.all.map(
              (perm) => _PermissionTile(
                perm:    perm,
                ctrl:    ctrl,
                isLast:  perm == StaffPermission.all.last,
              ),
            ),
          ],
        ),
      );
}

class _PermissionTile extends StatelessWidget {
  final String                perm;
  final SellerStaffController ctrl;
  final bool                  isLast;
  const _PermissionTile({
    required this.perm, required this.ctrl, required this.isLast,
  });

  String get _label {
    switch (perm) {
      case StaffPermission.viewOrders:      return 'perm_view_orders'.tr;
      case StaffPermission.manageInventory: return 'perm_manage_inv'.tr;
      case StaffPermission.viewReports:     return 'perm_view_reports'.tr;
      case StaffPermission.chatWithBuyers:  return 'perm_chat_buyers'.tr;
      default: return perm;
    }
  }

  String get _subtitle {
    switch (perm) {
      case StaffPermission.viewOrders:      return 'perm_view_orders_sub'.tr;
      case StaffPermission.manageInventory: return 'perm_manage_inv_sub'.tr;
      case StaffPermission.viewReports:     return 'perm_view_reports_sub'.tr;
      case StaffPermission.chatWithBuyers:  return 'perm_chat_buyers_sub'.tr;
      default: return '';
    }
  }

  IconData get _icon {
    switch (perm) {
      case StaffPermission.viewOrders:      return Icons.receipt_long_outlined;
      case StaffPermission.manageInventory: return Icons.inventory_2_outlined;
      case StaffPermission.viewReports:     return Icons.bar_chart_rounded;
      case StaffPermission.chatWithBuyers:  return Icons.chat_bubble_outline_rounded;
      default: return Icons.check_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOn = ctrl.formPermissions.contains(perm);
    return Column(children: [
      GestureDetector(
        onTap: () => ctrl.togglePermission(perm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: isOn
                ? AppColor.primaryColor.withOpacity(0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOn
                  ? AppColor.primaryColor.withOpacity(0.3)
                  : AppColor.greyBorder,
              width: isOn ? 1.4 : 0.8,
            ),
          ),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: isOn ? AppColor.primaryColor : AppColor.secondBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon,
                  size:  17,
                  color: isOn ? Colors.white : AppColor.greyLight),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                  _label,
                  style: AppTextStyle.labelLarge.copyWith(
                    fontSize: 13,
                    color: isOn ? AppColor.primaryColor : AppColor.black,
                  ),
                ),
                Text(
                  _subtitle,
                  style: AppTextStyle.labelSmall.copyWith(fontSize: 10.5),
                ),
              ]),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: isOn ? AppColor.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isOn ? AppColor.primaryColor : AppColor.greyBorder,
                  width: 1.5,
                ),
              ),
              child: isOn
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ]),
        ),
      ),
      if (!isLast) const SizedBox(height: 8),
    ]);
  }
}

// ─── Submit Button ─────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  final SellerStaffController ctrl;
  const _SubmitButton({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isLoading = ctrl.formStatusRequest == StatusRequest.loading;
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : ctrl.submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor:         AppColor.primaryColor,
          disabledBackgroundColor: AppColor.primaryColor.withOpacity(0.6),
          elevation:               0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : Text(
                ctrl.isEditing
                    ? 'staff_save_changes'.tr
                    : 'staff_send_invite'.tr,
                style: AppTextStyle.buttonLarge,
              ),
      ),
    );
  }
}

// ─── Shared Card ──────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final IconData icon;
  final String   title;
  final Widget   child;
  const _FormCard({
    required this.icon, required this.title, required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow:    AppColor.cardShadow,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color:        AppColor.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: AppColor.primaryColor),
              ),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyle.heading3.copyWith(fontSize: 13)),
            ]),
          ),
          const Divider(height: 14, indent: 14, endIndent: 14,
              color: AppColor.greyBorder),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: child,
          ),
        ]),
      );
}

// ─── Helper for InputDecoration ───────────────────────────────────────────────

InputDecoration _fieldDeco(
    {required String label,
    required String  hint,
    required IconData icon,
    Widget?  suffixWidget}) {
  return InputDecoration(
    labelText:  label,
    labelStyle: AppTextStyle.inputLabel,
    hintText:   hint,
    hintStyle:  AppTextStyle.inputHint,
    prefixIcon: Icon(icon, size: 18, color: AppColor.grey),
    suffixIcon: suffixWidget,
    filled:     true,
    fillColor:  AppColor.secondBackground,
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColor.greyBorder)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColor.greyBorder)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColor.primaryColor, width: 1.5)),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColor.error)),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColor.error, width: 1.5)),
    errorStyle: AppTextStyle.inputError,
  );
}
