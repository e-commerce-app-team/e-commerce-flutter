import 'package:e_commerce/core/localization/translation.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'core/class/crud.dart';
import 'core/localization/changelocal.dart';
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {

}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialServices();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const MyApp());

}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link if app was in cold state (terminated)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint("Failed to get initial app link: $e");
    }

    // Handle link when app is in warm state (foreground or background)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      debugPrint("Failed to handle incoming app link: $err");
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'ecomapp' && uri.host == 'staff' && uri.path == '/accept-invite') {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        // Navigate to the staff accept invite screen
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.toNamed(
            AppRoute.staffAcceptInvite,
            arguments: {'token': token},
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LocaleController controller = Get.put(LocaleController());
    return GetMaterialApp(
      translations: MyTranslation(),
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      locale: controller.language,
      theme: controller.appTheme,
      initialBinding: BindingsBuilder(() {
        Get.put(Crud());
      }),
      getPages: routes,
    );
  }
}
