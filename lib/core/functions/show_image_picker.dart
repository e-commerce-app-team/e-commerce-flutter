import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

Future<ImageSource?> showImagePickerBottomSheet() async {
  return await Get.bottomSheet<ImageSource>(
    Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 15),
          const Text("اختر مصدر الصورة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt_outlined, color: Colors.blue),
            ),
            title: const Text("التقاط بالكاميرا", style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Get.back(result: ImageSource.camera);
            },
          ),

          const SizedBox(height: 10),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.photo_library_outlined, color: Colors.purple),
            ),
            title: const Text("اختيار من الاستديو", style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Get.back( result: ImageSource.gallery);
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
    isScrollControlled: true,
    enterBottomSheetDuration: const Duration(milliseconds: 300),
    exitBottomSheetDuration: const Duration(milliseconds: 300),
  );
}