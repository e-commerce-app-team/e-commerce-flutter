import 'package:get/get.dart';

String? validInput(String val, int min, int max, String type) {

  if (val.isEmpty) {

    return "هذا الحقل مطلوب".tr;

  }

  if (val.length < min) {
    return "لا يمكن أن يكون أقل من $min".tr;

  }

  if (val.length > max) {
    return "لا يمكن أن يكون أكبر من $max".tr;
  }

  if (type == "name" || type == "store_name" || type == "company_name" || type == "rep_name") {

    RegExp validNameRegex = RegExp(r"^[a-zA-Z\u0600-\u06FF\s]+$");

    if (!validNameRegex.hasMatch(val)) {

      return "يجب أن يحتوي على أحرف فقط (بدون أرقام أو رموز)".tr;

    }

  }

  if (type == "email") {

    if (!GetUtils.isEmail(val)) {

      return "البريد الإلكتروني غير صالح".tr;

    }

  }

  if (type == "phone") {

    if (!GetUtils.isPhoneNumber(val)) {

      return "رقم الهاتف غير صالح".tr;

    }
    if (val.length != 10) {
      return "رقم الهاتف يجب أن يكون 10 أرقام بالضبط".tr;
    }
  }
  if (type == "password") {
    RegExp passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$');
    if (!passwordRegex.hasMatch(val)) {
      return "يجب أن تحتوي الكلمة على حرف كبير وصغير ورقم".tr;

    }

  }

  if (type == "commercial_register" || type == "tax_number") {

    if (!GetUtils.isNumericOnly(val)) {
      return "يجب أن يحتوي على أرقام فقط".tr;
    }
  }
  return null;
}