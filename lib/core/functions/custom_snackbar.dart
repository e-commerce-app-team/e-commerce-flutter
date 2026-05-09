import 'package:flutter/material.dart';
import 'package:get/get.dart';

void customSnackbar(String title, String message, {bool isError = true}) {
  Get.snackbar(
    title,
    message,
    backgroundColor: isError ? Colors.redAccent : Colors.green,
    colorText: Colors.white,
    snackPosition: SnackPosition.TOP,
    duration: const Duration(seconds: 3),
    margin: const EdgeInsets.all(10),
    borderRadius: 10,
  );
}