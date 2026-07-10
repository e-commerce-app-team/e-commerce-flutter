import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/data/datasource/remote/auth/forgetpassword_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

abstract class ForgetPasswordController extends GetxController {
  checkemail();
}

class ForgetPasswordControllerImp extends ForgetPasswordController {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  late TextEditingController email;
  StatusRequest statusRequest = StatusRequest.none;
  ForgetPasswordData forgetPasswordData = ForgetPasswordData(Get.find());

  @override
  checkemail() async {
    if (formstate.currentState!.validate()) {
      statusRequest = StatusRequest.loading;
      update();
      var response = await forgetPasswordData.sendOtp(email.text);
      response.fold((l) {
        statusRequest = StatusRequest.none;
        update();
        customSnackbar("خطأ", "فشل الاتصال. تأكد من إعدادات الخادم.", isError: true);
      }, (r) {
        if (r['success'] == true) {
          statusRequest = StatusRequest.success;
          update();
          Get.offNamed(AppRoute.verfiyCode, arguments: {'email': email.text});
        } else {
          statusRequest = StatusRequest.failure;
          update();
          customSnackbar("warning".tr, r['message'] ?? 'Error occurred', isError: true);
        }
      });
    }
  }

  @override
  void onInit() {
    email = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }
}