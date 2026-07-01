/*import 'dart:io';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/link_api.dart';

class InventoryData {
  final Crud crud;
  InventoryData(this.crud);

  Future getProducts({
    int page = 1,
    int? categoryId,
    String? status,
    String? stock,
    String? sort,
    String? search,
  }) async {
    return await crud.postData(
      AppLink.getProducts,
      {
        'page': page.toString(),
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (status != null) 'status': status,
        if (stock != null) 'stock_level': stock,
        if (sort != null) 'sort': sort,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
  }

  Future createProduct(Map<String, String> data, Map<String, File> files) async =>
      await crud.postDataWithFiles(AppLink.createProduct, data, files);

  Future updateProduct(int id, Map<String, String> data, Map<String, File> files) async =>
      await crud.postDataWithFiles('${AppLink.updateProduct}/$id', data, files);

  Future deleteProduct(int id) async =>
      await crud.postData('${AppLink.deleteProduct}/$id', {});

  Future updateProductStatus(int id, String status) async =>
      await crud.postData(AppLink.updateProductStatus, {
        'product_id': id.toString(),
        'status': status,
      });

  Future getCategories() async =>
      await crud.postData(AppLink.getCategories, {});

  Future createCategory(String name, int? parentId) async =>
      await crud.postData(AppLink.createCategory, {
        'name': name,
        if (parentId != null) 'parent_id': parentId.toString(),
      });

  Future updateCategory(int id, String name) async =>
      await crud.postData('${AppLink.updateCategory}/$id', {'name': name});

  Future deleteCategory(int id) async =>
      await crud.postData('${AppLink.deleteCategory}/$id', {});

  Future getWarehouses() async =>
      await crud.postData(AppLink.getWarehouses, {});
}*/