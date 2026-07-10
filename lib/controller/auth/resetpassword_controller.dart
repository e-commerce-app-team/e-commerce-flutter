import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/data/datasource/remote/auth/forgetpassword_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

abstract class ResetPasswordController extends GetxController {
  resetpassword();
}

class ResetPasswordControllerImp extends ResetPasswordController {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  late TextEditingController password;
  late TextEditingController repassword;

  String? email;
  String? otp;
  StatusRequest statusRequest = StatusRequest.none;
  ForgetPasswordData forgetPasswordData = ForgetPasswordData(Get.find());

  @override
  resetpassword() async {
    if (formstate.currentState!.validate()) {
      statusRequest = StatusRequest.loading;
      update();
      var response = await forgetPasswordData.resetPassword(email!, otp!, password.text);
      response.fold((l) {
        statusRequest = StatusRequest.none;
        update();
        customSnackbar("خطأ", "فشل الاتصال.", isError: true);
      }, (r) {
        if (r['success'] == true) {
          statusRequest = StatusRequest.success;
          update();
          Get.offNamed(AppRoute.successResetpassword);
        } else {
          statusRequest = StatusRequest.failure;
          update();
          customSnackbar("warning".tr, r['message'] ?? 'Error resetting password', isError: true);
        }
      });
    }
  }

  @override
  void onInit() {
    email = Get.arguments?['email'];
    otp = Get.arguments?['otp'];
    password = TextEditingController();
    repassword = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    password.dispose();
    repassword.dispose();
    super.dispose();
  }
}