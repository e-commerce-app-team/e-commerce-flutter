import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../core/class/status_request.dart';
import '../../core/functions/custom_snackbar.dart';
import '../../core/functions/handling_data_controller.dart';
import '../../core/services/services.dart';
import '../../data/datasource/remote/auth/login_data.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

abstract class LoginController extends GetxController {
  login();
  goToSignUp();
  goToForgetPassword();
}

class LoginControllerImp extends LoginController {

  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  late TextEditingController email;

  late TextEditingController password;

  StatusRequest statusRequest = StatusRequest.none;

  LoginData loginData = LoginData(Get.find());
  MyServices myServices = Get.find();
  bool isshowpassword = true;
  showPassword() {
    isshowpassword = isshowpassword == true ? false : true;
    update();
  }

  @override
  login() async {
    if (formstate.currentState!.validate()) {
      statusRequest = StatusRequest.loading;
      update();

      var response = await loginData.postData(email.text, password.text);
      response.fold((left){
      statusRequest=left;
      update();}, (right){
        if(right["success"]==true) {
          myServices.sharedPreferences.setString("id", right['user']['id'].toString());
          myServices.sharedPreferences.setString("role", right['user']['role']);
          myServices.sharedPreferences.setString("token", right['access_token']);
          myServices.sharedPreferences.setString("email", right['user']['email']);

          String role = right['user']['role'];
          if (role == "buyer") {
            myServices.sharedPreferences.setString("onboarding", "1");
            Get.offAllNamed(AppRoute.successSignUp);
          } else if (role == "vendor"||role == "wholesale") {
            myServices.sharedPreferences.setString("onboarding", "1");
            Get.offAllNamed(AppRoute.sellerMain);
          } else {
            customSnackbar("تنبيه".tr, "${right['message']}");
            statusRequest = StatusRequest.failure;
            update();
          }
        }else {
          statusRequest = StatusRequest.failure;
          customSnackbar("warning".tr, right['message'] ?? "login_failed".tr);
          update();
        }
      }
      );
    }

   // Get.offNamed(AppRoute.sellerMain);
  }
  @override
  goToSignUp() {
    Get.offNamed(AppRoute.selectAccountType);
  }

  @override
  void onInit() {

    email = TextEditingController();
    password = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  goToForgetPassword() {
    Get.toNamed(AppRoute.forgetPassword);
  }
}

