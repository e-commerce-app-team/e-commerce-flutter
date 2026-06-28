import 'package:e_commerce/controller/auth/verifycode_controller.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/view/widget/auth/customtextbodyauth.dart';
import 'package:e_commerce/view/widget/auth/customtexttitleauth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';

class VerfiyCode extends StatelessWidget {
  const VerfiyCode({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    VerifyCodeControllerImp controller =
    Get.put(VerifyCodeControllerImp());
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColor.backgroundcolor,
        elevation: 0.0,
        title: Text('Verification Code'.tr,
            style: Theme.of(context)
                .textTheme
                .displayLarge!
                .copyWith(color: AppColor.grey)),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        child: ListView(children: [
          const SizedBox(height: 20),
          const Icon(Icons.mark_email_read_outlined, size: 80, color: AppColor.primaryColor),
          const SizedBox(height: 20),
          CustomTextTitleAuth(text: "Check code".tr),
          const SizedBox(height: 10),
          CustomTextBodyAuth(
              text:
              "${"Please Enter The Digit Code Sent To".tr} \n ${controller.email ?? ''}"),
          const SizedBox(height: 30),
          OtpTextField(
            fieldWidth: 50.0,
            borderRadius: BorderRadius.circular(15),
            numberOfFields: 5,
            borderColor: AppColor.primaryColor,
            focusedBorderColor: AppColor.primaryColor,
            showFieldAsBox: true,
            onCodeChanged: (String code) {
            },
            onSubmit: (String verificationCode) {
              controller.goToResetPassword() ;
            },
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}