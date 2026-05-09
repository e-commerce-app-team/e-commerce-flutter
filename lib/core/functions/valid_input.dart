import 'package:get/get.dart';
validInput(String val, int min, int max, String type) {
  if (val.isEmpty) {
    return "can't be Empty";
  }
  if (val.length < min) {
    return "can't be less than $min";
  }

  if (val.length > max) {
    return "can't be larger than $max";
  }

  if (type == "username") {
    if (!GetUtils.isUsername(val)) {
      return "not valid username";
    }
  }
  if (type == "email") {
    if (!GetUtils.isEmail(val)) {
      return "not valid email";
    }
  }

  if (type == "phone") {
    if (!GetUtils.isPhoneNumber(val)) {
      return "not valid phone";
    }
    if (val.length != 10) {
      return "رقم الهاتف يجب أن يكون 10 أرقام بالضبط";
    }

  }
  if (type == "password") {
    RegExp passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$');
    if (!passwordRegex.hasMatch(val)) {
      return "يجب أن تحتوي الكلمة على حرف كبير وصغير ورقم";
    }
  }

  if (type == "commercial_register" || type == "tax_number") {
    if (!GetUtils.isNumericOnly(val)) {
      return "must be numbers only";
    }
  }

  if (type == "username" || type == "store_name" || type == "company_name" || type == "rep_name") {
    // RegExp validNameRegex = RegExp(r"^[a-zA-Z\u0600-\u06FF\s]+$");
    // if (!validNameRegex.hasMatch(val)) return "invalid name format";
  }
}