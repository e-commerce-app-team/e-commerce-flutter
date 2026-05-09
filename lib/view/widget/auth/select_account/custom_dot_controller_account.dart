import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/auth/select_account_type_controller.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/datasource/static/account_type_data.dart';

class CustomDotControllerAccount extends GetView<SelectAccountTypeController> {
  const CustomDotControllerAccount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SelectAccountTypeController>(
      builder: (controller) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          AccountTypeData.data.length,
              (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(right: 5),
            height: 8,
            width: controller.currentPage == index ? 20 : 8,
            decoration: BoxDecoration(
              color: controller.currentPage == index
                  ? AppColor.primaryColor
                  : AppColor.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}