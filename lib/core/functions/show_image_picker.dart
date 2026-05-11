import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_commerce/core/constant/color.dart';

Future<ImageSource?> showImagePickerBottomSheet() async {
  return await Get.bottomSheet<ImageSource>(
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        color: AppColor.backgroundcolor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ================= مؤشر السحب (Drag Handle) =================
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: AppColor.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),

          // ================= العنوان =================
          Text(
            "chooseImageSource".tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.black,
            ),
          ),
          const SizedBox(height: 25),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_outlined, color: AppColor.primaryColor, size: 28),
            ),
            title: Text(
              "camera".tr,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            onTap: () {
              Get.back(result: ImageSource.camera);
            },
          ),

          const SizedBox(height: 10),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.photo_library_outlined, color: AppColor.primaryColor, size: 28),
            ),
            title: Text(
              "gallery".tr,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            onTap: () {
              Get.back(result: ImageSource.gallery);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),

    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enterBottomSheetDuration: const Duration(milliseconds: 350),
    exitBottomSheetDuration: const Duration(milliseconds: 250),
  );
}