import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/core/functions/handling_data_controller.dart';
import 'package:e_commerce/data/model/seller/ads_models.dart';
import 'package:e_commerce/data/model/seller/inventory_models.dart';
import 'package:e_commerce/data/datasource/remote/seller/seller_ads_data.dart';
import 'package:e_commerce/core/services/services.dart';

class SellerAdsController extends GetxController {
  SellerAdsData adsData = SellerAdsData(Get.find());
  MyServices myServices = Get.find();
  String get token => myServices.sharedPreferences.getString('token') ?? "";

  StatusRequest statusRequest = StatusRequest.none;
  StatusRequest submitStatus = StatusRequest.none;

  List<AdModel> ads = [];
  List<ProductModel> products = [];
  int walletBalance = 0;
  List<AdTypeModel> adTypes = AdTypeModel.all();

  String selectedTab = 'all';
  List<AdModel> get filteredAds {
    // Backend API already handles filtering, but keeping local filtering for instant UI updates if needed
    return ads;
  }

  void changeTab(String tab) {
    selectedTab = tab;
    loadAds();
    update();
  }

  int get activeCount => ads.where((a) => a.status == AdStatus.active).length;
  int get pendingCount =>
      ads.where((a) => a.status == AdStatus.pending).length;

  int currentStep = 0;

  String selectedAdType = 'banner';
  String selectedDuration = '3_days';
  int? selectedProductId;
  String? selectedProductName;

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  int get computedPrice {
    final type = adTypes.firstWhere((t) => t.id == selectedAdType,
        orElse: () => adTypes.first);
    return type.pricing[selectedDuration] ?? 0;
  }

  bool get canAfford => walletBalance >= computedPrice;

  AdTypeModel get currentAdType => adTypes
      .firstWhere((t) => t.id == selectedAdType);

  File? adImage; // added for ad image

  Future<void> loadAdTypesAndBalance() async {
    var response = await adsData.getAdTypes(token);
    var status = handlingData(response);
    if (StatusRequest.success == status) {
      if (response['success'] == true) {
        walletBalance = (response['balance'] ?? 0).toInt();
        if (response['types'] != null) {
          adTypes = (response['types'] as List).map((t) => AdTypeModel.fromJson(t)).toList();
        }
        update();
      }
    }
  }

  Future<void> loadAds() async {
    statusRequest = StatusRequest.loading;
    update();

    String? statusFilter = selectedTab;
    if (selectedTab == 'all') statusFilter = null;

    var response = await adsData.getAds(token, statusFilter, null);
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['success'] == true) {
        List data = [];
        if (response['data'] is List) {
          data = response['data'];
        } else if (response['data'] != null && response['data']['data'] is List) {
          data = response['data']['data'];
        }
        ads = data.map((e) => AdModel.fromJson(e)).toList();
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
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
      if (titleCtrl.text.trim().isEmpty) {
        customSnackbar('ads_warn_title'.tr, 'ads_warn_enter_title'.tr);
        return;
      }
      if (selectedAdType == 'promoted_product' && selectedProductId == null) {
        customSnackbar('ads_warn_title'.tr, 'ads_warn_select_product'.tr);
        return;
      }
      if (selectedAdType == 'banner' && adImage == null) {
        customSnackbar('ads_warn_title'.tr, 'ads_warn_upload_image'.tr);
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
    selectedDuration = '3_days';
    selectedProductId = null;
    selectedProductName = null;
    adImage = null;
    titleCtrl.clear();
    descCtrl.clear();
    update();
  }

  Future<void> submitAd() async {
    if (!canAfford) {
      customSnackbar('ads_warn_no_balance'.tr, 'ads_warn_no_balance_msg'.tr);
      return;
    }
    submitStatus = StatusRequest.loading;
    update();

    // Build link based on type
    String? link;
    if (selectedAdType == 'promoted_product' && selectedProductId != null) {
      link = 'app://product/$selectedProductId';
    }

    Map<String, dynamic> data = {
      'type': selectedAdType,
      'title': titleCtrl.text.trim(),
      'description': descCtrl.text.trim(),
      'duration': selectedDuration,
      if (link != null) 'link': link,
    };

    var response = await adsData.createAd(token, data, adImage);
    submitStatus = handlingData(response);

    if (StatusRequest.success == submitStatus) {
      if (response['success'] == true) {
        walletBalance -= computedPrice;
        customSnackbar('ads_success_sent'.tr, 'ads_success_msg'.tr, isError: false);
        resetForm();
        Get.back();
        loadAds();
      } else {
        customSnackbar('error'.tr, response['message'] ?? 'ads_error_failed'.tr);
        submitStatus = StatusRequest.failure;
      }
    } else {
      customSnackbar('error'.tr, 'ads_error_connection'.tr);
    }
    update();
  }

  @override
  void onInit() {
    super.onInit();
    loadAdTypesAndBalance();
    loadAds();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }
}
