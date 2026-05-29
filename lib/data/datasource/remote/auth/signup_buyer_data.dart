import 'dart:io';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/link_api.dart';

class SignUpBuyerData {
  Crud crud;
  SignUpBuyerData(this.crud);

  postData(Map<String, String> data, Map<String, File> files) async {
    var response = await crud.postDataWithFiles(AppLink.signUpBuyer, data, files);
    return response;
  }
}