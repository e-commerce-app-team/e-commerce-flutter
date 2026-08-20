import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/core/functions/show_image_picker.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/data/datasource/remote/buyer/buyer_profile_data.dart';
import 'package:e_commerce/data/model/buyer/buyer_profile_model.dart';

class BuyerProfileController extends GetxController {
  final MyServices services = Get.find<MyServices>();
  late final BuyerProfileData profileData;

  StatusRequest statusRequest = StatusRequest.none;
  BuyerProfileModel? profile;
  List<Map> followingStores = <Map>[];
  List<Map> myReviews = <Map>[];
  List<Map> addresses = <Map>[];
  Map wallet = <String, dynamic>{};
  List<Map> walletHistory = <Map>[];
  List<Map> depositRequests = <Map>[];
  Map<String, bool> notificationSettings = <String, bool>{};
  Map conversations = <String, dynamic>{};
  File? selectedPhoto;

  String get token => services.sharedPreferences.getString('token') ?? '';

  @override
  void onInit() {
    super.onInit();
    profileData = BuyerProfileData(Get.find<Crud>());
    loadProfile();
  }

  Future<void> loadProfile() async {
    statusRequest = StatusRequest.loading;
    update();
    final response = await profileData.getProfile(token);
    response.fold(
      (failure) => statusRequest = failure,
      (data) {
        if (data['data'] is Map) {
          profile = BuyerProfileModel.fromJson(
            Map<String, dynamic>.from(data),
          );
          statusRequest = StatusRequest.success;
        } else {
          statusRequest = StatusRequest.failure;
        }
      },
    );
    update();
  }

  Future<void> refreshProfile() => loadProfile();

  Future<void> pickPhoto() async {
    final source = await showImagePickerBottomSheet();
    if (source == null) return;
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 82);
    if (picked != null) {
      selectedPhoto = File(picked.path);
      update();
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    final response = await profileData.updateProfile(
      token,
      data: {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
      },
      profilePhoto: selectedPhoto,
    );
    response.fold(
      (_) => customSnackbar('error'.tr, 'server_error'.tr),
      (data) {
        if (data['data'] is Map) {
          profile = BuyerProfileModel.fromJson(
            Map<String, dynamic>.from(data),
          );
          selectedPhoto = null;
          customSnackbar('success'.tr, 'profile_updated_success'.tr, isError: false);
        } else {
          customSnackbar('error'.tr, (data['message'] ?? 'server_error').toString());
        }
      },
    );
    update();
  }

  Future<void> loadFollowingStores() async {
    statusRequest = StatusRequest.loading;
    update();
    final response = await profileData.getFollowingStores(token);
    response.fold(
      (failure) => statusRequest = failure,
      (data) {
        followingStores = ((data['data'] as List?) ?? const [])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        statusRequest = StatusRequest.success;
      },
    );
    update();
  }

  Future<void> unfollowStore(String storeId) async {
    final response = await profileData.unfollowStore(token, storeId);
    response.fold(
      (_) => customSnackbar('error'.tr, 'server_error'.tr),
      (_) {
        followingStores.removeWhere((store) => store['id'].toString() == storeId);
        customSnackbar('success'.tr, 'buyer_unfollow_success'.tr, isError: false);
      },
    );
    update();
  }

  Future<void> loadReviews() async {
    statusRequest = StatusRequest.loading;
    update();
    final response = await profileData.getMyReviews(token);
    response.fold(
      (failure) => statusRequest = failure,
      (data) {
        myReviews = ((data['data'] as List?) ?? const [])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        statusRequest = StatusRequest.success;
      },
    );
    update();
  }

  Future<void> loadAddresses() async {
    final response = await profileData.getAddresses(token);
    response.fold((_) {}, (data) {
      addresses = ((data['data'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    });
    update();
  }

  Future<void> saveAddress(Map<String, dynamic> data) async {
    final response = await profileData.addAddress(token, data);
    response.fold((_) => customSnackbar('error'.tr, 'server_error'.tr), (_) {
      customSnackbar('success'.tr, 'address_saved'.tr, isError: false);
      loadAddresses();
    });
  }

  Future<void> setDefaultAddress(String id) async {
    final response = await profileData.setDefaultAddress(token, id);
    response.fold((_) {}, (_) => loadAddresses());
  }

  Future<void> loadWallet() async {
    final balance = await profileData.getWalletBalance(token);
    balance.fold((_) {}, (data) => wallet = Map<String, dynamic>.from(data));
    final history = await profileData.getWalletHistory(token);
    history.fold((_) {}, (data) {
      walletHistory = ((data['data'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    });
    final requests = await profileData.getDepositRequests(token);
    requests.fold((_) {}, (data) {
      depositRequests = ((data['data'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    });
    update();
  }

  Future<void> requestWalletDeposit(double amount, String reference) async {
    final response = await profileData.requestDeposit(token, {
      'amount': amount,
      'payment_method': 'manual',
      'reference': reference.trim().isEmpty ? null : reference.trim(),
    });
    response.fold(
      (_) => customSnackbar('error'.tr, 'server_error'.tr),
      (_) {
        customSnackbar('success'.tr, 'wallet_deposit_pending'.tr, isError: false);
        loadWallet();
      },
    );
  }

  Future<void> loadNotificationSettings() async {
    final response = await profileData.getNotificationPreferences(token);
    response.fold((_) {}, (data) {
      final list = (data['data'] as List?) ?? const [];
      notificationSettings = {
        for (final item in list.whereType<Map>())
          item['type'].toString(): item['enabled'] == true,
      };
    });
    update();
  }

  Future<void> saveNotificationSettings() async {
    await profileData.updateNotificationPreferences(token, {
      'settings': notificationSettings.entries
          .map((entry) => {'type': entry.key, 'enabled': entry.value})
          .toList(),
    });
  }

  Future<void> loadConversations() async {
    final response = await profileData.getConversations(token);
    response.fold((_) {}, (data) => conversations = data['data'] is Map ? data['data'] : data);
    update();
  }

  bool canEditReview(Map review) {
    final raw = review['created_at']?.toString();
    final created = raw == null ? null : DateTime.tryParse(raw);
    return created != null && DateTime.now().difference(created).inHours < 24;
  }

  Future<void> updateReview(String id, int rating, String comment) async {
    final response = await profileData.updateReview(
      token,
      id,
      {'rating': rating, 'comment': comment},
    );
    response.fold(
      (_) => customSnackbar('error'.tr, 'server_error'.tr),
      (_) {
        customSnackbar('success'.tr, 'buyer_review_updated'.tr, isError: false);
        loadReviews();
      },
    );
  }

  Future<void> logout() async {
    await services.clearSession();
    Get.offAllNamed(AppRoute.login);
  }
}
