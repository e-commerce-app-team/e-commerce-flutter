import '../../../../core/class/crud.dart';
import '../../../../link_api.dart';

class LoginData {
  Crud crud;
  LoginData(this.crud);

  postData(String email, String password) async {
    var response = await crud.postData(AppLink.login, {

      "login": email,

      "password": password,

    });
    return response;

  }

}