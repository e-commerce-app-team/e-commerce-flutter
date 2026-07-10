import 'dart:async';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:get/get.dart';
import '../../../data/datasource/remote/auth/verifycode_signup_data.dart';

class VerifyCodeSellerSignUpControllerImp extends GetxController {
  late String email;
  late String phone;
  late String firstName;
  late String method;

  VerifyCodeSignUpData verifyCodeSignUpData = VerifyCodeSignUpData(Get.find());
  StatusRequest statusRequest = StatusRequest.none;

  Timer? _timer;
  int countdown = 60;
  bool canResend = false;

  void startTimer() {
    countdown = 60;
    canResend = false;
    update();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        countdown--;
        update();
      } else {
        canResend = true;
        _timer?.cancel();
        update();
      }
    });
  }

  resendOtp() async {
    if (!canResend) return;
    statusRequest = StatusRequest.loading;
    update();
    
    var response = await verifyCodeSignUpData.sendOtp(email, phone, firstName, method);
    response.fold((l) {
      statusRequest = StatusRequest.none;
      update();
      customSnackbar("خطأ", "فشل الاتصال بخادم إرسال الرمز", isError: true);
    }, (r) {
      statusRequest = StatusRequest.none;
      if (r["success"] == true) {
        startTimer();
        customSnackbar("نجاح", "تمت إعادة إرسال الرمز بنجاح", isError: false);
      } else {
        update();
        customSnackbar("خطأ", r['message'] ?? 'فشل إعادة الإرسال', isError: true);
      }
    });
  }

  checkCode(String verificationCode) async {
    statusRequest = StatusRequest.loading;
    update();

    try {
      var response = await verifyCodeSignUpData.verifyOtp(email, verificationCode);
      
      response.fold((l) {
        statusRequest = StatusRequest.none;
        update();
        customSnackbar("خطأ", "فشل الاتصال.", isError: true);
      }, (r) {
        if (r["success"] == true) {
          statusRequest = StatusRequest.success;
          update();
          Get.back(result: true); // Return to stepper
        } else {
          statusRequest = StatusRequest.none;
          update();
          customSnackbar("خطأ", r['message'] ?? 'Invalid Verification Code', isError: true);
        }
      });
    } catch (e) {
      statusRequest = StatusRequest.none;
      update();
      customSnackbar("خطأ", "حدث خطأ غير متوقع", isError: true);
    }
  }

  @override
  void onInit() {
    email = Get.arguments['email'];
    phone = Get.arguments['phone'];
    firstName = Get.arguments['first_name'];
    method = Get.arguments['method'] ?? 'email';
    startTimer();
    super.onInit();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
