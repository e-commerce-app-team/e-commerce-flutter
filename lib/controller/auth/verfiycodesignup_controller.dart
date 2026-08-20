import 'dart:async';
import 'dart:io';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:get/get.dart';

import '../../../data/datasource/remote/auth/signup_buyer_data.dart';
import '../../../data/datasource/remote/auth/verifycode_signup_data.dart';

abstract class VerifyCodeSignUpController extends GetxController {
  checkCode(String verificationCode);
  goToSuccessSignUp();
  resendOtp();
}

class VerifyCodeSignUpControllerImp extends VerifyCodeSignUpController {
  late String email;
  late String phone;
  late String firstName;
  late String method;
  late Map<String, String> textData;
  File? profileImage;

  VerifyCodeSignUpData verifyCodeSignUpData = VerifyCodeSignUpData(Get.find());
  SignUpBuyerData signUpBuyerData = SignUpBuyerData(Get.find());

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

  @override
  resendOtp() async {
    if (!canResend) return;
    statusRequest = StatusRequest.loading;
    update();

    var response = await verifyCodeSignUpData.sendOtp(
        textData['email']!, textData['phone']!, firstName, method);
    response.fold((l) {
      statusRequest = StatusRequest.none;
      update();
      String errorMsg = "فشل الاتصال بخادم إرسال الرمز";
      if (l.toString().contains("offline")) {
        errorMsg = "لا يوجد اتصال بالإنترنت. تأكد من الشبكة وحاول مرة أخرى.";
      }
      customSnackbar("خطأ", errorMsg, isError: true);
    }, (r) {
      statusRequest = StatusRequest.none;
      if (r["success"] == true) {
        startTimer();
        customSnackbar("نجاح", "تمت إعادة إرسال الرمز بنجاح", isError: false);
      } else {
        update();
        String errorMsg = r['message'] ?? 'فشل إعادة الإرسال';
        if (r['errors'] != null) {
          final errorsList = r['errors'] as Map;
          errorMsg = errorsList.values
              .map((e) => e is List ? e.first : e)
              .join('\n');
        }
        customSnackbar("خطأ", errorMsg, isError: true);
      }
    });
  }

  @override
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
        // عند نجاح التحقق فقط نرجع للـ caller ولا نقوم بإنشاء الحساب هنا
        if (r["success"] == true) {
          statusRequest = StatusRequest.success;
          update();
          Get.back(result: true);
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

  // Removed immediate account creation here. The SignUpBuyer controller will handle post-OTP registration.


  @override
  goToSuccessSignUp() {
    Get.offAllNamed(AppRoute.successSignUp);
  }

  @override
  void onInit() {
    textData = Get.arguments['textData'];
    profileImage = Get.arguments['profileImage'];
    method = Get.arguments['method'] ?? 'email';
    email = method == 'email' ? textData['email']! : textData['phone']!;
    phone = textData['phone']!;
    firstName = textData['first_name']!;
    startTimer();
    super.onInit();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}