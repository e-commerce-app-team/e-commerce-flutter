import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/link_api.dart';

class SellerOrdersData {
  final Crud crud;
  SellerOrdersData(this.crud);

  Map<String, String> _auth(String token) => {'Authorization': 'Bearer $token'};

  /// Fetches all seller orders with optional status filter and search
  Future<Either<StatusRequest, Map>> getOrders({
    String? status,
    String? search,
    int page = 1,
    required String token,
  }) async => await crud.getData(
    '${AppLink.orders}?page=$page'
    '${status != null ? "&status=$status" : ""}'
    '${(search != null && search.isNotEmpty) ? "&search=$search" : ""}',
    headers: _auth(token),
  );

  /// Get order badge counts per status
  Future<Either<StatusRequest, Map>> getBadges({required String token}) async =>
    await crud.getData(
      AppLink.ordersBadges,
      headers: _auth(token),
    );

  /// Get single order details
  Future<Either<StatusRequest, Map>> getOrderDetails({
    required int orderId,
    required String token,
  }) async => await crud.getData(
    '${AppLink.orders}/$orderId',
    headers: _auth(token),
  );

  /// Accept order
  Future<Either<StatusRequest, Map>> acceptOrder({
    required int orderId,
    required String token,
  }) async => await crud.postData(
    AppLink.ordersAccept,
    {'order_id': orderId},
    headers: _auth(token),
  );

  /// Reject order with reason
  Future<Either<StatusRequest, Map>> rejectOrder({
    required int orderId,
    required String reason,
    required String token,
  }) async => await crud.postData(
    AppLink.ordersReject,
    {'order_id': orderId, 'rejection_reason': reason},
    headers: _auth(token),
  );

  /// Update preparation time
  Future<Either<StatusRequest, Map>> updatePreparationTime({
    required int orderId,
    required String estimatedDate,
    String? delayMessage,
    required String token,
  }) async => await crud.postData(
    AppLink.ordersUpdateTime,
    {
      'order_id': orderId,
      'estimated_delivery_date': estimatedDate,
      if (delayMessage != null) 'delay_notice_message': delayMessage,
    },
    headers: _auth(token),
  );

  /// Mark order ready for shipping
  Future<Either<StatusRequest, Map>> readyForShipping({
    required int orderId,
    required String token,
  }) async => await crud.postData(
    AppLink.ordersReadyShipping,
    {'order_id': orderId},
    headers: _auth(token),
  );

  /// Find or create conversation with buyer
  Future<Either<StatusRequest, Map>> findOrCreateConversation({
    required int buyerId,
    required String orderId,
    required String token,
  }) async => await crud.postData(
    AppLink.sellerConversations,
    {'buyer_id': buyerId, 'order_id': orderId},
    headers: _auth(token),
  );
}