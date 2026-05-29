import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/link_api.dart';
import 'package:e_commerce/core/services/services.dart';

class SellerNotificationsData {
  Crud crud;
  SellerNotificationsData(this.crud);

  // POST /auth/fcm-token
  // Body: { fcm_token: "...", device: "android"|"ios" }
  Future<void> saveFCMToken(String fcmToken) async {
    try {
      await crud.postData(
        AppLink.fcmToken, // "https://api.yourapp.sy/v1/auth/fcm-token"
        {
          "fcm_token": fcmToken,
          "device": "android",
        },
      );
    } catch (_) {
    }
  }
}
