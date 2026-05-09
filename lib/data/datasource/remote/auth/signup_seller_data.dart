import 'dart:io';

import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/link_api.dart';

class SignupSellerData {

 Crud crud ;
 SignupSellerData (this.crud);
 postData(Map<String, String> data, Map<String, File> files) async{
   var response =await crud.postDataWithFiles(AppLink.signUpSeller, data, files);
   return response.fold((l) => l, (r) => r);
 }

}