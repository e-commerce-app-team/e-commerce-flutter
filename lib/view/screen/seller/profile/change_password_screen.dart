import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/change_password_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ChangePasswordController());
    return GetBuilder<ChangePasswordController>(
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
          title: Text('change_password'.tr, style: AppTextStyle.appBarTitle),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            children: [
              _SecurityTipCard(),
              const SizedBox(height: 16),
              _PasswordFormCard(ctrl: ctrl),
              const SizedBox(height: 16),
              _ForgotPasswordLink(ctrl: ctrl),
            ],
          ),
        ),
        bottomNavigationBar: _SaveBar(ctrl: ctrl),
      ),
    );
  }
}

class _SecurityTipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColor.infoLight,
          AppColor.primarySurface,
        ],
      ),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColor.info.withOpacity(0.2)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColor.info.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.security_rounded,
              size: 18, color: AppColor.info),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('security_tip_title'.tr,
                  style: AppTextStyle.labelLarge.copyWith(
                      color: AppColor.infoDark, fontSize: 13)),
              const SizedBox(height: 4),
              Text('security_tip_body'.tr,
                  style: AppTextStyle.labelSmall.copyWith(
                      color: AppColor.infoDark.withOpacity(0.8),
                      height: 1.5,
                      fontSize: 11)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PasswordFormCard extends StatelessWidget {
  final ChangePasswordController ctrl;
  const _PasswordFormCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColor.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColor.primarySurface,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    size: 16, color: AppColor.primaryColor),
              ),
              const SizedBox(width: 10),
              Text('change_password'.tr,
                  style: AppTextStyle.heading3.copyWith(fontSize: 14)),
            ]),
          ),
          const Divider(
              height: 20, indent: 16, endIndent: 16, color: AppColor.greyBorder),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(children: [
              _PwdField(
                controller: ctrl.currentPwdCtrl,
                label: 'current_password_label'.tr,
                hint: 'current_password_hint'.tr,
                obscure: !ctrl.showCurrent,
                onToggle: ctrl.toggleShowCurrent,
              ),
              const SizedBox(height: 16),
              _PwdField(
                controller: ctrl.newPwdCtrl,
                label: 'new_password_label'.tr,
                hint: 'new_password_hint'.tr,
                obscure: !ctrl.showNew,
                onToggle: ctrl.toggleShowNew,
                onChanged: ctrl.onNewPasswordChanged,
              ),
              if (ctrl.newPwdCtrl.text.isNotEmpty) ...[
                const SizedBox(height: 10),
                _StrengthBar(strength: ctrl.passwordStrength),
                const SizedBox(height: 10),
                _RequirementsPanel(ctrl: ctrl),
              ],
              const SizedBox(height: 16),
              _PwdField(
                controller: ctrl.confirmPwdCtrl,
                label: 'confirm_new_password_label'.tr,
                hint: 'confirm_new_password_hint'.tr,
                obscure: !ctrl.showConfirm,
                onToggle: ctrl.toggleShowConfirm,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _PwdField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;
  final void Function(String)? onChanged;

  const _PwdField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.obscure,
    required this.onToggle,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyle.inputLabel),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        obscureText: obscure,
        onChanged: onChanged,
        style: AppTextStyle.inputText,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyle.inputHint,
          filled: true,
          fillColor: AppColor.secondBackground,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColor.grey,
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColor.greyBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColor.greyBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            const BorderSide(color: AppColor.primaryColor, width: 1.5),
          ),
        ),
      ),
    ],
  );
}

class _StrengthBar extends StatelessWidget {
  final int strength;
  const _StrengthBar({required this.strength});

  Color get _color {
    if (strength <= 2) return AppColor.error;
    if (strength <= 4) return AppColor.warning;
    if (strength == 5) return AppColor.success;
    return AppColor.statAvg;
  }

  String get _label {
    if (strength <= 2) return 'strength_weak'.tr;
    if (strength <= 4) return 'strength_medium'.tr;
    if (strength == 5) return 'strength_strong'.tr;
    return 'strength_very_strong'.tr;
  }

  double get _progress => (strength / 6).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) => Row(children: [
    Text('${'strength_label'.tr}: ',
        style: AppTextStyle.labelSmall.copyWith(fontSize: 11)),
    Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 6,
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: AppColor.greyBorder,
            valueColor: AlwaysStoppedAnimation<Color>(_color),
          ),
        ),
      ),
    ),
    const SizedBox(width: 10),
    AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Text(
        _label,
        key: ValueKey(_label),
        style: AppTextStyle.labelSmall.copyWith(
          color: _color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    ),
  ]);
}

class _RequirementsPanel extends StatelessWidget {
  final ChangePasswordController ctrl;
  const _RequirementsPanel({required this.ctrl});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColor.secondBackground,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColor.greyBorder),
    ),
    child: Column(children: [
      _ReqRow(met: ctrl.hasMinLength, text: 'req_min_length'.tr),
      _ReqRow(met: ctrl.hasUppercase, text: 'req_uppercase'.tr),
      _ReqRow(met: ctrl.hasLowercase, text: 'req_lowercase'.tr),
      _ReqRow(met: ctrl.hasNumber, text: 'req_number'.tr),
    ]),
  );
}

