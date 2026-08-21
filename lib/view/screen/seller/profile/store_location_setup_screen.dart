import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_profile_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/view/screen/seller/branches/branch_location_picker_screen.dart';

class StoreLocationSetupScreen extends StatefulWidget {
  const StoreLocationSetupScreen({super.key});

  @override
  State<StoreLocationSetupScreen> createState() =>
      _StoreLocationSetupScreenState();
}

class _StoreLocationSetupScreenState extends State<StoreLocationSetupScreen> {
  final addressCtrl = TextEditingController();
  double? latitude;
  double? longitude;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final profile = Get.find<SellerProfileController>().profile;
    latitude = profile?.latitude;
    longitude = profile?.longitude;
    addressCtrl.text = profile?.detailedAddress ?? '';
  }

  @override
  void dispose() {
    addressCtrl.dispose();
    super.dispose();
  }

  Future<void> pickLocation() async {
    final result = await Get.to(
      () => BranchLocationPickerScreen(
        initialLat: latitude,
        initialLng: longitude,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        latitude = result.latitude;
        longitude = result.longitude;
      });
    }
  }

  Future<void> save() async {
    if (latitude == null ||
        longitude == null ||
        addressCtrl.text.trim().isEmpty) {
      Get.snackbar('تنبيه', 'حدد الموقع واكتب العنوان التفصيلي');
      return;
    }
    setState(() => saving = true);
    final ok = await Get.find<SellerProfileController>().saveMainStoreLocation(
      latitude: latitude!,
      longitude: longitude!,
      address: addressCtrl.text,
    );
    if (mounted) setState(() => saving = false);
    if (ok && mounted) Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColor.backgroundScaffold,
    appBar: AppBar(
      title: Text('موقع المتجر الرئيسي', style: AppTextStyle.appBarTitle),
      centerTitle: true,
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColor.primarySurface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'يستخدم هذا الموقع للاستلام الشخصي وحساب قرب المتجر. لا يتم استخدام موقع المستودعات بديلًا عنه.',
            style: AppTextStyle.bodyMedium,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 54,
          child: OutlinedButton.icon(
            onPressed: pickLocation,
            icon: const Icon(Icons.map_outlined),
            label: Text(
              latitude == null
                  ? 'تحديد الموقع على الخريطة'
                  : 'تعديل موقع المتجر',
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (latitude != null && longitude != null)
          Text(
            'الموقع المحدد: ${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}',
            style: AppTextStyle.labelSmall,
          ),
        const SizedBox(height: 14),
        TextField(
          controller: addressCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'العنوان التفصيلي',
            hintText: 'المدينة، الحي، الشارع، رقم البناء',
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: saving ? null : save,
            child: saving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('حفظ موقع المتجر'),
          ),
        ),
      ],
    ),
  );
}
