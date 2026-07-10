import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/data/datasource/remote/auth/forgetpassword_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

abstract class VerifyCodeController extends GetxController {
  checkCode(String verifyCode);
}

class VerifyCodeControllerImp extends VerifyCodeController {
  String? email;
  StatusRequest statusRequest = StatusRequest.none;
  ForgetPasswordData forgetPasswordData = ForgetPasswordData(Get.find());

  @override
  checkCode(String verifyCode) async {
    statusRequest = StatusRequest.loading;
    update();
    var response = await forgetPasswordData.verifyOtp(email!, verifyCode);
    response.fold((l) {
      statusRequest = StatusRequest.none;
      update();
      customSnackbar("خطأ", "فشل الاتصال.", isError: true);
    }, (r) {
      if (r['success'] == true) {
        statusRequest = StatusRequest.success;
        update();
        Get.offNamed(AppRoute.resetPassword, arguments: {
          'email': email,
          'otp': verifyCode,
        });
      } else {
        statusRequest = StatusRequest.failure;
        update();
        customSnackbar("warning".tr, r['message'] ?? 'Invalid OTP', isError: true);
      }
    });
  }

  @override
  void onInit() {
    email = Get.arguments?['email'];
    super.onInit();
  }


}