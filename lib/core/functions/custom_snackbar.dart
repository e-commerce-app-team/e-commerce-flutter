import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';

void customSnackbar(String title, String message, {bool isError = true}) {
  if (Get.isSnackbarOpen) {
    return;
  }
  Color bgColor = isError ? AppColor.snackbarErrorBg : AppColor.snackbarSuccessBg;
  Color textColor = isError ? AppColor.snackbarErrorText : AppColor.snackbarSuccessText;
  Color iconColor = isError ? Colors.redAccent : Colors.green;

  Get.snackbar(
    title,
    message,
    backgroundColor: bgColor.withOpacity(0.85),
    barBlur: 20,

    colorText: textColor,
    titleText: Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    ),
    messageText: Text(
      message,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor.withOpacity(0.8),
      ),
    ),

    icon: Icon(
      isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
      color: iconColor,
      size: 32,
    ),
    shouldIconPulse: true,

    snackPosition: SnackPosition.TOP,
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    borderRadius: 16,

    boxShadows: [
      BoxShadow(
        color: AppColor.black.withOpacity(0.4),
        blurRadius: 20,
        spreadRadius: 5,
        offset: const Offset(0, 8),
      )
    ],
  );
}