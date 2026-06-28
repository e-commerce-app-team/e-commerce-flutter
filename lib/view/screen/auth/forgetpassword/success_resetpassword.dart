import 'package:e_commerce/controller/auth/successresetpassword_controller.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/view/widget/auth/custombuttonauth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuccessResetPassword extends StatelessWidget {
  const SuccessResetPassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SuccessResetPasswordControllerImp controller =
    Get.put(SuccessResetPasswordControllerImp());
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColor.backgroundcolor,
        elevation: 0.0,
        title: Text('Success',
            style: Theme.of(context)
                .textTheme
                .displayLarge!
                .copyWith(color: AppColor.grey)),
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 150,
                color: AppColor.success,
              ),
            ),
            const SizedBox(height: 40),
            Text("37".tr,
                style: Theme.of(context)
                    .textTheme
                    .displayLarge!
                    .copyWith(fontSize: 32, fontWeight: FontWeight.bold, color: AppColor.primaryColor)),
            const SizedBox(height: 15),
            Text(
              "36".tr,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColor.greyText,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 3),
            SizedBox(
              width: double.infinity,
              child: CustomButtomAuth(
                  text: "31".tr,
                  onPressed: () {
                    controller.goToPageLogin();
                  }),
            ),
            const SizedBox(height: 30),
        ]),
      ),
    );
  }
}