import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/core/middleware/my_middleware.dart';
import 'package:e_commerce/view/screen/auth/forgetpassword/forgetpassword.dart';
import 'package:e_commerce/view/screen/auth/login.dart';
import 'package:e_commerce/view/screen/auth/select_account_type.dart';
import 'package:e_commerce/view/screen/auth/forgetpassword/resetpassword.dart';
import 'package:e_commerce/view/screen/auth/forgetpassword/success_resetpassword.dart';
import 'package:e_commerce/view/screen/auth/signup/signup_buyer.dart';
import 'package:e_commerce/view/screen/auth/signup/signup_seller.dart';
import 'package:e_commerce/view/screen/auth/success_signup.dart';
import 'package:e_commerce/view/screen/auth/forgetpassword/verifycode.dart';
import 'package:e_commerce/view/screen/auth/verifycodesignup.dart';
import 'package:e_commerce/view/screen/onboarding.dart';
import 'package:e_commerce/view/screen/seller/dashboard/drawer/spin_wheel_screen.dart';
import 'package:e_commerce/view/screen/seller/seller_main_screen.dart';
import 'package:e_commerce/view/widget/seller/seller_drawer.dart';
import 'package:get/get.dart';

List<GetPage<dynamic>>? routes = [

  GetPage(name: "/", page: () => const SellerMainScreen(), middlewares: [

    MyMiddleWare()

  ]),

  GetPage(name: AppRoute.login, page: () => const Login()),

  GetPage(name: AppRoute.selectAccountType, page: () => const SelectAccountType()),

  GetPage(name: AppRoute.signUpBuyer, page: () => const SignUpBuyer()),

  GetPage(name: AppRoute.signUpSeller, page: () => const SignUpSeller()),

  GetPage(name: AppRoute.forgetPassword, page: () => const ForgetPassword()),

  GetPage(name: AppRoute.verfiyCode, page: () => const VerfiyCode()),

  GetPage(name: AppRoute.resetPassword, page: () => const ResetPassword()),

  GetPage(name: AppRoute.successResetpassword, page: () => const SuccessResetPassword()),

  GetPage(name: AppRoute.successSignUp, page: () => const SuccessSignUp()),

  GetPage(name: AppRoute.verfiyCodeSignUp, page: () => const VerfiyCodeSignUp()),

  GetPage(name: AppRoute.successSignUp, page: () => const SuccessSignUp()),
  GetPage(name: AppRoute.sellerMain, page: () => const SellerMainScreen()),
  GetPage(name: AppRoute.sellerDrawer, page: () => const SellerDrawer()),
  GetPage(name: AppRoute.spinWheele, page: () => const SpinWheelScreen()),

];
