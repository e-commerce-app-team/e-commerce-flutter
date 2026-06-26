import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/link_api.dart';

class SellerOrdersData {
  final Crud crud;
  SellerOrdersData(this.crud);

  Future<dynamic> getOrders({
    String? status,
    String? search,
    int page = 1,
    required String token,
  }) async =>
      await crud.getData(
        '${AppLink.sellerOrders}?page=$page'
            '${status != null ? "&status=$status" : ""}'
            '${(search != null && search.isNotEmpty) ? "&search=$search" : ""}',
        headers: {'Authorization': 'Bearer $token'},
      );

  Future<dynamic> acceptOrder({
    required String orderId,
    required int estimatedMinutes,
    required String token,
  }) async =>
      await crud.postData(
        '${AppLink.sellerOrders}/$orderId/accept',
        {'estimated_minutes': estimatedMinutes},
        headers: {'Authorization': 'Bearer $token'},
      );

  Future<dynamic> rejectOrder({
    required String orderId,
    required String reason,
    required String token,
  }) async =>
      await crud.postData(
        '${AppLink.sellerOrders}/$orderId/reject',
        {'reason': reason},
        headers: {'Authorization': 'Bearer $token'},
      );

  Future<dynamic> findOrCreateConversation({
    required int buyerId,
    required String orderId,
    required String token,
  }) async =>
      await crud.postData(
        AppLink.sellerConversations,
        {
          'buyer_id': buyerId,
          'order_id': orderId,
        },
        headers: {'Authorization': 'Bearer $token'},
      );
}