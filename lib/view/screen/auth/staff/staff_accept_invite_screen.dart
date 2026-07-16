import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/auth/staff_accept_invite_controller.dart';
import 'package:e_commerce/core/class/handling_dataview.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/functions/valid_input.dart';

/// Screen shown when a staff member clicks the invitation link in their email.
/// They see a form to create their account password and join the store.
class StaffAcceptInviteScreen extends StatelessWidget {
  const StaffAcceptInviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(StaffAcceptInviteController());

    return Scaffold(
      backgroundColor: AppColor.backgroundcolor,
      body: GetBuilder<StaffAcceptInviteController>(
        builder: (c) => HandlingDataRequest(
          statusRequest: c.statusRequest,
          widget: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Form(
                key: c.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ─── Logo / Icon ───────────────────────────────────────
                    _InviteHeaderSection(storeName: c.storeName),
                    const SizedBox(height: 36),

                    // ─── First Name field ──────────────────────────────────
                    _TextField(
                      label:      'First Name', // Ideally localized
                      hint:       'Enter your first name',
                      controller: c.firstNameCtrl,
                      icon:       Icons.person_outline_rounded,
                      validator:  (val) => validInput(val!, 2, 50, 'name'),
                    ),
                    const SizedBox(height: 16),

                    // ─── Last Name field ───────────────────────────────────
                    _TextField(
                      label:      'Last Name',
                      hint:       'Enter your last name',
                      controller: c.lastNameCtrl,
                      icon:       Icons.person_outline_rounded,
                      validator:  (val) => validInput(val!, 2, 50, 'name'),
                    ),
                    const SizedBox(height: 16),

                    // ─── Password field ────────────────────────────────────
                    _PasswordField(
                      label:      'staff_password_label'.tr,
                      hint:       'staff_password_hint'.tr,
                      controller: c.passwordCtrl,
                      isHidden:   c.isPasswordHidden,
                      onToggle:   c.togglePassword,
                      validator:  (val) => validInput(val!, 8, 50, 'password'),
                    ),
                    const SizedBox(height: 16),

                    // ─── Confirm password field ────────────────────────────
                    _PasswordField(
                      label:      'staff_confirm_password_label'.tr,
                      hint:       'staff_confirm_password_hint'.tr,
                      controller: c.confirmPasswordCtrl,
                      isHidden:   c.isConfirmPasswordHidden,
                      onToggle:   c.toggleConfirmPassword,
                      validator:  (val) {
                        if (val != c.passwordCtrl.text) {
                          return 'password_not_match'.tr;
                        }
                        return validInput(val!, 8, 50, 'password');
                      },
                    ),
                    const SizedBox(height: 32),

                    // ─── Submit button ─────────────────────────────────────
                    _AcceptInviteButton(
                      isLoading: c.statusRequest == StatusRequest.loading,
                      onTap:     c.submitAcceptInvite,
                    ),

                    const SizedBox(height: 20),

                    // ─── Hint ──────────────────────────────────────────────
                    Text(
                      'staff_login_hint'.tr,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.bodySmall
                          .copyWith(color: AppColor.greyLight),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header Section ──────────────────────────────────────────────────────────

class _InviteHeaderSection extends StatelessWidget {
  final String storeName;
  const _InviteHeaderSection({required this.storeName});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          // Circular icon
          Container(
            width:  90,
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.primaryColor.withOpacity(0.7),
                  AppColor.primaryColor,
                ],
                begin: Alignment.topLeft,
                end:   Alignment.bottomRight,
              ),
              shape:     BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:      AppColor.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset:     const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.mail_outline_rounded,
              size:  44,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'staff_accept_title'.tr,
            style:     AppTextStyle.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          if (storeName.isNotEmpty) ...[
            Container(
              padding:    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color:        AppColor.primarySurface,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: AppColor.primaryColor.withOpacity(0.2)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.store_outlined,
                    size: 16, color: AppColor.primaryColor),
                const SizedBox(width: 6),
                Text(
                  storeName,
                  style: AppTextStyle.labelLarge
                      .copyWith(color: AppColor.primaryColor),
                ),
              ]),
            ),
            const SizedBox(height: 10),
          ],

          Text(
            'staff_accept_body'.tr,
            style:     AppTextStyle.bodyMedium.copyWith(color: AppColor.greyLight),
            textAlign: TextAlign.center,
          ),
        ],
      );
}

// ─── Text Field (For Names) ───────────────────────────────────────────────────

class _TextField extends StatelessWidget {
  final String            label;
  final String            hint;
  final TextEditingController controller;
  final IconData          icon;
  final String? Function(String?) validator;

  const _TextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyle.labelLarge),
          const SizedBox(height: 8),
          TextFormField(
            controller:  controller,
            validator:   validator,
            decoration:  InputDecoration(
              hintText:       hint,
              hintStyle:      AppTextStyle.bodySmall.copyWith(color: AppColor.greyLight),
              filled:         true,
              fillColor:      AppColor.secondBackground,
              border:         OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:   BorderSide.none,
              ),
              enabledBorder:  OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:   BorderSide(color: AppColor.greyBorder, width: 1),
              ),
              focusedBorder:  OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:   BorderSide(color: AppColor.primaryColor, width: 1.5),
              ),
              prefixIcon: Icon(icon, color: AppColor.greyLight, size: 20),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
            ),
          ),
        ],
      );
}

// ─── Password Field ───────────────────────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  final String            label;
  final String            hint;
  final TextEditingController controller;
  final bool              isHidden;
  final VoidCallback      onToggle;
  final String? Function(String?) validator;

  const _PasswordField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.isHidden,
    required this.onToggle,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyle.labelLarge),
          const SizedBox(height: 8),
          TextFormField(
            controller:  controller,
            obscureText: isHidden,
            validator:   validator,
            decoration:  InputDecoration(
              hintText:       hint,
              hintStyle:      AppTextStyle.bodySmall.copyWith(color: AppColor.greyLight),
              filled:         true,
              fillColor:      AppColor.secondBackground,
              border:         OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:   BorderSide.none,
              ),
              enabledBorder:  OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:   BorderSide(color: AppColor.greyBorder, width: 1),
              ),
              focusedBorder:  OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:   BorderSide(color: AppColor.primaryColor, width: 1.5),
              ),
              prefixIcon: const Icon(Icons.lock_outline_rounded,
                  color: AppColor.greyLight, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  isHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColor.greyLight,
                  size:  20,
                ),
                onPressed: onToggle,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
            ),
          ),
        ],
      );
}

// ─── Accept Invite Button ─────────────────────────────────────────────────────

class _AcceptInviteButton extends StatelessWidget {
  final bool         isLoading;
  final VoidCallback onTap;
  const _AcceptInviteButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
        width:  double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: isLoading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
            elevation:       6,
            shadowColor:     AppColor.primaryColor.withOpacity(0.4),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          child: isLoading
              ? const SizedBox(
                  width:  22,
                  height: 22,
                  child:  CircularProgressIndicator(
                    color:       Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'staff_set_password'.tr,
                    style: AppTextStyle.buttonMedium,
                  ),
                ]),
        ),
      );
}
