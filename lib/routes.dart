import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/view/screen/auth/forgetpassword.dart';
import 'package:e_commerce/view/screen/auth/login.dart';
import 'package:e_commerce/view/screen/auth/resetpassword.dart';
import 'package:e_commerce/view/screen/auth/signup.dart';
import 'package:e_commerce/view/screen/auth/success_resetpassword.dart';
import 'package:e_commerce/view/screen/auth/success_signup.dart';
import 'package:e_commerce/view/screen/auth/verifycode.dart';
import 'package:e_commerce/view/screen/onboarding.dart';
import 'package:flutter/material.dart';

Map<String, Widget Function(BuildContext)> routes = {
  // Auth
  AppRoute.login: (context) => const Login(),
  AppRoute.signUp: (context) => const SignUp(),
  AppRoute.forgetPassword: (context) => const ForgetPassword(),
  AppRoute.verfiyCode: (context) => const VerfiyCode(),
  AppRoute.resetPassword: (context) => const ResetPassword(),
  AppRoute.successResetpassword: (context) => const SuccessResetPassword(),
  AppRoute.successSignUp: (context) => const SuccessSignUp(),
  // OnBoarding
  AppRoute.onBoarding: (context) => const OnBoarding(),
};