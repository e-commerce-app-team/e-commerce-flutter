import 'dart:io';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/link_api.dart';

class SellerAdsData {
  Crud crud;
  SellerAdsData(this.crud);

  Map<String, String> _auth(String token) => {'Authorization': 'Bearer $token'};

  getAdTypes(String token) async {
    var response = await crud.getData(AppLink.sellerAdTypes, headers: _auth(token));
    return response.fold((l) => l, (r) => r);
  }

  getAds(String token, String? status, String? type, {int page = 1}) async {
    String url = "${AppLink.sellerAdsIndex}?page=$page";
    if (status != null && status != 'all') url += "&status=$status";
    if (type != null && type != 'all') url += "&type=$type";
    var response = await crud.getData(url, headers: _auth(token));
    return response.fold((l) => l, (r) => r);
  }

  createAd(String token, Map data, File? image) async {
    if (image != null) {
      Map<String, String> stringData = data.map((key, value) => MapEntry(key.toString(), value.toString()));
      var response = await crud.postDataWithFiles(
          AppLink.sellerAdsStore, stringData, {'image': image}, headers: _auth(token));
      return response.fold((l) => l, (r) => r);
    } else {
      var response = await crud.postData(AppLink.sellerAdsStore, data as Map<String, dynamic>, headers: _auth(token));
      return response.fold((l) => l, (r) => r);
    }
  }

  getAdDetails(String token, String adId) async {
    var response = await crud.getData("${AppLink.sellerAdsShow}/$adId/showAd", headers: _auth(token));
    return response.fold((l) => l, (r) => r);
  }

  updateAd(String token, String adId, Map data, File? image) async {
    if (image != null) {
      data['_method'] = 'PUT';
      Map<String, String> stringData = data.map((key, value) => MapEntry(key.toString(), value.toString()));
      var response = await crud.postDataWithFiles(
          "${AppLink.sellerAdsUpdate}/$adId/updateAd", stringData, {'image': image}, headers: _auth(token));
      return response.fold((l) => l, (r) => r);
    } else {
      var response = await crud.putData(
          "${AppLink.sellerAdsUpdate}/$adId/updateAd", data as Map<String, dynamic>, headers: _auth(token));
      return response.fold((l) => l, (r) => r);
    }
  }

  deleteAd(String token, String adId) async {
    var response = await crud.deleteData("${AppLink.sellerAdsDestroy}/$adId/destroyAd", headers: _auth(token));
    return response.fold((l) => l, (r) => r);
  }

  getDashboardStats(String token) async {
    var response = await crud.getData(AppLink.sellerAdsDashboard, headers: _auth(token));
    return response.fold((l) => l, (r) => r);
  }
}
