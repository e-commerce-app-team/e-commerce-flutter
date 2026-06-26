import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/data/model/seller/ads_models.dart';
import 'package:e_commerce/data/model/seller/inventory_models.dart';

class SellerAdsController extends GetxController {
  StatusRequest statusRequest = StatusRequest.none;
  StatusRequest submitStatus = StatusRequest.none;

  List<AdModel> ads = [];
  List<ProductModel> products = [];
  int walletBalance = 342000;

  String selectedTab = 'all';
  List<AdModel> get filteredAds {
    if (selectedTab == 'all') return ads;
    if (selectedTab == 'active') {
      return ads.where((a) => a.status == AdStatus.active).toList();
    }
    if (selectedTab == 'pending') {
      return ads.where((a) => a.status == AdStatus.pending).toList();
    }
    if (selectedTab == 'expired') {
      return ads
          .where((a) =>
              a.status == AdStatus.expired || a.status == AdStatus.rejected)
          .toList();
    }
    return ads;
  }

  void changeTab(String tab) {
    selectedTab = tab;
    update();
  }

  int get activeCount => ads.where((a) => a.status == AdStatus.active).length;
  int get pendingCount =>
      ads.where((a) => a.status == AdStatus.pending).length;

  int currentStep = 0;

  String selectedAdType = 'banner';
  String selectedDuration = '3';
  int? selectedProductId;
  String? selectedProductName;

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  int get computedPrice {
    final type = AdTypeModel.all().firstWhere((t) => t.id == selectedAdType,
        orElse: () => AdTypeModel.all().first);
    return type.pricing[selectedDuration] ?? 0;
  }

  bool get canAfford => walletBalance >= computedPrice;

  AdTypeModel get currentAdType => AdTypeModel.all()
      .firstWhere((t) => t.id == selectedAdType);


  Future<void> loadAds() async {
    statusRequest = StatusRequest.loading;
    update();
    await Future.delayed(const Duration(milliseconds: 700));
    ads = AdModel.mockList();
    products = ProductModel.mockList();
    statusRequest = StatusRequest.success;
    update();
  }

  void selectAdType(String type) {
    selectedAdType = type;
    if (type != 'product') {
      selectedProductId = null;
      selectedProductName = null;
    }
    update();
  }

  void selectDuration(String dur) {
    selectedDuration = dur;
    update();
  }

  void selectProduct(ProductModel p) {
    selectedProductId = p.id;
    selectedProductName = p.name;
    titleCtrl.text = p.name;
    update();
  }

  void nextStep() {
    if (currentStep == 0) {
      currentStep = 1;
      update();
      return;
    }
    if (currentStep == 1) {
      // validate step 2
      if (titleCtrl.text.trim().isEmpty) {
        customSnackbar('تنبيه', 'الرجاء إدخال عنوان الإعلان');
        return;
      }
      if (selectedAdType == 'product' && selectedProductId == null) {
        customSnackbar('تنبيه', 'الرجاء اختيار المنتج المُعلَن عنه');
        return;
      }
      currentStep = 2;
      update();
      return;
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      currentStep--;
      update();
    }
  }

  void resetForm() {
    currentStep = 0;
    selectedAdType = 'banner';
    selectedDuration = '3';
    selectedProductId = null;
    selectedProductName = null;
    titleCtrl.clear();
    descCtrl.clear();
    update();
  }

  Future<void> submitAd() async {
    if (!canAfford) {
      customSnackbar('رصيد غير كافٍ',
          'رصيد محفظتك لا يكفي لهذا الإعلان — يرجى إضافة رصيد');
      return;
    }
    submitStatus = StatusRequest.loading;
    update();
    await Future.delayed(const Duration(milliseconds: 900));
    // await adsData.createAd(...)
    walletBalance -= computedPrice;
    ads.insert(
      0,
      AdModel(
        id: DateTime.now().millisecondsSinceEpoch,
        adType: selectedAdType,
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
        linkedProductId: selectedProductId,
        linkedProductName: selectedProductName,
        durationDays: int.parse(selectedDuration),
        totalCost: computedPrice,
        status: AdStatus.pending,
        startDate: '',
        endDate: '',
        createdAt: 'الآن',
        impressions: 0,
        clicks: 0,
      ),
    );
    submitStatus = StatusRequest.success;
    customSnackbar('تم إرسال الإعلان',
        'إعلانك قيد المراجعة، سيُفعَّل خلال ساعات قليلة',
        isError: false);
    resetForm();
    Get.back();
    update();
  }

  @override
  void onInit() {
    super.onInit();
    loadAds();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }
}
