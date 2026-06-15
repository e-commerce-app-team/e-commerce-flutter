import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/link_api.dart';
import 'package:e_commerce/core/services/services.dart';

class SellerNotificationsData {
  Crud crud;
  SellerNotificationsData(this.crud);


  Future<void> saveFCMToken(String fcmToken) async {
    try {
      await crud.postData(
        AppLink.fcmToken,
        {
          "fcm_token": fcmToken,
          "device": "android",
        },
      );
    } catch (_) {
    }
  }
}
