import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../core/constant/routes.dart';

class SelectAccountTypeController extends GetxController{

  late PageController pageController;
  int currentPage= 0;
  @override
  void onInit() {
    pageController = PageController();
    super.onInit();
  }

  void onPageChanged (int index)
  {
    currentPage = index;
    update();
  }

void goToSignUp(){

    if(currentPage == 0){
      Get.toNamed(AppRoute.signUpBuyer);
    }else if(currentPage == 1){
      Get.toNamed(AppRoute.signUpSeller);
    }
}
@override
  void dispose(){
    pageController.dispose();
    super.dispose();

}


}