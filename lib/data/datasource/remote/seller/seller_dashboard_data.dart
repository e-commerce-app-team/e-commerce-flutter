import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/link_api.dart';

/// Data source للـ dashboard
/// يستخدم GET /my-orders لجلب أحدث الطلبات (موجود فعلاً على الباك)
class SellerDashboardData {
  final Crud crud;
  SellerDashboardData(this.crud);

  Map<String, String> _auth(String token) => {'Authorization': 'Bearer $token'};

  /// جلب أحدث 5 طلبات للعرض في الداشبورد
  /// GET /my-orders?per_page=5
  Future<Either<StatusRequest, Map>> getRecentOrders(String token) async =>
      await crud.getData(
        '${AppLink.orders}?per_page=5',
        headers: _auth(token),
      );

  /// جلب إحصائيات الطلبات للـ badges
  /// GET /orders/badges (موجود على الباك)
  Future<Either<StatusRequest, Map>> getOrderBadges(String token) async =>
      await crud.getData(AppLink.ordersBadges, headers: _auth(token));
}
