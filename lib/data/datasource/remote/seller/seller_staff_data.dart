import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/link_api.dart';

class SellerStaffData {
  final Crud crud;
  SellerStaffData(this.crud);

  Map<String, String> _auth(String token) => {
        'Authorization': 'Bearer $token',
      };

  Future<dynamic> getStaff(String token) async =>
      await crud.getData(AppLink.sellerStaff, headers: _auth(token));

  Future<dynamic> inviteStaff(
    String token, {
    required String       email,
    required String       role,
    required List<String> permissions,
  }) async =>
      await crud.postData(
        AppLink.sellerStaffInvite,
        {
          'email':       email,
          'role':        role,
          'permissions': permissions,
        },
        headers: _auth(token),
      );

  Future<dynamic> updateStaff(
    String token,
    int    id, {
    required String       role,
    required List<String> permissions,
  }) async =>
      await crud.postData(
        '${AppLink.sellerStaff}/$id',
        {
          'role':        role,
          'permissions': permissions,
          '_method':     'PUT',
        },
        headers: _auth(token),
      );

  Future<dynamic> deleteStaff(String token, int id) async =>
      await crud.postData(
        '${AppLink.sellerStaff}/$id/delete',
        {},
        headers: _auth(token),
      );
}

