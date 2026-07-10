import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/link_api.dart';

class SellerCouponsData {
  Crud crud;
  SellerCouponsData(this.crud);

  Map<String, String> _auth(String token) => {'Authorization': 'Bearer $token'};

  getCoupons(String token, {int page = 1}) async {
    var response = await crud.getData("${AppLink.sellerCouponsIndex}?page=$page", headers: _auth(token));
    return response.fold((l) => l, (r) => r);
  }

  createCoupon(String token, Map data) async {
    var response = await crud.postData(AppLink.sellerCouponsStore, data as Map<String, dynamic>, headers: _auth(token));
    return response.fold((l) => l, (r) => r);
  }

  getCouponDetails(String token, String id) async {
    var response = await crud.getData("${AppLink.sellerCouponsShow}/$id/show", headers: _auth(token));
    return response.fold((l) => l, (r) => r);
  }

  updateCoupon(String token, String id, Map data) async {
    var response = await crud.putData("${AppLink.sellerCouponsUpdate}/$id/update", data as Map<String, dynamic>, headers: _auth(token));
    return response.fold((l) => l, (r) => r);
  }

  toggleCoupon(String token, String id) async {
    var response = await crud.patchData("${AppLink.sellerCouponsToggle}/$id/toggle", {}, headers: _auth(token));
    return response.fold((l) => l, (r) => r);
  }

  deleteCoupon(String token, String id) async {
    var response = await crud.deleteData("${AppLink.sellerCouponsDestroy}/$id/destroy", headers: _auth(token));
    return response.fold((l) => l, (r) => r);
  }

  getCouponStats(String token, String id) async {
    var response = await crud.getData("${AppLink.sellerCouponsStats}/$id/stats", headers: _auth(token));
    return response.fold((l) => l, (r) => r);
  }
}
