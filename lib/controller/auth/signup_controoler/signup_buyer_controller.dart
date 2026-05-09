import 'dart:io';
import 'package:e_commerce/core/functions/handling_data_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/class/status_request.dart';


import '../../../core/constant/routes.dart';
import '../../../core/functions/custom_snackbar.dart';
import '../../../data/datasource/remote/auth/signup_buyer_data.dart';

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

  @override
  void signUp() async{
    if (formstate.currentState!.validate()) {
      statusRequest = StatusRequest.loading;
      update();
      Map<String, String> textData = {
        "first_name": firstName.text,
        "last_name": lastName.text,
        "email": email.text,
        "phone": phone.text,
        "password": password.text,
        "password_confirmation": confirmPassword.text,
      };
      Map<String, File> filesData = {};
      if (profileImage != null) {
        filesData['profile_photo'] = profileImage!;
      }
      var response = await signUpBuyerData.postData(textData,filesData);
      print("============= RESPONSE FROM SERVER: $response =============");
      statusRequest=handlingData(response);
      if (StatusRequest.success == statusRequest){
        if(response["success"]==true){
          customSnackbar("تنبيه",response["message"]);
          Get.offAllNamed(AppRoute.login);
        }else{
          customSnackbar("تنبيه", response["message"]);
          statusRequest = StatusRequest.failure;
        }
      }
      update();

    }
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