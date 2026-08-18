import 'package:get/get.dart';

String exploreText(String ar, String en) {
  return Get.locale?.languageCode == 'ar' ? ar : en;
}
