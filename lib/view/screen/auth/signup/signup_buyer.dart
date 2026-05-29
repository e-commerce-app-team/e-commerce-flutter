import 'dart:io';
import 'package:e_commerce/view/widget/auth/customtextbodyauth.dart';
import 'package:e_commerce/view/widget/auth/customtexttitleauth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/auth/signup_controoler/signup_buyer_controller.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/functions/alert_exitapp.dart';
import 'package:e_commerce/core/functions/valid_input.dart';
import 'package:e_commerce/view/widget/auth/custombuttonauth.dart';
import 'package:e_commerce/view/widget/auth/customtextformauth.dart';
import 'package:e_commerce/view/widget/auth/textsignup.dart';

import '../../../../core/class/handling_dataview.dart';

class SignUpBuyer extends StatelessWidget {
  const SignUpBuyer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SignUpBuyerControllerImp controller = Get.put(SignUpBuyerControllerImp());
    final double screenHeight = Get.height;

    return Scaffold(
      backgroundColor: AppColor.secondBackground,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) return;
          await alertExitApp();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: screenHeight * 0.50,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColor.mainGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        InkWell(
                          onTap: () => Get.back(),
                          child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
                        ),
                        const SizedBox(height: 20),
                        CustomTextTitleAuth(text: "welcome_with_us".tr),
                        const SizedBox(height: 8),
                        Text(  "signup_buyer_body".tr,style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white))

                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: screenHeight * 0.28,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  color: AppColor.backgroundcolor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: GetBuilder<SignUpBuyerControllerImp>(
                  builder: (controllerView) => HandlingDataRequest(
                    statusRequest: controllerView.statusRequest,
                    widget:  Form(
                  key: controller.formstate,
                  child: ListView(
                    padding: const EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 20),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      GetBuilder<SignUpBuyerControllerImp>(
                        builder: (contr) => Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColor.secondBackground,
                                backgroundImage: contr.profileImage != null
                                    ? FileImage(contr.profileImage!)
                                    : null,
                                child: contr.profileImage == null
                                    ? const Icon(Icons.person, size: 50, color: AppColor.grey)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () => contr.pickImage(),
                                  child: const CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppColor.primaryColor,
                                    child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CustomTextFormAuth(
                              isNumber: false,
                              valid: (val) => validInput(val!, 2, 20, "name"),
                              mycontroller: controller.firstName,
                              hint_text: "first_name_hint".tr,
                              iconData: Icons.person_outline,
                              label_text: "first_name".tr,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: CustomTextFormAuth(
                              isNumber: false,
                              valid: (val) => validInput(val!, 2, 20, "name"),
                              mycontroller: controller.lastName,
                              hint_text: "last_name_hint".tr,
                              iconData: Icons.person_outline,
                              label_text: "last_name".tr,
                            ),
                          ),
                        ],
                      ),

                      CustomTextFormAuth(
                        isNumber: false,
                        valid: (val) => validInput(val!, 5, 40, "email"),
                        mycontroller: controller.email,
                        hint_text: "email_hint".tr,
                        iconData: Icons.email_outlined,
                        label_text: "email".tr,
                      ),

                      CustomTextFormAuth(
                        isNumber: true,
                        valid: (val) => validInput(val!, 7, 15, "phone"),
                        mycontroller: controller.phone,
                        hint_text: "phone_hint".tr,
                        iconData: Icons.phone_android_outlined,
                        label_text: "phone".tr,
                      ),

                      CustomTextFormAuth(
                        isNumber: false,
                        obscureText: true,
                        valid: (val) => validInput(val!, 6, 30, "password"),
                        mycontroller: controller.password,
                        hint_text: "password_hint".tr,
                        iconData: Icons.lock_outline,
                        label_text: "password".tr,
                      ),

                      CustomTextFormAuth(
                        isNumber: false,
                        obscureText: true,
                        valid: (val) {
                          if (val != controller.password.text) {
                            return "password_not_match".tr;
                          }
                          return validInput(val!, 6, 30, "password");
                        },
                        mycontroller: controller.confirmPassword,
                        hint_text: "confirm_password_hint".tr,
                        iconData: Icons.lock_reset_outlined,
                        label_text: "confirm_password".tr,
                      ),

                      const SizedBox(height: 15),

                      CustomButtomAuth(
                        text: "create_buyer_account".tr,
                        onPressed: () {
                          controller.signUp();
                        },
                      ),
                      const SizedBox(height: 40),

                      CustomTextSignUpOrSignIn(
                        textone: "already_have_account".tr,
                        texttwo: "sign_in".tr,
                        onTap: () {
                          controller.goToSignIn();
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
                )
              )
            )

     ],
        )
          )
        );


  }
}