import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/link_api.dart';

class BuyerOrdersDataSource {
  final Crud _crud;

  BuyerOrdersDataSource(this._crud);

  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
  };

  Future<Either<StatusRequest, Map>> getOrders(
    String token, {
    String? status,
    int page = 1,
    int perPage = 20,
  }) {
    final params = <String, String>{
      'page': '$page',
      'per_page': '$perPage',
      if (status != null && status.isNotEmpty && status != 'all')
        'status': status,
    };
    final url = Uri.parse(
      AppLink.buyerOrders,
    ).replace(queryParameters: params).toString();
    print('=========== BUYER ORDERS URL: $url ===========');
    print(
      '=========== BUYER ORDERS TOKEN PRESENT: ${token.isNotEmpty} ===========',
    );
    return _crud.getData(url, headers: _headers(token));
  }

  Future<Either<StatusRequest, Map>> getOrderDetail(
    String token,
    String orderId,
  ) => _crud.getData(
    AppLink.buyerOrderDetail(orderId),
    headers: _headers(token),
  );

  Future<Either<StatusRequest, Map>> confirmDelivery(
    String token,
    String orderId, {
    String? subOrderId,
  }) => _crud.postData(AppLink.buyerConfirmDelivery(orderId), {
    if (subOrderId != null) 'sub_order_id': subOrderId,
  }, headers: _headers(token));

  Future<Either<StatusRequest, Map>> approveShipping(
    String token,
    String orderId, {
    String? subOrderId,
  }) => _crud.postData(AppLink.buyerApproveShipping(orderId), {
    if (subOrderId != null) 'sub_order_id': subOrderId,
  }, headers: _headers(token));

  Future<Either<StatusRequest, Map>> payOrder(String token, String orderId) =>
      _crud.postData(
        AppLink.buyerPayOrder(orderId),
        {},
        headers: _headers(token),
      );

  Future<Either<StatusRequest, Map>> rateStore(
    String token,
    String storeId, {
    required double rating,
    required String comment,
  }) => _crud.postData(AppLink.buyerRateStore(storeId), {
    'rating': rating,
    'comment': comment,
  }, headers: _headers(token));
}
