import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/link_api.dart';

class ForgetPasswordData {
  Crud crud;
  ForgetPasswordData(this.crud);

  sendOtp(String login) async {
    var response = await crud.postData(AppLink.forgotPasswordOTP, {
      "login": login,
    });
    return response;
  }

  verifyOtp(String login, String otp) async {
    var response = await crud.postData(AppLink.verifyResetOTP, {
      "login": login,
      "otp": otp,
    });
    return response;
  }

  resetPassword(String login, String otp, String password) async {
    var response = await crud.postData(AppLink.resetPasswordOTP, {
      "login": login,
      "otp": otp,
      "password": password,
      "password_confirmation": password,
    });
    return response;
  }
}
