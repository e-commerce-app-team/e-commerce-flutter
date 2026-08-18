import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/link_api.dart';

class BuyerCartDataSource {
  final Crud _crud;

  BuyerCartDataSource(this._crud);

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
      };

  Future<Either<StatusRequest, Map>> getCart(String token) =>
      _crud.getData(AppLink.buyerCart, headers: _headers(token));

  Future<Either<StatusRequest, Map>> addToCart(
    String token, {
    required String productId,
    int qty = 1,
    String? variantId,
  }) =>
      _crud.postData(
        AppLink.buyerCartAdd,
        {
          'product_id': int.tryParse(productId) ?? productId,
          'qty': qty,
          if (variantId != null) 'variant_id': int.tryParse(variantId) ?? variantId,
        },
        headers: _headers(token),
      );

  Future<Either<StatusRequest, Map>> updateQty(
    String token,
    String itemId,
    int qty,
  ) =>
      _crud.putData(
        AppLink.buyerCartUpdate(itemId),
        {'qty': qty},
        headers: _headers(token),
      );

  Future<Either<StatusRequest, Map>> removeItem(String token, String itemId) =>
      _crud.deleteData(AppLink.buyerCartRemove(itemId), headers: _headers(token));

  Future<Either<StatusRequest, Map>> clearCart(String token) =>
      _crud.deleteData(AppLink.buyerCartClear, headers: _headers(token));

  Future<Either<StatusRequest, Map>> validateCoupon(
    String token, {
    required String code,
    required String sellerId,
    required double orderTotal,
    required List<String> productIds,
  }) =>
      _crud.postData(
        AppLink.buyerValidateCoupon,
        {
          'code': code,
          'seller_id': int.tryParse(sellerId) ?? sellerId,
          'order_total': orderTotal,
          'product_ids': productIds.map(int.tryParse).whereType<int>().toList(),
        },
        headers: _headers(token),
      );

  Future<Either<StatusRequest, Map>> checkout(
    String token,
    Map<String, dynamic> body,
  ) =>
      _crud.postData(AppLink.buyerCheckout, body, headers: _headers(token));

  Future<Either<StatusRequest, Map>> payOrder(
    String token,
    String orderId,
    String password,
  ) =>
      _crud.postData(
        AppLink.buyerPayOrder(orderId),
        {'password': password},
        headers: _headers(token),
      );

  Future<Either<StatusRequest, Map>> getWalletBalance(String token) =>
      _crud.getData(AppLink.buyerWalletBalance, headers: _headers(token));
}

class BuyerAddressDataSource {
  final Crud _crud;

  BuyerAddressDataSource(this._crud);

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
      };

  Future<Either<StatusRequest, Map>> getAddresses(String token) =>
      _crud.getData(AppLink.buyerAddresses, headers: _headers(token));

  Future<Either<StatusRequest, Map>> createAddress(
    String token,
    Map<String, dynamic> body,
  ) =>
      _crud.postData(AppLink.buyerAddresses, body, headers: _headers(token));

  Future<Either<StatusRequest, Map>> setDefault(String token, String id) =>
      _crud.patchData(
        AppLink.buyerAddressDefault(id),
        {},
        headers: _headers(token),
      );
}
