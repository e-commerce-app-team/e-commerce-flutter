import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/link_api.dart';

class NotificationData {
  final Crud crud;
  NotificationData(this.crud);

  Map<String, String> _auth(String token) => {'Authorization': 'Bearer $token'};

  Future<Either<StatusRequest, Map>> index(String token) =>
      crud.getData(AppLink.notifications, headers: _auth(token));

  Future<Either<StatusRequest, Map>> markRead(String token, String id) =>
      crud.postData(AppLink.notificationRead(id), {}, headers: _auth(token));

  Future<Either<StatusRequest, Map>> markAllRead(String token) =>
      crud.postData(AppLink.notificationReadAll, {}, headers: _auth(token));

  Future<Either<StatusRequest, Map>> preferences(String token) =>
      crud.getData(AppLink.notificationPreferences, headers: _auth(token));

  Future<Either<StatusRequest, Map>> updatePreferences(
    String token,
    List<Map<String, dynamic>> settings,
  ) => crud.putData(AppLink.notificationPreferences, {
    'settings': settings,
  }, headers: _auth(token));

  Future<Either<StatusRequest, Map>> registerDevice(
    String token,
    Map<String, dynamic> data,
  ) => crud.postData(AppLink.notificationDevices, data, headers: _auth(token));

  Future<Either<StatusRequest, Map>> sendChatNotification(
    String token,
    Map<String, dynamic> data,
  ) => crud.postData(AppLink.chatNotification, data, headers: _auth(token));
}
