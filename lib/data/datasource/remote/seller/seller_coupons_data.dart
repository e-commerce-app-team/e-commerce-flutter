import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/link_api.dart';

class SellerCouponsData {
  final Crud crud;
  SellerCouponsData(this.crud);

  Map<String, String> _auth(String token) => {'Authorization': 'Bearer $token'};

  Future<dynamic> getCoupons(String token, {int page = 1}) async {
    final response = await crud.getData(
      '${AppLink.sellerCouponsIndex}?page=$page',
      headers: _auth(token),
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> createCoupon(String token, Map data) async {
    final response = await crud.postData(
      AppLink.sellerCouponsStore,
      Map<String, dynamic>.from(data),
      headers: _auth(token),
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> getCouponDetails(String token, String id) async {
    final response = await crud.getData(
      '${AppLink.sellerCouponsShow}/$id/show',
      headers: _auth(token),
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> updateCoupon(String token, String id, Map data) async {
    final response = await crud.putData(
      '${AppLink.sellerCouponsUpdate}/$id/update',
      Map<String, dynamic>.from(data),
      headers: _auth(token),
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> toggleCoupon(String token, String id) async {
    final response = await crud.patchData(
      '${AppLink.sellerCouponsToggle}/$id/toggle',
      {},
      headers: _auth(token),
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> deleteCoupon(String token, String id) async {
    final response = await crud.deleteData(
      '${AppLink.sellerCouponsDestroy}/$id/destroy',
      headers: _auth(token),
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> getCouponStats(String token, String id) async {
    final response = await crud.getData(
      '${AppLink.sellerCouponsStats}/$id/stats',
      headers: _auth(token),
    );
    return response.fold((l) => l, (r) => r);
  }
}
