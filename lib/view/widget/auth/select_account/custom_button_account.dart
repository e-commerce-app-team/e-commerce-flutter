import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/auth/select_account_type_controller.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/datasource/static/account_type_data.dart';

class CustomButtonAccount extends GetView<SelectAccountTypeController> {
  const CustomButtonAccount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SelectAccountTypeController>(
      builder: (controller) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        width: double.infinity,
        child: MaterialButton(
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: AppColor.primaryColor,
          textColor: Colors.white,
          onPressed: () => controller.goToSignUp(),
          child: Text(
            AccountTypeData.data[controller.currentPage]['button']!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}