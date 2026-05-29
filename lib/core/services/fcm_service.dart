import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import '../../controller/seller/seller_main_controller.dart';
import '../../data/datasource/remote/seller/seller_notifications_data.dart';
import '../class/crud.dart';
import '../constant/routes.dart';
import '../functions/custom_snackbar.dart';

class FCMService extends GetxService{
  final FirebaseMessaging _firebaseMessaging=FirebaseMessaging.instance;
  late SellerNotificationsData notificationsData;
  Future<FCMService> init()async{
    notificationsData = SellerNotificationsData(Get.find<Crud>());
    await _requestPermission();
    await _setupToken();
    _listenToMessages();

    return this;
  }
  Future<void> _requestPermission()async{
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');

  }
}
Future<void> _setupToken()async{
    String? fcmToken = await _firebaseMessaging.getToken();
  if (fcmToken != null) {
    await _sendFCMTokenToServer(fcmToken);
  }
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _sendFCMTokenToServer(newToken);
    });

    }
  Future<void> _sendFCMTokenToServer(String fcmToken) async {
    await notificationsData.saveFCMToken(fcmToken);
  }
  void _listenToMessages(){
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });
    FirebaseMessaging.instance.getInitialMessage().then((initialMessage) {
      if (initialMessage != null) {
        Future.delayed(const Duration(seconds: 1), () {
          _handleNotificationTap(initialMessage);
        });
      }
    });
  }
  void _handleForegroundMessage(RemoteMessage message) {
    final type = message.data['type'] ?? '';

    if (Get.isRegistered<SellerMainController>()) {
      SellerMainController sellerController = Get.find<SellerMainController>();

      switch (type) {
        case 'new_order':
          sellerController.incrementOrders();
          customSnackbar(message.notification?.title ??'New Order'.tr,
              message.notification?.body ??'A new order has been placed.'.tr, isError: false);
          break;
        case 'new_message':
          sellerController.setUnreadMessages(sellerController.unreadMessagesCount + 1);
          break;
      }
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    final type = message.data['type'] ?? '';

    if (Get.isRegistered<SellerMainController>()) {
      SellerMainController sellerController = Get.find<SellerMainController>();
      switch (type) {
        case 'new_order':
          sellerController.changeTab(2);
          break;
        case 'new_message':
          sellerController.changeTab(3);
          break;
      }
    } else {
      Get.offAllNamed(AppRoute.sellerMain);
    }
  }
}


