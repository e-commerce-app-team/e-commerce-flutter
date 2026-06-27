import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/data/model/seller/inventory_models.dart';
import 'package:e_commerce/link_api.dart';

/// Data layer for the Inventory module.
/// Communicates directly with the Laravel backend via the [Crud] class.
class InventoryData {
  final Crud crud;
  InventoryData(this.crud);

  // ─── Products ──────────────────────────────────────────────────────────────

  /// Fetches the seller's products ordered by [sortBy].
  /// [sortBy]: latest | oldest | price_asc | price_desc | best_selling
  Future<Either<StatusRequest, Map>> getProducts(
    String token, {
    String sortBy = 'latest',
    int perPage = 100,
  }) async {
    final url = Uri.parse(AppLink.productsSort)
        .replace(queryParameters: {
          'sort_by': sortBy,
          'per_page': perPage.toString(),
        })
        .toString();
    return await crud.getData(url, headers: _auth(token));
  }

  /// Searches products by name and/or SKU (GET /products/search).
  Future<Either<StatusRequest, Map>> searchProducts(
    String token, {
    String? name,
    String? sku,
    int perPage = 20,
  }) async {
    final params = <String, String>{'per_page': perPage.toString()};
    if (name != null && name.isNotEmpty) params['name'] = name;
    if (sku != null && sku.isNotEmpty) params['sku'] = sku;
    final url = Uri.parse(AppLink.productsSearch)
        .replace(queryParameters: params)
        .toString();
    return await crud.getData(url, headers: _auth(token));
  }

  /// Filters products by category (POST /products/filter-by-category).
  Future<Either<StatusRequest, Map>> filterByCategory(
    String token,
    int categoryId, {
    int perPage = 100,
  }) async =>
      await crud.postData(
        AppLink.productsFilterCategory,
        {'category_id': categoryId, 'per_page': perPage},
        headers: _auth(token),
      );

  /// Filters products by status (POST /products/filter-by-status).
  /// [status]: active | draft | hidden
  Future<Either<StatusRequest, Map>> filterByStatus(
    String token,
    String status, {
    int perPage = 100,
  }) async =>
      await crud.postData(
        AppLink.productsFilterStatus,
        {'status': status, 'per_page': perPage},
        headers: _auth(token),
      );

  /// Filters products by stock level (POST /products/filter-by-stock).
  /// [stockLevel]: low | out | good
  Future<Either<StatusRequest, Map>> filterByStock(
    String token,
    String stockLevel, {
    int perPage = 100,
  }) async =>
      await crud.postData(
        AppLink.productsFilterStock,
        {'stock_level': stockLevel, 'per_page': perPage},
        headers: _auth(token),
      );

  /// Creates a new product with images and variants (POST /products).
  ///
  /// Product images are sent as  images[0], images[1], ...
  /// Variant data is sent as     variants[i][attributes] (JSON string), etc.
  /// Variant images are sent as  variants[i][image]
  Future<Either<StatusRequest, Map>> createProduct(
    String token,
    Map<String, String> fields,
    List<File> productImages,
    List<ProductVariantModel> variants,
  ) async {
    final data = Map<String, String>.from(fields);
    final files = <String, File>{};

    // Attach product images
    for (int i = 0; i < productImages.length; i++) {
      files['images[$i]'] = productImages[i];
    }

    // Attach variant fields and optional images
    _appendVariantFields(data, files, variants);

    return await crud.postDataWithFiles(
      AppLink.products,
      data,
      files,
      headers: _auth(token),
    );
  }

  /// Updates an existing product (PUT /products/{id}).
  ///
  /// Pass [newImages] only when the user has selected replacement images.
  Future<Either<StatusRequest, Map>> updateProduct(
    String token,
    int productId,
    Map<String, String> fields,
    List<File> newImages,
    List<ProductVariantModel> variants,
  ) async {
    final data = Map<String, String>.from(fields);
    final files = <String, File>{};

    for (int i = 0; i < newImages.length; i++) {
      files['images[$i]'] = newImages[i];
    }

    _appendVariantFields(data, files, variants);

    return await crud.putDataWithFiles(
      '${AppLink.products}/$productId',
      data,
      files,
      headers: _auth(token),
    );
  }

  /// Permanently deletes a product and all its media (DELETE /products/{id}).
  Future<Either<StatusRequest, Map>> deleteProduct(
    String token,
    int productId,
  ) async =>
      await crud.deleteData(
        '${AppLink.products}/$productId',
        headers: _auth(token),
      );

  /// Performs a bulk action on multiple products (POST /products/bulk-action).
  /// [action]: activate | hide | delete | discount
  /// [discountPercentage]: required when action == 'discount' (1–99)
  Future<Either<StatusRequest, Map>> bulkAction(
    String token,
    List<int> ids,
    String action, {
    double? discountPercentage,
  }) async =>
      await crud.postData(
        AppLink.productsBulkAction,
        {
          'ids': ids,
          'action': action,
          if (discountPercentage != null)
            'discount_percentage': discountPercentage,
        },
        headers: _auth(token),
      );

  // ─── Variants ──────────────────────────────────────────────────────────────

  /// Toggles/updates a single variant's fields (POST /variants/{id}/toggle).
  /// Pass only the fields you want to update.
  Future<Either<StatusRequest, Map>> toggleVariant(
    String token,
    int variantId, {
    bool? isActive,
    int? quantity,
    int? price,
  }) async =>
      await crud.postData(
        '${AppLink.variants}/$variantId/toggle',
        {
          if (isActive != null) 'is_active': isActive,
          if (quantity != null) 'quantity': quantity,
          if (price != null) 'price': price,
        },
        headers: _auth(token),
      );

  // ─── Categories ────────────────────────────────────────────────────────────

  /// Fetches all categories (GET /categories).
  /// Note: category creation/update/delete requires super_admin role.
  Future<Either<StatusRequest, Map>> getCategories(String token) async =>
      await crud.getData(AppLink.categories, headers: _auth(token));

  // ─── Private Helpers ───────────────────────────────────────────────────────

  Map<String, String> _auth(String token) =>
      {'Authorization': 'Bearer $token'};

  /// Encodes variant data into flat string fields and attaches variant images.
  ///
  /// The backend's ProductSaveRequest expects:
  ///   variants[i][attributes] — JSON string (backend decodes it automatically)
  ///   variants[i][quantity]
  ///   variants[i][price]      (optional)
  ///   variants[i][sku]        (optional)
  ///   variants[i][is_active]
  ///   variants[i][image]      (optional file)
  void _appendVariantFields(
    Map<String, String> data,
    Map<String, File> files,
    List<ProductVariantModel> variants,
  ) {
    for (int i = 0; i < variants.length; i++) {
      final v = variants[i];
      // Send attributes as array fields so Laravel validation (required|array) passes
      v.attributes.forEach((key, val) {
        data['variants[$i][attributes][$key]'] = val;
      });
      data['variants[$i][quantity]'] = v.stock.toString();
      if (v.price != null) data['variants[$i][price]'] = v.price.toString();
      if (v.sku != null && v.sku!.isNotEmpty) {
        data['variants[$i][sku]'] = v.sku!;
      }
      data['variants[$i][is_active]'] = v.isActive ? '1' : '0';
      if (v.localImage != null) {
        files['variants[$i][image]'] = v.localImage!;
      }
    }
  }
}