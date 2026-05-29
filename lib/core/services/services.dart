import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../class/crud.dart';
import 'fcm_service.dart';

class MyServices extends GetxService{

 late SharedPreferences sharedPreferences ;

  Future<MyServices> init() async {
    await Firebase.initializeApp();
    sharedPreferences = await SharedPreferences.getInstance();
    return this;
  }



}
Future<void> initialServices() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Get.putAsync(() => MyServices().init());

  Get.put(Crud());


  Get.put(FCMService()).init();
}