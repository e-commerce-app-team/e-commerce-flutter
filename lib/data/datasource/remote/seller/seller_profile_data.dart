import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/link_api.dart';

class SellerProfileData {
  final Crud crud;
  SellerProfileData(this.crud);

  Map<String, String> _auth(String token) => {'Authorization': 'Bearer $token'};

  /// GET /seller/store-settings
  Future<Either<StatusRequest, Map>> getProfile(String token) async =>
      await crud.getData(AppLink.sellerProfile, headers: _auth(token));

  /// POST /seller/store-settings/update
  Future<Either<StatusRequest, Map>> updateProfile(
    String token, {
    required Map<String, String> data,
    File? logo,
    File? cover,
  }) async {
    final files = <String, File>{};
    if (logo  != null) files['store_logo']         = logo;
    if (cover != null) files['store_cover_photo']  = cover;

    if (files.isEmpty) {
      // بدون ملفات نستخدم postData عادياً
      return await crud.postData(
        AppLink.sellerProfileUpdate,
        data,
        headers: _auth(token),
      );
    }

    return await crud.postDataWithFiles(
      AppLink.sellerProfileUpdate,
      data,
      files,
      headers: _auth(token),
    );
  }

  /// Shipping settings - TODO: الباك لم ينفّذ هذا الـ endpoint بعد
  Future<Either<StatusRequest, Map>> updateShippingSettings(
    String token,
    Map<String, String> data,
  ) async =>
      await crud.postData(
        AppLink.sellerShippingSettings,
        data,
        headers: _auth(token),
      );
}
