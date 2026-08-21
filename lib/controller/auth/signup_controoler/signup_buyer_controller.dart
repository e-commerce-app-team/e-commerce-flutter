import 'dart:io';
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
              "Ø§Ø®ØªØ± Ø·Ø±ÙŠÙ‚Ø© Ø§Ø³ØªÙ„Ø§Ù… Ø§Ù„Ø±Ù…Ø²",
              style: Theme.of(Get.context!).textTheme.displayLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.email, color: AppColor.primaryColor),
              title: const Text("Ø§Ù„Ø¨Ø±ÙŠØ¯ Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(email.text),
              onTap: () {
                Get.back();
                _sendOtpAndNavigate('email');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text("ÙˆØ§ØªØ³Ø§Ø¨ (WhatsApp)", style: TextStyle(fontWeight: FontWeight.bold)),
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

    // Ø¥Ø±Ø³Ø§Ù„ ÙƒÙˆØ¯ Ø§Ù„ØªØ­Ù‚Ù‚
    var response = await verifyCodeSignUpData.sendOtp(
        email.text, phone.text, firstName.text, method);

    response.fold((lift) async {
      statusRequest = StatusRequest.none;
      update();
      customSnackbar("Ø®Ø·Ø£", "ÙØ´Ù„ Ø§Ù„Ø§ØªØµØ§Ù„ Ø¨Ø§Ù„Ø®Ø§Ø¯Ù…. ØªØ£ÙƒØ¯ Ù…Ù† Ø¥Ø¹Ø¯Ø§Ø¯Ø§Øª Ø§Ù„Ø´Ø¨ÙƒØ©.", isError: true);
    }, (right) async {
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

        // ØªÙˆØ¬ÙŠÙ‡ Ù„ØµÙØ­Ø© Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ø¹ ØªÙ…Ø±ÙŠØ± Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª ÙˆØ§Ù†ØªØ¸Ø§Ø± Ø§Ù„Ù†ØªÙŠØ¬Ø©
        var result = await Get.toNamed(AppRoute.verfiyCodeSignUp, arguments: {
          "textData": textData,
          "profileImage": profileImage,
          "method": method,
        });

        // Ø¥Ø°Ø§ Ø¹Ø§Ø¯ true â€” ØªÙ… Ø§Ù„ØªØ­Ù‚Ù‚ Ø¨Ù†Ø¬Ø§Ø­ØŒ Ù†ÙƒÙ…Ù„ Ø¹Ù…Ù„ÙŠØ© Ø¥Ù†Ø´Ø§Ø¡ Ø§Ù„Ø­Ø³Ø§Ø¨ Ù‡Ù†Ø§
        if (result == true) {
          // Ø¬Ù…Ø¹ Ø§Ù„Ù…Ù„ÙØ§Øª
          Map<String, File> filesData = {};
          if (profileImage != null) filesData['profile_photo'] = profileImage!;

          var registerResponse = await signUpBuyerData.postData(textData, filesData);
          registerResponse.fold((lRegister) {
            statusRequest = StatusRequest.none;
            update();
            String errorMsg = "ÙØ´Ù„ Ø§Ù„Ø§ØªØµØ§Ù„ Ø£Ø«Ù†Ø§Ø¡ Ø¥Ù†Ø´Ø§Ø¡ Ø§Ù„Ø­Ø³Ø§Ø¨";
            if (lRegister.toString().contains("offline")) {
              errorMsg = "Ù„Ø§ ÙŠÙˆØ¬Ø¯ Ø§ØªØµØ§Ù„ Ø¨Ø§Ù„Ø¥Ù†ØªØ±Ù†Øª. ØªØ£ÙƒØ¯ Ù…Ù† Ø§Ù„Ø´Ø¨ÙƒØ© ÙˆØ­Ø§ÙˆÙ„ Ù…Ø±Ø© Ø£Ø®Ø±Ù‰.";
            } else if (lRegister.toString().contains("timeout")) {
              errorMsg = "Ø§Ù†Ù‚Ø·Ø¹ Ø§Ù„Ø§ØªØµØ§Ù„ Ø¨Ø§Ù„Ø®Ø§Ø¯Ù…. Ø­Ø§ÙˆÙ„ Ù…Ø±Ø© Ø£Ø®Ø±Ù‰.";
            }
            customSnackbar("Ø®Ø·Ø£", errorMsg, isError: true);
          }, (rRegister) {
            if (rRegister["success"] == true) {
              statusRequest = StatusRequest.success;
              update();
              Get.offAllNamed(AppRoute.successSignUp);
            } else {
              statusRequest = StatusRequest.none;
              update();
              String errorMessage = rRegister['message'] ?? 'Error occurred';
              if (rRegister['errors'] != null) {
                errorMessage = (rRegister['errors'] as Map).values.first[0];
              }
              customSnackbar("warning".tr, errorMessage, isError: true);
            }
          });
        }
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
