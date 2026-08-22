import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../controller/buyer/buyer_orders_controller.dart';
import '../../controller/notification_controller.dart';
import '../../controller/seller/seller_main_controller.dart';
import '../../data/datasource/remote/notification_data.dart';
import '../../core/constant/routes.dart';
import '../class/crud.dart';
import 'services.dart';

class FCMService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  late final NotificationData _dataSource;
  StreamSubscription<String>? _tokenSubscription;

  Future<FCMService> init() async {
    _dataSource = NotificationData(Get.find<Crud>());
    await _initializeLocalNotifications();
    await _requestPermission();
    await _setupToken();
    _listenToMessages();
    return this;
  }

  Future<void> _initializeLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _local.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final raw = response.payload;
        if (raw == null || raw.isEmpty) return;
        handleNotificationData(Map<String, dynamic>.from(jsonDecode(raw)));
      },
    );
    final android = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        'system_notifications',
        'System notifications',
        description: 'Order, chat and announcement notifications',
        importance: Importance.high,
      ),
    );
  }

  Future<void> _requestPermission() async =>
      _messaging.requestPermission(alert: true, badge: true, sound: true);

  Future<void> _setupToken() async {
    await _registerTokenIfAuthenticated(await _messaging.getToken());
    _tokenSubscription = _messaging.onTokenRefresh.listen(
      _registerTokenIfAuthenticated,
    );
  }

  Future<void> registerCurrentDevice() async =>
      _registerTokenIfAuthenticated(await _messaging.getToken());

  Future<void> _registerTokenIfAuthenticated(String? token) async {
    final services = Get.find<MyServices>();
    final authToken = services.sharedPreferences.getString('token') ?? '';
    if (token == null || token.isEmpty || authToken.isEmpty) return;
    await _dataSource.registerDevice(authToken, {
      'fcm_token': token,
      'platform': Platform.isIOS
          ? 'ios'
          : Platform.isAndroid
          ? 'android'
          : 'other',
      'locale': Get.locale?.languageCode ?? 'en',
    });
  }

  void _listenToMessages() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => handleNotificationData(message.data),
    );
    _messaging.getInitialMessage().then((message) {
      if (message != null)
        Future.delayed(
          const Duration(milliseconds: 700),
          () => handleNotificationData(message.data),
        );
    });
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final data = Map<String, dynamic>.from(message.data);
    if (Get.isRegistered<NotificationController>())
      Get.find<NotificationController>().load();
    if (Get.isRegistered<SellerMainController>()) {
      final seller = Get.find<SellerMainController>();
      if (data['type'] == 'new_order') seller.incrementOrders();
      if (data['type'] == 'chat_message')
        seller.setUnreadMessages(seller.unreadMessagesCount + 1);
    }
    await _local.show(
      id:
          data['notification_id']?.toString().hashCode ??
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: _localized(data, 'title'),
      body: _localized(data, 'message'),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'system_notifications',
          'System notifications',
          channelDescription: 'Order, chat and announcement notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(data),
    );
  }

  String _localized(Map<String, dynamic> data, String field) {
    final arabic = (Get.locale?.languageCode ?? 'ar') == 'ar';
    return (data[arabic ? '${field}_ar' : '${field}_en'] ??
            data['${field}_key'] ??
            '')
        .toString();
  }

  void handleNotificationData(Map<String, dynamic> data) {
    final type = '${data['type'] ?? ''}';
    final services = Get.find<MyServices>();
    final role = services.userRole;
    final orderId = data['order_id']?.toString();

    if (type == 'chat_message') {
      final senderId = data['sender_id']?.toString() ?? '';
      if (role == 'buyer' && senderId.isNotEmpty) {
        Get.toNamed(AppRoute.buyerChatRoom, arguments: {'seller_id': senderId});
      } else if (role != 'buyer') {
        _openSellerTab(3);
      }
      return;
    }
    if (orderId != null && orderId.isNotEmpty) {
      if (role == 'buyer') {
        if (Get.isRegistered<BuyerOrdersController>()) {
          Get.toNamed(AppRoute.buyerOrderDetail, arguments: orderId);
        } else {
          Get.offAllNamed(AppRoute.buyerMain);
          Future.delayed(
            const Duration(milliseconds: 500),
            () => Get.toNamed(AppRoute.buyerOrderDetail, arguments: orderId),
          );
        }
      } else {
        _openSellerTab(2);
      }
      return;
    }
    Get.toNamed(AppRoute.notifications);
  }

  void _openSellerTab(int index) {
    if (Get.currentRoute != AppRoute.sellerMain)
      Get.offAllNamed(AppRoute.sellerMain);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (Get.isRegistered<SellerMainController>())
        Get.find<SellerMainController>().changeTab(index);
    });
  }

  @override
  void onClose() {
    _tokenSubscription?.cancel();
    super.onClose();
  }
}