class _ReqRow extends StatelessWidget {
  final bool met;
  final String text;
  const _ReqRow({required this.met, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: met ? AppColor.success : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: met ? AppColor.success : AppColor.greyBorder,
            width: 1.5,
          ),
        ),
        child: met
            ? const Icon(Icons.check_rounded, size: 11, color: Colors.white)
            : null,
      ),
      const SizedBox(width: 8),
      Text(
        text,
        style: AppTextStyle.labelSmall.copyWith(
          color: met ? AppColor.success : AppColor.grey,
          fontSize: 11,
        ),
      ),
    ]),
  );
}

class _ForgotPasswordLink extends StatelessWidget {
  final ChangePasswordController ctrl;
  const _ForgotPasswordLink({required this.ctrl});

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (_) => _ForgotPasswordSheet(ctrl: ctrl),
    ).then((_) => ctrl.onForgotSheetClosed());
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => _openSheet(context),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColor.cardShadow,
        border: Border.all(
            color: AppColor.primaryColor.withOpacity(0.15)),
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColor.primarySurface,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(Icons.key_outlined,
              size: 20, color: AppColor.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'forgot_current_password_link'.tr,
                  style: AppTextStyle.labelLarge.copyWith(
                      color: AppColor.primaryColor, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'reset_via_otp'.tr,
                  style: AppTextStyle.labelSmall.copyWith(fontSize: 11),
                ),
              ]),
        ),
        const Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: AppColor.primaryColor),
      ]),
    ),
  );
}

class _SaveBar extends StatelessWidget {
  final ChangePasswordController ctrl;
  const _SaveBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final loading = ctrl.statusRequest == StatusRequest.loading;
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
          color: Colors.white, boxShadow: AppColor.bottomNavShadow),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: loading ? null : ctrl.changePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
            disabledBackgroundColor: AppColor.primaryColor.withOpacity(0.6),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: loading
              ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5))
              : Text('change_password_btn'.tr,
              style: AppTextStyle.buttonLarge),
        ),
      ),
    );
  }
}

class _ForgotPasswordSheet extends StatelessWidget {
  final ChangePasswordController ctrl;
  const _ForgotPasswordSheet({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChangePasswordController>(
      builder: (c) => AnimatedPadding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DragHandle(),
              _SheetHeader(ctrl: c),
              const Divider(height: 1, color: AppColor.greyBorder),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: _SheetBody(ctrl: c),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColor.greyBorder,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

class _SheetHeader extends StatelessWidget {
  final ChangePasswordController ctrl;
  const _SheetHeader({required this.ctrl});

  String get _title {
    switch (ctrl.forgotStep) {
      case ForgotPwdStep.sendOtp:
        return 'forgot_pwd_title'.tr;
      case ForgotPwdStep.verifyOtp:
        return 'enter_otp_title'.tr;
      case ForgotPwdStep.newPassword:
        return 'set_new_pwd_title'.tr;
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    child: Row(children: [
      if (ctrl.forgotStep != ForgotPwdStep.sendOtp)
        GestureDetector(
          onTap: ctrl.goBackStep,
          child: Container(
            padding: const EdgeInsets.all(7),
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: AppColor.secondBackground,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.arrow_back_ios_rounded,
                size: 13, color: AppColor.grey),
          ),
        ),
      Expanded(
        child: Text(_title, style: AppTextStyle.heading3),
      ),
      _StepBadge(step: ctrl.forgotStep),
    ]),
  );
}

class _StepBadge extends StatelessWidget {
  final ForgotPwdStep step;
  const _StepBadge({required this.step});

  int get _current => step.index + 1;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(3, (i) {
      final active = i <= step.index;
      final isCurrent = i == step.index;
      return Row(mainAxisSize: MainAxisSize.min, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCurrent ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? AppColor.primaryColor
                : AppColor.greyBorder,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        if (i < 2)
          Container(
            width: 6,
            height: 1.5,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            color: i < step.index
                ? AppColor.primaryColor
                : AppColor.greyBorder,
          ),
      ]);
    }),
  );
}

class _SheetBody extends StatelessWidget {
  final ChangePasswordController ctrl;
  const _SheetBody({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    switch (ctrl.forgotStep) {
      case ForgotPwdStep.sendOtp:
        return _SendOTPStep(ctrl: ctrl);
      case ForgotPwdStep.verifyOtp:
        return _VerifyOTPStep(ctrl: ctrl);
      case ForgotPwdStep.newPassword:
        return _NewPasswordStep(ctrl: ctrl);
    }
  }
}

class _SendOTPStep extends StatelessWidget {
  final ChangePasswordController ctrl;
  const _SendOTPStep({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final loading = ctrl.forgotStatus == StatusRequest.loading;
    return Column(children: [
      Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          gradient: AppColor.mainGradient,
          shape: BoxShape.circle,
          boxShadow: AppColor.primaryShadow,
        ),
        child: const Icon(Icons.lock_reset_rounded,
            size: 32, color: Colors.white),
      ),
      const SizedBox(height: 20),
      Text(
        'forgot_pwd_sub'.tr,
        style: AppTextStyle.bodyMedium.copyWith(
            fontSize: 13, height: 1.6),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: AppColor.primarySurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColor.primaryColor.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined,
                size: 18, color: AppColor.primaryColor),
            const SizedBox(width: 10),
            Text(
              ctrl.maskedEmail,
              style: AppTextStyle.labelLarge.copyWith(
                  color: AppColor.primaryColor,
                  fontFamily: 'PlayfairDisplay'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 28),
      SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: loading ? null : ctrl.sendForgotOTP,
          icon: loading
              ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.send_rounded,
              size: 18, color: Colors.white),
          label: Text('send_otp_btn'.tr,
              style: AppTextStyle.buttonLarge),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    ]);
  }
}

class _VerifyOTPStep extends StatelessWidget {
  final ChangePasswordController ctrl;
  const _VerifyOTPStep({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final loading = ctrl.forgotStatus == StatusRequest.loading;
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColor.successLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.success.withOpacity(0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.mark_email_read_outlined,
              size: 18, color: AppColor.success),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyle.labelSmall.copyWith(
                    color: AppColor.successDark, fontSize: 12, height: 1.5),
                children: [
                  TextSpan(text: '${'otp_sent_to'.tr} '),
                  TextSpan(
                    text: ctrl.maskedEmail,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'PlayfairDisplay'),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 28),
      OtpTextField(
        numberOfFields: 6,
        showFieldAsBox: true,
        fieldWidth: 46.0,
        borderRadius: BorderRadius.circular(12),
        borderColor: AppColor.greyBorder,
        focusedBorderColor: AppColor.primaryColor,
        borderWidth: 1.5,
        textStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColor.primaryColor,
          fontFamily: 'PlayfairDisplay',
        ),
        onCodeChanged: ctrl.onOTPChanged,
        onSubmit: ctrl.onOTPChanged,
      ),
      const SizedBox(height: 20),
      _ResendRow(ctrl: ctrl),
      const SizedBox(height: 28),
      SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: loading ? null : ctrl.verifyOTP,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
            disabledBackgroundColor: AppColor.primaryColor.withOpacity(0.6),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: loading
              ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5))
              : Text('verify_otp_btn'.tr,
              style: AppTextStyle.buttonLarge),
        ),
      ),
    ]);
  }
}

