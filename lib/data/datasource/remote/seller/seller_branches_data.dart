import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/data/model/seller/branch_model.dart';
import 'package:e_commerce/link_api.dart';

class SellerBranchesData {
  final Crud crud;
  SellerBranchesData(this.crud);

  Future<dynamic> getBranches(String token) async =>
      await crud.getData(
        AppLink.sellerBranches,
        headers: {"Authorization": "Bearer $token"},
      );

  Future<dynamic> addBranch(String token, BranchModel branch) async =>
      await crud.postData(
        AppLink.sellerBranches,
        branch.toJson(),
        headers: {"Authorization": "Bearer $token"},
      );

  Future<dynamic> updateBranch(String token, BranchModel branch) async =>
      await crud.postData(
        '${AppLink.sellerBranches}/${branch.id}',
        branch.toJson(),
        headers: {"Authorization": "Bearer $token"},
      );

  Future<dynamic> deleteBranch(String token, int id) async =>
      await crud.postData(
        '${AppLink.sellerBranches}/$id/delete',
        {},
        headers: {"Authorization": "Bearer $token"},
      );

  Future<dynamic> toggleActive(String token, int id, bool isActive) async =>
      await crud.postData(
        '${AppLink.sellerBranches}/$id/toggle',
        {'is_active': isActive},
        headers: {"Authorization": "Bearer $token"},
      );
}