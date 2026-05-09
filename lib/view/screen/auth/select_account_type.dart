import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/auth/select_account_type_controller.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/view/widget/auth/select_account/custom_button_account.dart';
import 'package:e_commerce/view/widget/auth/select_account/custom_dot_controller_account.dart';
import 'package:e_commerce/view/widget/auth/select_account/custom_slider_account.dart';

class SelectAccountType extends StatelessWidget {
  const SelectAccountType({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(SelectAccountTypeController());

    return Scaffold(
      backgroundColor: AppColor.backgroundcolor,

      body: SafeArea(
        child: Column(
          children: const [
            Expanded(
              flex: 4,
              child: CustomSliderAccount(),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  CustomDotControllerAccount(),
                  Spacer(),
                  CustomButtonAccount(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}