import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/link_api.dart';

class BuyerStoreDetailDataSource {
  final Crud _crud = Crud();

  Map<String, String> _auth(String? token) =>
      token == null || token.isEmpty ? {} : {'Authorization': 'Bearer $token'};

  Future<Either<StatusRequest, Map>> getStoreDetails(
    String storeId, {
    String? token,
  }) {
    return _crud.getData(
      AppLink.buyerStoreDetails(storeId),
      headers: _auth(token),
    );
  }

  Future<Either<StatusRequest, Map>> getDepartments(
    String storeId, {
    String? token,
  }) {
    return _crud.getData(
      AppLink.buyerStoreDepartments(storeId),
      headers: _auth(token),
    );
  }

  Future<Either<StatusRequest, Map>> getProducts(
    String storeId, {
    String? token,
    int page = 1,
    int? departmentId,
    String? query,
    num? minPrice,
    num? maxPrice,
    String sortBy = 'latest',
  }) {
    final params = <String, String>{
      'page': page.toString(),
      'sort_by': sortBy,
      if (departmentId != null) 'department_id': departmentId.toString(),
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      if (minPrice != null) 'min_price': minPrice.toString(),
      if (maxPrice != null) 'max_price': maxPrice.toString(),
    };
    final url = Uri.parse(AppLink.buyerStoreProducts(storeId))
        .replace(queryParameters: params)
        .toString();
    return _crud.getData(url, headers: _auth(token));
  }

  Future<Either<StatusRequest, Map>> getReviews(
    String storeId, {
    String? token,
  }) {
    return _crud.getData(
      AppLink.buyerStoreReviews(storeId),
      headers: _auth(token),
    );
  }

  Future<Either<StatusRequest, Map>> toggleFollow(
    String storeId,
    String token,
  ) {
    return _crud.postData(
      AppLink.buyerToggleStoreFollow(storeId),
      {},
      headers: _auth(token),
    );
  }

  Future<Either<StatusRequest, Map>> addReview(
    String storeId,
    String token, {
    required double rating,
    required String comment,
  }) {
    return _crud.postData(
      AppLink.buyerRateStore(storeId),
      {
        'rating': rating,
        'comment': comment,
      },
      headers: _auth(token),
    );
  }
}
