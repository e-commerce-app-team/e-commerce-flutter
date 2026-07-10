import 'dart:io';
import 'package:e_commerce/core/functions/handling_data_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/color.dart';


import '../../../core/constant/routes.dart';
import '../../../core/functions/custom_snackbar.dart';
import '../../../data/datasource/remote/auth/signup_buyer_data.dart';
import '../../../data/datasource/remote/auth/verifycode_signup_data.dart';

abstract class SignUpBuyerController extends GetxController {
  void signUp();
  void goToSignIn();
  Future<void> pickImage();
}

class SignUpBuyerControllerImp extends SignUpBuyerController {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  late TextEditingController firstName;
  late TextEditingController lastName;
  late TextEditingController email;
  late TextEditingController phone;
  late TextEditingController password;
  late TextEditingController confirmPassword;

  File? profileImage;
  final ImagePicker _picker = ImagePicker();

  StatusRequest statusRequest = StatusRequest.none;
  SignUpBuyerData signUpBuyerData = SignUpBuyerData(Get.find());

  @override
  void onInit() {
    firstName = TextEditingController();
    lastName = TextEditingController();
    email = TextEditingController();
    phone = TextEditingController();
    password = TextEditingController();
    confirmPassword = TextEditingController();
    super.onInit();
  }

  @override
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImage = File(image.path);
      update();
    }
  }

  VerifyCodeSignUpData verifyCodeSignUpData = VerifyCodeSignUpData(Get.find());

  @override
  void signUp() async {
    if (formstate.currentState!.validate()) {
      _showOtpMethodChoice();
    }
  }

  void _showOtpMethodChoice() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "اختر طريقة استلام الرمز",
              style: Theme.of(Get.context!).textTheme.displayLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.email, color: AppColor.primaryColor),
              title: const Text("البريد الإلكتروني", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(email.text),
              onTap: () {
                Get.back();
                _sendOtpAndNavigate('email');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text("واتساب (WhatsApp)", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(phone.text),
              onTap: () {
                Get.back();
                _sendOtpAndNavigate('phone'); // phone is handled as WhatsApp in backend
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendOtpAndNavigate(String method) async {
    statusRequest = StatusRequest.loading;
    update();

    // إرسال كود التحقق
    var response = await verifyCodeSignUpData.sendOtp(
        email.text, phone.text, firstName.text, method);

    response.fold((lift) {
      statusRequest = StatusRequest.none;
      update();
      customSnackbar("خطأ", "فشل الاتصال بالخادم. تأكد من إعدادات الشبكة.", isError: true);
    }, (right) {
      if (right["success"] == true) {
        statusRequest = StatusRequest.success;
        update();
        
        Map<String, String> textData = {
          "first_name": firstName.text,
          "last_name": lastName.text,
          "email": email.text,
          "phone": phone.text,
          "password": password.text,
          "password_confirmation": confirmPassword.text,
        };

        // توجيه لصفحة التحقق مع تمرير البيانات
        Get.toNamed(AppRoute.verfiyCodeSignUp, arguments: {
          "textData": textData,
          "profileImage": profileImage,
          "method": method,
        });
      } else {
        statusRequest = StatusRequest.none;
        update();
        String errorMessage = right['message'] ?? 'Error occurred';
        if (right['errors'] != null) {
          errorMessage = (right['errors'] as Map).values.first[0];
        }
        customSnackbar("warning".tr, errorMessage, isError: true);
      }
    });
  }

  @override
  void goToSignIn() {
     Get.offNamed(AppRoute.login);
  }

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }
}