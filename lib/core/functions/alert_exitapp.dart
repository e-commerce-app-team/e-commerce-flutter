import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';

Future<bool> alertExitApp() async {
  bool? shouldExit = await Get.defaultDialog<bool>(
    title: "warning".tr,
    titleStyle: const TextStyle(
      color: AppColor.primaryColor,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    middleText: "exitConfirm".tr,
    middleTextStyle: const TextStyle(fontSize: 16),
    radius: 15,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),

    actions: [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          elevation: 0,
        ),
        onPressed: () {
          Get.back(result: false);
        },
        child: Text(
            "cancel".tr,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ),

      const SizedBox(width: 10),

      OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColor.primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        onPressed: () {
          Get.back(result: true);
        },
        child: Text(
            "confirm".tr,
            style: const TextStyle(color: AppColor.primaryColor, fontWeight: FontWeight.bold)
        ),
      ),
    ],
  );

  if (shouldExit == true) {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  return Future.value(shouldExit ?? false);
}