import 'dart:io';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_commerce/core/functions/show_image_picker.dart';

import '../../../core/constant/color.dart';
import '../../../core/constant/routes.dart';
import '../../../core/functions/custom_snackbar.dart';
import '../../../core/functions/handling_data_controller.dart';
import '../../../data/datasource/remote/auth/signup_seller_data.dart';
import '../../../data/datasource/remote/auth/verifycode_signup_data.dart';
import 'package:e_commerce/data/model/seller/inventory_models.dart';

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

  List<CategoryModel> categories = [];

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
    loadCategories();
  }

  Future<void> loadCategories() async {
    statusRequest = StatusRequest.loading;
    update();

    var response = await signupSellerData.getCategories();
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      response.fold((l) {}, (data) {
        if (data['success'] == true) {
          List responseData = data['data'] ?? [];
          categories = responseData.map((e) => CategoryModel.fromJson(e)).toList();
        } else {
          statusRequest = StatusRequest.failure;
        }
      });
    }
    update();
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

  VerifyCodeSignUpData verifyCodeSignUpData = VerifyCodeSignUpData(Get.find());

  @override
  void next() async {
    if (formstate.currentState!.validate()) {
      if (currentPage == 0) {
        _showOtpMethodChoice();
        return; // Wait for OTP verification
      }

      if (currentPage == 1 && selectedCategoryId == null) {
        customSnackbar("تنبيه", "ادخل تصنيف المتجر");
        return;
      }

      if (currentPage < 2) {
        _goToNextPage();
      } else {
        signUp();
      }
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
              title: const Text("البريد الإلكتروني", style: TextStyle(fontWeight: FontWeight.bold)), onTap: () {
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
    var response = await verifyCodeSignUpData.sendOtp(
        email.text, phone.text, firstName.text, method);
    
    response.fold((lift) {
      statusRequest = StatusRequest.none;
      update();
      customSnackbar("خطأ", "فشل الاتصال بالخادم. حاول مجدداً.", isError: true);
    }, (right) {
      statusRequest = StatusRequest.none;
      update();
      if (right["success"] == true) {
        _navigateToOtpScreen(method);
      } else {
        String errorMessage = right['message'] ?? 'حدث خطأ غير متوقع';
        if (right['errors'] != null) {
          errorMessage = (right['errors'] as Map).values.first[0];
        }
        customSnackbar("warning".tr, errorMessage, isError: true);
      }
    });
  }

  void _goToNextPage() {
    currentPage++;
    pageController.animateToPage(
      currentPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    update();
  }

  void _navigateToOtpScreen(String method) async {
    var result = await Get.toNamed(AppRoute.verifyCodeSellerSignUp, arguments: {
      'email': method == 'email' ? email.text : phone.text,
      'phone': phone.text,
      'first_name': firstName.text,
      'method': method,
    });

    if (result == true) {
      _goToNextPage();
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