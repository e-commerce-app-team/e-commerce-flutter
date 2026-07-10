import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/link_api.dart';

class SellerChatData {
  final Crud crud;
  SellerChatData(this.crud);

  Map<String, String> _auth(String token) => {'Authorization': 'Bearer $token'};

  Future<Either<StatusRequest, Map>> getFirebaseAuthToken(String token) async =>
      await crud.getData(AppLink.chatFirebaseAuth, headers: _auth(token));

  Future<Either<StatusRequest, Map>> getQuickReplies(String token) async =>
      await crud.getData(AppLink.chatQuickReplies, headers: _auth(token));

  Future<Either<StatusRequest, Map>> addQuickReply(String token, String title, String content) async =>
      await crud.postData(AppLink.chatQuickReplies, {'title': title, 'message': content}, headers: _auth(token));

  Future<Either<StatusRequest, Map>> updateQuickReply(String token, int id, String title, String content) async =>
      await crud.putData('${AppLink.chatQuickReplies}/$id', {'title': title, 'message': content}, headers: _auth(token));

  Future<Either<StatusRequest, Map>> deleteQuickReply(String token, int id) async =>
      await crud.deleteData('${AppLink.chatQuickReplies}/$id', headers: _auth(token));

  Future<Either<StatusRequest, Map>> getAutoReplies(String token) async =>
      await crud.getData(AppLink.chatAutoReplies, headers: _auth(token));

  Future<Either<StatusRequest, Map>> toggleAutoReply(String token, String id, bool enabled) async =>
      await crud.putData('${AppLink.chatAutoReplies}/$id', {'is_active': enabled}, headers: _auth(token));

  Future<Either<StatusRequest, Map>> updateAutoReply(String token, String id, String keyword, String message) async =>
      await crud.putData('${AppLink.chatAutoReplies}/$id', {'keyword': keyword, 'message': message}, headers: _auth(token));

  Future<Either<StatusRequest, Map>> blockUser(String token, int userId) async =>
      await crud.postData(AppLink.chatBlockUser, {'blocked_id': userId}, headers: _auth(token));

  Future<Either<StatusRequest, Map>> unblockUser(String token, int userId) async =>
      await crud.deleteData('${AppLink.chatUnblockUser}/$userId', headers: _auth(token));

  Future<Either<StatusRequest, Map>> getBlockedUsers(String token) async =>
      await crud.getData(AppLink.chatBlockedUsers, headers: _auth(token));

  Future<Either<StatusRequest, Map>> reportUser(String token, int reportedId, String reason) async =>
      await crud.postData(AppLink.chatReportUser, {'reported_id': reportedId, 'reason': reason}, headers: _auth(token));
}
