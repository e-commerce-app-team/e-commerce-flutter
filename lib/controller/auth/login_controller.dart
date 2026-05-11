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
      print("============= RESPONSE FROM SERVER: $response =============");

      statusRequest = handlingData(response);

      if (StatusRequest.success == statusRequest) {
        if (response["success"] == true) {

          myServices.sharedPreferences.setString("id", response['user']['id'].toString());
          myServices.sharedPreferences.setString("role", response['user']['role']);
          myServices.sharedPreferences.setString("token", response['access_token']);
          myServices.sharedPreferences.setString("email", response['user']['email']);
         // myServices.sharedPreferences.setString("name", response['user']['name']);

         // myServices.sharedPreferences.setString("step", "2");

          String role = response['user']['role'];
          if (role == 'buyer') {
            Get.offAllNamed(AppRoute.successSignUp);
          } else  {

            Get.offAllNamed(AppRoute.successSignUp);
          }

        } else {
          customSnackbar("تنبيه","${response['message']}");
          statusRequest = StatusRequest.failure;
        }
      }
      update();
    }
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

