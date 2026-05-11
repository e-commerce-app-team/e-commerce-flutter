import 'package:get/get.dart';

import '../../core/constant/routes.dart';
import '../../core/functions/custom_snackbar.dart';

abstract class SelectAccountTypeController extends GetxController {
  void chooseUserType(String type);
  void goToNext();
}

class SelectAccountTypeControllerImp extends SelectAccountTypeController {
  String selectedType = "";

  @override
  void chooseUserType(String type) {
    selectedType = type;
    update();
  }

  @override
  void goToNext() {
    if (selectedType.isEmpty) {
      customSnackbar("Alert".tr,"Please choose the account type".tr,);
    } else if (selectedType == "buyer") {
       Get.toNamed(AppRoute.signUpBuyer);
    } else if (selectedType == "seller") {
       Get.toNamed(AppRoute.signUpSeller);
    }
  }
}