class _ResendRow extends StatelessWidget {
  final ChangePasswordController ctrl;
  const _ResendRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (ctrl.resendSeconds > 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_outlined,
              size: 14, color: AppColor.greyLight),
          const SizedBox(width: 6),
          Text(
            '${'resend_in_label'.tr} ${ctrl.resendSeconds} ${'seconds_label'.tr}',
            style: AppTextStyle.labelSmall.copyWith(fontSize: 12),
          ),
        ],
      );
    }
    return GestureDetector(
      onTap: ctrl.resendOTP,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColor.primaryColor.withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.refresh_rounded,
              size: 15, color: AppColor.primaryColor),
          const SizedBox(width: 6),
          Text('resend_otp_btn'.tr,
              style: AppTextStyle.labelMedium.copyWith(
                  color: AppColor.primaryColor, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _NewPasswordStep extends StatelessWidget {
  final ChangePasswordController ctrl;
  const _NewPasswordStep({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final loading = ctrl.forgotStatus == StatusRequest.loading;
    return Column(children: [
      Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColor.successLight,
          shape: BoxShape.circle,
          border: Border.all(
              color: AppColor.success.withOpacity(0.3), width: 2),
        ),
        child: const Icon(Icons.verified_rounded,
            size: 30, color: AppColor.success),
      ),
      const SizedBox(height: 16),
      Text(
        'set_new_pwd_title'.tr,
        style: AppTextStyle.heading3,
      ),
      const SizedBox(height: 24),
      _PwdField(
        controller: ctrl.forgotNewPwdCtrl,
        label: 'new_password_label'.tr,
        hint: 'new_password_hint'.tr,
        obscure: !ctrl.showForgotNew,
        onToggle: ctrl.toggleShowForgotNew,
        onChanged: ctrl.onForgotNewPasswordChanged,
      ),
      if (ctrl.forgotNewPwdCtrl.text.isNotEmpty) ...[
        const SizedBox(height: 10),
        _StrengthBar(strength: ctrl.forgotNewStrength),
      ],
      const SizedBox(height: 14),
      _PwdField(
        controller: ctrl.forgotConfirmPwdCtrl,
        label: 'confirm_new_password_label'.tr,
        hint: 'confirm_new_password_hint'.tr,
        obscure: !ctrl.showForgotConfirm,
        onToggle: ctrl.toggleShowForgotConfirm,
      ),
      const SizedBox(height: 28),
      SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: loading ? null : ctrl.resetPasswordViaOTP,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
            disabledBackgroundColor: AppColor.primaryColor.withOpacity(0.6),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: loading
              ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5))
              : Text('save_new_pwd_btn'.tr,
              style: AppTextStyle.buttonLarge),
        ),
      ),
    ]);
  }
}