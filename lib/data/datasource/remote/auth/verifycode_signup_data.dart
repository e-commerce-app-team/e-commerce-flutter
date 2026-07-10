import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/link_api.dart';

class VerifyCodeSignUpData {
  Crud crud;
  VerifyCodeSignUpData(this.crud);

  // إرسال كود التحقق قبل التسجيل
  sendOtp(String email, String phone, String firstName, String method) async {
    var response = await crud.postData(AppLink.sendSignupOtp, {
      "email": email,
      "phone": phone,
      "first_name": firstName,
      "method": method,
    });
    return response;
  }

  // التحقق من الكود
  verifyOtp(String identifier, String otp) async {
    var response = await crud.postData(AppLink.verifySignupOtp, {
      "identifier": identifier,
      "otp": otp,
    });
    return response;
  }
}
