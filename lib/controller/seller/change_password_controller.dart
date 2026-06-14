import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/data/datasource/remote/seller/change_password_data.dart';

enum ForgotPwdStep { sendOtp, verifyOtp, newPassword }

class ChangePasswordController extends GetxController {
  MyServices myServices = Get.find();
  ChangePasswordData changePasswordData = ChangePasswordData(Get.find());

  StatusRequest statusRequest = StatusRequest.none;
  StatusRequest forgotStatus = StatusRequest.none;

  final currentPwdCtrl = TextEditingController();
  final newPwdCtrl = TextEditingController();
  final confirmPwdCtrl = TextEditingController();

  bool showCurrent = false;
  bool showNew = false;
  bool showConfirm = false;
  int passwordStrength = 0;

  ForgotPwdStep forgotStep = ForgotPwdStep.sendOtp;
  String otpValue = '';
  int resendSeconds = 0;
  Timer? _resendTimer;

  final forgotNewPwdCtrl = TextEditingController();
  final forgotConfirmPwdCtrl = TextEditingController();
  bool showForgotNew = false;
  bool showForgotConfirm = false;
  int forgotNewStrength = 0;

  String get maskedEmail {
    final email = myServices.sharedPreferences.getString('email') ?? '';
    if (email.isEmpty) return '';
    final at = email.indexOf('@');
    if (at <= 0) return email;
    final user = email.substring(0, at);
    final domain = email.substring(at);
    final masked = user.length > 3
        ? '${user.substring(0, 2)}${'*' * (user.length - 3)}${user[user.length - 1]}'
        : user;
    return '$masked$domain';
  }

  void toggleShowCurrent() {
    showCurrent = !showCurrent;
    update();
  }

  void toggleShowNew() {
    showNew = !showNew;
    update();
  }

  void toggleShowConfirm() {
    showConfirm = !showConfirm;
    update();
  }

  void toggleShowForgotNew() {
    showForgotNew = !showForgotNew;
    update();
  }

  void toggleShowForgotConfirm() {
    showForgotConfirm = !showForgotConfirm;
    update();
  }

  int calcStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?:{}|<>_\-]').hasMatch(password)) score++;
    return score;
  }

  bool get hasMinLength => newPwdCtrl.text.length >= 8;
  bool get hasUppercase => RegExp(r'[A-Z]').hasMatch(newPwdCtrl.text);
  bool get hasLowercase => RegExp(r'[a-z]').hasMatch(newPwdCtrl.text);
  bool get hasNumber => RegExp(r'[0-9]').hasMatch(newPwdCtrl.text);

  void onNewPasswordChanged(String val) {
    passwordStrength = calcStrength(val);
    update();
  }

  void onForgotNewPasswordChanged(String val) {
    forgotNewStrength = calcStrength(val);
    update();
  }

  Future<void> changePassword() async {
    if (currentPwdCtrl.text.trim().isEmpty) {
      customSnackbar('warning'.tr, 'enter_current_password'.tr);
      return;
    }
    if (newPwdCtrl.text.length < 8) {
      customSnackbar('warning'.tr, 'password_min_length'.tr);
      return;
    }
    if (!hasUppercase || !hasLowercase || !hasNumber) {
      customSnackbar('warning'.tr, 'password_requirements_msg'.tr);
      return;
    }
    if (newPwdCtrl.text != confirmPwdCtrl.text) {
      customSnackbar('warning'.tr, 'password_not_match'.tr);
      return;
    }
    if (newPwdCtrl.text == currentPwdCtrl.text) {
      customSnackbar('warning'.tr, 'same_password_error'.tr);
      return;
    }
    statusRequest = StatusRequest.loading;
    update();
    await Future.delayed(const Duration(milliseconds: 800));
    statusRequest = StatusRequest.success;
    customSnackbar('success'.tr, 'password_changed_success'.tr, isError: false);
    currentPwdCtrl.clear();
    newPwdCtrl.clear();
    confirmPwdCtrl.clear();
    passwordStrength = 0;
    update();
  }

  Future<void> sendForgotOTP() async {
    forgotStatus = StatusRequest.loading;
    update();
    await Future.delayed(const Duration(milliseconds: 800));
    forgotStatus = StatusRequest.success;
    forgotStep = ForgotPwdStep.verifyOtp;
    otpValue = '';
    _startResendTimer();
    update();
  }

  void _startResendTimer() {
    resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendSeconds > 0) {
        resendSeconds--;
        update();
      } else {
        t.cancel();
      }
    });
  }

  Future<void> resendOTP() async {
    if (resendSeconds > 0) return;
    forgotStatus = StatusRequest.loading;
    update();
    await Future.delayed(const Duration(milliseconds: 600));
    forgotStatus = StatusRequest.success;
    otpValue = '';
    _startResendTimer();
    update();
  }

  void onOTPChanged(String val) {
    otpValue = val;
    update();
  }

  Future<void> verifyOTP() async {
    if (otpValue.length < 6) {
      customSnackbar('warning'.tr, 'enter_full_otp'.tr);
      return;
    }
    forgotStatus = StatusRequest.loading;
    update();
    await Future.delayed(const Duration(milliseconds: 700));
    forgotStatus = StatusRequest.success;
    forgotStep = ForgotPwdStep.newPassword;
    update();
  }

  Future<void> resetPasswordViaOTP() async {
    final p = forgotNewPwdCtrl.text;
    if (p.length < 8 ||
        !RegExp(r'[A-Z]').hasMatch(p) ||
        !RegExp(r'[a-z]').hasMatch(p) ||
        !RegExp(r'[0-9]').hasMatch(p)) {
      customSnackbar('warning'.tr, 'password_requirements_msg'.tr);
      return;
    }
    if (p != forgotConfirmPwdCtrl.text) {
      customSnackbar('warning'.tr, 'password_not_match'.tr);
      return;
    }
    forgotStatus = StatusRequest.loading;
    update();
    await Future.delayed(const Duration(milliseconds: 800));
    forgotStatus = StatusRequest.success;
    customSnackbar('success'.tr, 'password_changed_success'.tr, isError: false);
    Get.back();
    _resetForgot();
    update();
  }

  void goBackStep() {
    if (forgotStep == ForgotPwdStep.verifyOtp) {
      forgotStep = ForgotPwdStep.sendOtp;
      _resendTimer?.cancel();
      resendSeconds = 0;
    } else if (forgotStep == ForgotPwdStep.newPassword) {
      forgotStep = ForgotPwdStep.verifyOtp;
    }
    update();
  }

  void _resetForgot() {
    forgotStep = ForgotPwdStep.sendOtp;
    otpValue = '';
    resendSeconds = 0;
    _resendTimer?.cancel();
    forgotNewPwdCtrl.clear();
    forgotConfirmPwdCtrl.clear();
    showForgotNew = false;
    showForgotConfirm = false;
    forgotNewStrength = 0;
    forgotStatus = StatusRequest.none;
  }

  void onForgotSheetClosed() {
    _resetForgot();
    update();
  }

  @override
  void onClose() {
    currentPwdCtrl.dispose();
    newPwdCtrl.dispose();
    confirmPwdCtrl.dispose();
    forgotNewPwdCtrl.dispose();
    forgotConfirmPwdCtrl.dispose();
    _resendTimer?.cancel();
    super.onClose();
  }
}