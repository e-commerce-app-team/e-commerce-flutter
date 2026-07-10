import 'package:e_commerce/controller/auth/resetpassword_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/functions/valid_input.dart';
import 'package:e_commerce/view/widget/auth/custombuttonauth.dart';
import 'package:e_commerce/view/widget/auth/customtextbodyauth.dart';
import 'package:e_commerce/view/widget/auth/customtextformauth.dart';
import 'package:e_commerce/view/widget/auth/customtexttitleauth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPassword extends StatelessWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(ResetPasswordControllerImp());
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColor.backgroundcolor,
        elevation: 0.0,
        title: Text('35'.tr, // Usually title is "Reset Password" or similar, "35" might be new password.
            style: Theme.of(context)
                .textTheme
                .displayLarge!
                .copyWith(color: AppColor.grey)),
      ),
      body: GetBuilder<ResetPasswordControllerImp>(
        builder: (controller) => controller.statusRequest == StatusRequest.loading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                child: Form(
                  key: controller.formstate,
                  child: ListView(children: [
                    const SizedBox(height: 20),
                    const Icon(Icons.password_outlined, size: 80, color: AppColor.primaryColor),
                    const SizedBox(height: 20),
                    CustomTextTitleAuth(text: "35".tr),
                    const SizedBox(height: 10),
                    CustomTextBodyAuth(text: "Please enter your new password".tr),
                    const SizedBox(height: 30),
                    CustomTextFormAuth(
                      isNumber: false ,
                      valid: (val) {
                        return validInput(val!, 3, 40, "password");
                      },
                      mycontroller: controller.password,
                      hint_text: "13".tr,
                      iconData: Icons.lock_outline,
                      label_text: "19".tr,
                    ),
                    CustomTextFormAuth(
                      isNumber: false ,
                      valid: (val) {
                        if (val != controller.password.text) {
                          return "Passwords do not match".tr;
                        }
                        return validInput(val!, 3, 40, "password");
                      },
                      mycontroller: controller.repassword,
                      hint_text: "Re" + " " + "13".tr,
                      iconData: Icons.lock_outline,
                      label_text: "19".tr,
                    ),
                    CustomButtomAuth(
                        text: "33".tr,
                        onPressed: () {
                          controller.resetpassword();
                        }),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
      ),
    );
  }
}