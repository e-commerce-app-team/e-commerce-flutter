import 'dart:io';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_commerce/core/functions/show_image_picker.dart';

import '../../../core/constant/routes.dart';
import '../../../core/functions/custom_snackbar.dart';
import '../../../core/functions/handling_data_controller.dart';
import '../../../data/datasource/remote/auth/signup_seller_data.dart';

abstract class SignUpSellerController extends GetxController {
  void next();
  void back();
  void signUp();
  void changeAccountType(String type);
  void setCategory(int id);
  Future<void> pickDocument(String docType);
}

class SignUpSellerControllerImp extends SignUpSellerController {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  late PageController pageController;
  int currentPage = 0;

  late TextEditingController firstName;
  late TextEditingController lastName;
  late TextEditingController email;
  late TextEditingController phone;
  late TextEditingController password;
  late TextEditingController confirmPassword;

  late TextEditingController storeName;
  late TextEditingController crNumber;
  late TextEditingController vatNumber;

  int? selectedCategoryId;
  File? logoImage;
  File? idImage;
  File? crImage;

  String accountType = 'vendor';
  StatusRequest statusRequest = StatusRequest.none;
  SignupSellerData signupSellerData = SignupSellerData(Get.find());

  @override
  void onInit() {
    pageController = PageController();
    firstName = TextEditingController();
    lastName = TextEditingController();
    email = TextEditingController();
    phone = TextEditingController();
    password = TextEditingController();
    confirmPassword = TextEditingController();
    storeName = TextEditingController();
    crNumber = TextEditingController();
    vatNumber = TextEditingController();
    super.onInit();
  }

  @override
  void changeAccountType(String type) {
    accountType = type;
    if (type == 'vendor') {
      crNumber.clear();
      vatNumber.clear();
      crImage = null;
    }
    update();
  }

  @override
  void setCategory(int id) {
    selectedCategoryId = id;
    update();
  }

  @override
  Future<void> pickDocument(String docType) async {
    ImageSource? source = await showImagePickerBottomSheet();

    if (source != null) {
      final XFile? pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        if (docType == 'logo') {
          logoImage = File(pickedFile.path);
        } else if (docType == 'id') {
          idImage = File(pickedFile.path);
        } else if (docType == 'cr') {
          crImage = File(pickedFile.path);
        }
        update();
      }
    }
  }

  @override
  void next() {
    if (formstate.currentState!.validate()) {
      if (currentPage == 1 && selectedCategoryId == null) {
        customSnackbar("تنبيه", "ادخل تصنيف المتجر");
        return;
      }

      if (currentPage < 2) {
        currentPage++;
        pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        update();
      } else {
        signUp();
      }
    }
  }

  @override
  void back() {
    if (currentPage > 0) {
      currentPage--;
      pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      update();
    } else {
      Get.back();
    }
  }

  @override
  Future<void> signUp() async {
    if (formstate.currentState!.validate()) {
      if (logoImage == null || idImage == null) {
        customSnackbar("تنبيه".tr, "الرجاء رفع شعار المتجر وصورة الهوية ");
        return;
      }
      if (accountType == 'wholesale' && crImage == null) {
      customSnackbar("تنبيه","الرجاء رفع صورة السجل التجاري ");
        return;
      }
    statusRequest=StatusRequest.loading;
      update();
      Map<String, String> textData = {
        "first_name": firstName.text,
        "last_name": lastName.text,
        "email": email.text,
        "phone": phone.text,
        "password": password.text,
        "password_confirmation": confirmPassword.text,
        "role": accountType,
        "store_name": storeName.text,
        "category": selectedCategoryId.toString(),
      };
      if (accountType == 'wholesale') {
        textData["commercial_registration_number"] = crNumber.text;
        textData["tax_number"] = vatNumber.text;
      }
      Map<String,File> fileData={
        "store_logo": logoImage! ,
        "id_card_photo": idImage! ,
      };
      if (accountType == 'wholesale' ) {
        fileData["commercial_record_photo"] = crImage!;
      }
      var response = await signupSellerData.postData(textData, fileData);
      response.fold((lift){
        statusRequest=lift;
      }, (right){
        if(right["success"]==true){
          statusRequest=StatusRequest.success;
          customSnackbar("32".tr, right['message'], isError: false);
          Get.offAllNamed(AppRoute.login);
        }else{
          statusRequest=StatusRequest.failure;
          customSnackbar("warning".tr, right['message'], isError: true);
        }
      }
      );
      update();

    }
  }

  @override
  void dispose() {
    pageController.dispose();
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    confirmPassword.dispose();
    storeName.dispose();
    crNumber.dispose();
    vatNumber.dispose();
    super.dispose();
  }
}