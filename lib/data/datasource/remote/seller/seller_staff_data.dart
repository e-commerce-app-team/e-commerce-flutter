import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/link_api.dart';

class SellerStaffData {
  final Crud crud;
  SellerStaffData(this.crud);

  Map<String, String> _auth(String token) => {
        'Authorization': 'Bearer $token',
      };

  // ─── GET /seller/staff ─────────────────────────────────────────────────
  Future<dynamic> getStaff(String token) async =>
      await crud.getData(AppLink.sellerStaff, headers: _auth(token));

  // ─── POST /seller/staff/invite ─────────────────────────────────────────
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

  // ─── PUT /seller/staff/{id} ────────────────────────────────────────────
  Future<dynamic> updateStaff(
    String token,
    int    id, {
    required String       role,
    required List<String> permissions,
  }) async =>
      await crud.putData(
        '${AppLink.sellerStaff}/$id',
        {
          'role':        role,
          'permissions': permissions,
        },
        headers: _auth(token),
      );

  // ─── DELETE /seller/staff/{id} ─────────────────────────────────────────
  Future<dynamic> deleteStaff(String token, int id) async =>
      await crud.deleteData(
        '${AppLink.sellerStaff}/$id',
        headers: _auth(token),
      );

  // ─── PATCH /seller/staff/{id}/toggle-status ────────────────────────────
  Future<dynamic> toggleStaffStatus(String token, int id) async =>
      await crud.patchData(
        '${AppLink.sellerStaff}/$id/toggle-status',
        {},
        headers: _auth(token),
      );
}
