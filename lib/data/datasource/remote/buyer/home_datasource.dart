import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/link_api.dart';

/// Remote datasource for all buyer home screen API calls.
/// Every method falls through gracefully so the controller can
/// show demo data when the backend hasn't implemented an endpoint yet.
class BuyerHomeRemoteDataSource {
  final Crud _crud = Crud();

  Future<Either<StatusRequest, Map>> getBanners() =>
      _crud.getData(AppLink.buyerBanners);

  Future<Either<StatusRequest, Map>> getCategories() =>
      _crud.getData(AppLink.buyerCategories);

  Future<Either<StatusRequest, Map>> getFeaturedStores() =>
      _crud.getData(AppLink.buyerFeaturedStores);

  Future<Either<StatusRequest, Map>> getNearbyStores({
    required double lat,
    required double lng,
    double radius = 10,
  }) =>
      _crud.getData(
          '${AppLink.buyerNearbyStores}?lat=$lat&lng=$lng&radius=$radius');

  Future<Either<StatusRequest, Map>> getFeaturedProducts() =>
      _crud.getData(AppLink.buyerFeaturedProducts);

  Future<Either<StatusRequest, Map>> getFlashSaleProducts() =>
      _crud.getData(AppLink.buyerFlashSale);

  Future<Either<StatusRequest, Map>> getTrendingProducts() =>
      _crud.getData(AppLink.buyerTrending);

  Future<Either<StatusRequest, Map>> getNewArrivals() =>
      _crud.getData(AppLink.buyerNewArrivals);

  Future<Either<StatusRequest, Map>> getOffers() =>
      _crud.getData(AppLink.buyerOffers);

  Future<Either<StatusRequest, Map>> getRecommended(String? token) =>
      _crud.getData(
        AppLink.buyerRecommended,
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

  Future<Either<StatusRequest, Map>> getAllProducts({
    int page = 1,
    String? categoryId,
    String? sortBy,
  }) {
    var url = '${AppLink.buyerAllProducts}?page=$page';
    if (categoryId != null && categoryId != 'all') {
      url += '&category_id=$categoryId';
    }
    if (sortBy != null) url += '&sort_by=$sortBy';
    return _crud.getData(url);
  }

  Future<Either<StatusRequest, Map>> getFavorites(String token) =>
      _crud.getData(
        AppLink.buyerFavorites,
        headers: {'Authorization': 'Bearer $token'},
      );

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
