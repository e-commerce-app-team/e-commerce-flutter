import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/link_api.dart';

class ChangePasswordData {
  final Crud crud;
  ChangePasswordData(this.crud);

  Future changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async =>
      await crud.postData(AppLink.changePassword, {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': confirmPassword,
      });

  Future sendForgotPasswordOTP(String email) async =>
      await crud.postData(AppLink.forgotPasswordOTP, {'email': email});

  Future verifyOTP(String email, String otp) async =>
      await crud.postData(AppLink.verifyResetOTP, {
        'email': email,
        'otp': otp,
      });

  Future resetPassword({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  }) async =>
      await crud.postData(AppLink.resetPasswordOTP, {
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': confirmPassword,
      });
}