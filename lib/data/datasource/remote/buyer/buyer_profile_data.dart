import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/link_api.dart';

class BuyerProfileData {
  final Crud crud;
  BuyerProfileData(this.crud);

  Map<String, String> _auth(String token) => {'Authorization': 'Bearer $token'};

  Future<Either<StatusRequest, Map>> getProfile(String token) async =>
      await crud.getData('${AppLink.server}/buyer/profile', headers: _auth(token));

  Future<Either<StatusRequest, Map>> updateProfile(
    String token, {
    required Map<String, String> data,
    File? profilePhoto,
  }) async {
    if (profilePhoto != null) {
      return await crud.postDataWithFiles(
        '${AppLink.server}/buyer/profile',
        Map<String, String>.from(data)..['_method'] = 'PUT',
        {'profile_photo': profilePhoto},
        headers: _auth(token),
      );
    }
    return await crud.putData(
      '${AppLink.server}/buyer/profile',
      data,
      headers: _auth(token),
    );
  }

  Future<Either<StatusRequest, Map>> getAddresses(String token) async =>
      await crud.getData(AppLink.buyerAddresses, headers: _auth(token));

  Future<Either<StatusRequest, Map>> addAddress(String token, Map<String, dynamic> data) async =>
      await crud.postData(AppLink.buyerAddresses, data, headers: _auth(token));

  Future<Either<StatusRequest, Map>> updateAddress(String token, String id, Map<String, dynamic> data) async =>
      await crud.putData('${AppLink.buyerAddresses}/$id', data, headers: _auth(token));

  Future<Either<StatusRequest, Map>> deleteAddress(String token, String id) async =>
      await crud.deleteData('${AppLink.buyerAddresses}/$id', headers: _auth(token));

  Future<Either<StatusRequest, Map>> setDefaultAddress(String token, String id) async =>
      await crud.postData('${AppLink.buyerAddresses}/$id/default', {}, headers: _auth(token));

  Future<Either<StatusRequest, Map>> getWalletBalance(String token) async =>
      await crud.getData(AppLink.buyerWalletBalance, headers: _auth(token));

  Future<Either<StatusRequest, Map>> getWalletHistory(String token) async =>
      await crud.getData(AppLink.buyerWalletHistory, headers: _auth(token));

  Future<Either<StatusRequest, Map>> requestDeposit(String token, Map<String, dynamic> data) async =>
      await crud.postData('${AppLink.server}/buyer/wallet/deposit-requests', data, headers: _auth(token));

  Future<Either<StatusRequest, Map>> getDepositRequests(String token) async =>
      await crud.getData('${AppLink.server}/buyer/wallet/deposit-requests', headers: _auth(token));

  Future<Either<StatusRequest, Map>> getFollowingStores(String token) async =>
      await crud.getData('${AppLink.server}/buyer/following-stores', headers: _auth(token));

  Future<Either<StatusRequest, Map>> unfollowStore(String token, String storeId) async =>
      await crud.deleteData('${AppLink.server}/buyer/stores/$storeId/unfollow', headers: _auth(token));

  Future<Either<StatusRequest, Map>> getMyReviews(String token) async =>
      await crud.getData('${AppLink.server}/buyer/reviews', headers: _auth(token));

  Future<Either<StatusRequest, Map>> updateReview(String token, String id, Map<String, dynamic> data) async =>
      await crud.putData('${AppLink.server}/buyer/reviews/$id', data, headers: _auth(token));

  Future<Either<StatusRequest, Map>> getNotificationPreferences(String token) async =>
      await crud.getData('${AppLink.server}/buyer/notification-settings', headers: _auth(token));

  Future<Either<StatusRequest, Map>> updateNotificationPreferences(String token, Map<String, dynamic> data) async =>
      await crud.putData('${AppLink.server}/buyer/notification-settings', data, headers: _auth(token));

  Future<Either<StatusRequest, Map>> getConversations(String token) async =>
      await crud.getData('${AppLink.server}/buyer/conversations', headers: _auth(token));

  Future<Either<StatusRequest, Map>> changePassword(String token, Map<String, dynamic> data) async =>
      await crud.postData(AppLink.changePassword, data, headers: _auth(token));
}
