import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/link_api.dart';

class BuyerExploreRemoteDataSource {
  final Crud _crud = Crud();

  Future<Either<StatusRequest, Map>> getCategories() =>
      _crud.getData(AppLink.buyerCategories);

  Future<Either<StatusRequest, Map>> getProducts({
    String? query,
    String? categoryId,
    String? sortBy,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? freeShipping,
    bool? discounted,
    bool? inStock,
    String? storeId,
    String? token,
  }) {
    final params = <String, String>{
      'page': '1',
      'per_page': '60',
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      if (categoryId != null && categoryId != 'all') 'category_id': categoryId,
      if (sortBy != null) 'sort_by': sortBy,
      if (minPrice != null) 'min_price': minPrice.round().toString(),
      if (maxPrice != null) 'max_price': maxPrice.round().toString(),
      if (minRating != null && minRating > 0) 'min_rating': minRating.toString(),
      if (freeShipping == true) 'free_shipping': '1',
      if (discounted == true) 'discounted': '1',
      if (inStock == true) 'in_stock': '1',
      if (storeId != null && storeId.isNotEmpty) 'store_id': storeId,
    };
    final uri = Uri.parse(AppLink.buyerAllProducts).replace(queryParameters: params);
    return _crud.getData(
      uri.toString(),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );
  }

  Future<Either<StatusRequest, Map>> getStores({
    String? query,
    String? categoryId,
    String? sortBy,
    double? minRating,
    bool? openNow,
    bool? hasProducts,
    double? lat,
    double? lng,
    double? radius,
    String? token,
  }) {
    final params = <String, String>{
      'per_page': '80',
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      if (categoryId != null && categoryId != 'all') 'category_id': categoryId,
      if (sortBy != null) 'sort_by': sortBy,
      if (minRating != null && minRating > 0) 'min_rating': minRating.toString(),
      if (openNow == true) 'open_now': '1',
      if (hasProducts == true) 'has_products': '1',
      if (lat != null) 'lat': lat.toString(),
      if (lng != null) 'lng': lng.toString(),
      if (radius != null) 'radius': radius.toString(),
    };
    final uri = Uri.parse(AppLink.buyerStores).replace(queryParameters: params);
    return _crud.getData(
      uri.toString(),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );
  }

  Future<Either<StatusRequest, Map>> toggleFavorite(
    String productId,
    String token,
  ) =>
      _crud.postData(
        AppLink.buyerToggleFavorite(productId),
        {},
        headers: {'Authorization': 'Bearer $token'},
      );

  Future<Either<StatusRequest, Map>> addToCart(String productId, String token) =>
      _crud.postData(
        AppLink.buyerCartAdd,
        {'product_id': productId, 'qty': 1},
        headers: {'Authorization': 'Bearer $token'},
      );
}
