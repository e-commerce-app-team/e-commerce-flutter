import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/link_api.dart';

/// Data source للـ wallet يستخدم endpoints الموجودة فعلاً على الباك:
///   GET  /balance              → رصيد البائع + locked/available
///   GET  /history             → سجل السحوبات (PayoutRequests)
///   POST /payouts/instant-withdraw → طلب سحب جديد
class SellerWalletRemoteData {
  final Crud crud;
  SellerWalletRemoteData(this.crud);

  Map<String, String> _auth(String token) => {'Authorization': 'Bearer $token'};

  /// GET /balance
  /// يُرجع: { total_balance, locked_balance, available_balance, payout_method, payout_account }
  Future<Either<StatusRequest, Map>> getBalance(String token) async =>
      await crud.getData(AppLink.sellerWalletBalance, headers: _auth(token));

  /// GET /history
  /// يُرجع: array of PayoutRequest objects
  Future<Either<StatusRequest, Map>> getWithdrawalHistory(String token) async {
    // الباك يُرجع array مباشرة - نلفّه في Map
    try {
      final result = await crud.getData(AppLink.sellerWalletHistory, headers: _auth(token));
      return result;
    } catch (e) {
      return const Left(StatusRequest.serverfailure);
    }
  }

  /// POST /payouts/instant-withdraw
  /// يُرسل: { amount, payout_method, payout_account? OR sham_code + qr_image }
  Future<Either<StatusRequest, Map>> withdraw(
    String token, {
    required Map<String, dynamic> data,
  }) async =>
      await crud.postData(
        AppLink.sellerWithdraw,
        data,
        headers: _auth(token),
      );
}
