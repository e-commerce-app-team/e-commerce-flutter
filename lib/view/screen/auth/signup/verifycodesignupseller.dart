import 'package:e_commerce/controller/auth/signup_controoler/verifycodesignupseller_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/view/widget/auth/customtextbodyauth.dart';
import 'package:e_commerce/view/widget/auth/customtexttitleauth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';

class VerifyCodeSellerSignUp extends StatelessWidget {
  const VerifyCodeSellerSignUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(VerifyCodeSellerSignUpControllerImp());
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColor.backgroundcolor,
        elevation: 0.0,
        title: Text('enter_otp_title'.tr,
            style: Theme.of(context)
                .textTheme
                .displayLarge!
                .copyWith(color: AppColor.grey)),
      ),
      body: GetBuilder<VerifyCodeSellerSignUpControllerImp>(
        builder: (controller) => controller.statusRequest == StatusRequest.loading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                child: ListView(children: [
                  const SizedBox(height: 20),
                  const Icon(Icons.mark_email_read_outlined, size: 80, color: AppColor.primaryColor),
                  const SizedBox(height: 20),
                  CustomTextTitleAuth(text: "enter_otp_title".tr),
                  const SizedBox(height: 10),
                  CustomTextBodyAuth(
                      text: "${"otp_sent_to".tr} \n ${controller.email}"),
                  const SizedBox(height: 30),
                  FittedBox(
                    child: OtpTextField(
                      fieldWidth: 50.0,
                      borderRadius: BorderRadius.circular(15),
                      numberOfFields: 6,
                      borderColor: AppColor.primaryColor,
                      focusedBorderColor: AppColor.primaryColor,
                      showFieldAsBox: true,
                      onSubmit: (String verificationCode) {
                        controller.checkCode(verificationCode);
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "did_not_receive_otp".tr,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColor.grey),
                      ),
                      TextButton(
                        onPressed: controller.canResend ? () => controller.resendOtp() : null,
                        child: Text(
                          controller.canResend
                              ? "resend_otp_btn".tr
                              : "${"resend_in_label".tr} ${controller.countdown}s",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: controller.canResend ? AppColor.primaryColor : AppColor.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ]),
              ),
      ),
    );
  }
}