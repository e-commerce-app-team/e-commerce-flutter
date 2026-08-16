import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/controller/buyer/buyer_home_controller.dart';
import 'package:e_commerce/data/models/buyer/home_models.dart';

// Header
import 'package:e_commerce/view/widget/buyer/home/buyer_home_header.dart';
// Banner
import 'package:e_commerce/view/widget/buyer/home/hero_banner_carousel.dart';
// Categories
import 'package:e_commerce/view/widget/buyer/home/categories_bar.dart';
// Flash Sale
import 'package:e_commerce/view/widget/buyer/home/flash_sale_section.dart';
// Featured Stores
import 'package:e_commerce/view/widget/buyer/home/featured_stores_section.dart';
// Featured Products
import 'package:e_commerce/view/widget/buyer/home/featured_products_section.dart';
// Nearby Stores
import 'package:e_commerce/view/widget/buyer/home/nearby_stores_section.dart';
// Recommended
import 'package:e_commerce/view/widget/buyer/home/recommended_section.dart';
// New Arrivals
import 'package:e_commerce/view/widget/buyer/home/new_arrivals_section.dart';
// Offers
import 'package:e_commerce/view/widget/buyer/home/offers_section.dart';
// Trending
import 'package:e_commerce/view/widget/buyer/home/trending_products_section.dart';
// Favorites
import 'package:e_commerce/view/widget/buyer/home/favorites_section.dart';
// All Products
import 'package:e_commerce/view/widget/buyer/home/all_products_section.dart';

void _openProduct(BuyerProductItem product) {
  final id = product.id;
  if (id == null || id.isEmpty) return;
  Get.toNamed(AppRoute.buyerProductDetail, arguments: {'product_id': id});
}

/// NEXUS Buyer Home Screen.
///
/// Section order (top → bottom):
///   1.  Header (NEXUS + greeting + search)
///   2.  Hero Banner Carousel (seller ads)
///   3.  Categories (glassmorphism pills)
///   4.  Flash Sale / Deals (countdown)
///   5.  Featured Stores (boosted + high rating)
///   6.  Featured Products (ads + rating ≥4.5)
///   7.  Nearby Stores (location-based)
///   8.  New Arrivals
///   9.  Recommended For You (personalized)
///  10.  Deals & Offers (discount products)
///  11.  Trending Now (2-col grid)
///  12.  Favorites (conditional — only if items saved)
///  13.  All Products (paginated 2-col grid)
class BuyerHomeScreen extends StatelessWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(BuyerHomeController());

    return Scaffold(
      backgroundColor: AppColor.backgroundcolor,
      body: SafeArea(
        bottom: false,
        child: GetBuilder<BuyerHomeController>(
          builder: (controller) {
            // ── Full-screen shimmer on first load ─────────────────────────
            if (controller.isLoading) {
              return const _HomeLoadingShimmer();
            }

            return RefreshIndicator(
              color: AppColor.primaryColor,
              onRefresh: controller.refreshAll,
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                children: [
                  // ① Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: BuyerHomeHeader(
                      userName: 'خالد',
                      deliveryLocation: 'دمشق - المزة، شارع الشيخ سعد',
                      notificationCount: 0,
                      cartCount: 0,
                      searchHint: 'search_hint_home'.tr,
                      onNotificationTap: null,
                      onCartTap: null,
                      onSearchTap: () => Get.toNamed(AppRoute.explore),
                      onLocationTap: () {},
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ② Hero Banner
                  if (controller.banners.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: HeroBannerCarousel(banners: controller.banners),
                    ),
                  const SizedBox(height: 28),

                  // ③ Categories
                  if (controller.categories.isNotEmpty) ...[
                    CategoriesBar(
                      categories: controller.categories,
                      selectedId: controller.selectedCategoryId,
                      onSelected: (c) => controller.changeCategory(c.id),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // ④ Flash Sale
                  if (controller.flashSaleProducts.isNotEmpty)
                    FlashSaleSection(
                      products: controller.flashSaleProducts,
                      remaining: controller.flashSaleRemaining,
                      onSeeAll: () {},
                      onProductTap: (i) => _openProduct(controller.flashSaleProducts[i]),
                      onAddToCart: (i) => controller.addToCart(controller.flashSaleProducts[i]),
                    ),
                  if (controller.flashSaleProducts.isNotEmpty)
                    const SizedBox(height: 32),

                  // ⑤ Featured Stores
                  if (controller.featuredStores.isNotEmpty)
                    FeaturedStoresSection(
                      stores: controller.featuredStores,
                      onSeeAll: () {},
                      onStoreTap: (index) {
                        final id = controller.featuredStores[index].id;
                        if (id != null && id.isNotEmpty) {
                          Get.toNamed(
                            AppRoute.buyerStoreDetail,
                            arguments: {'store_id': id},
                          );
                        }
                      },
                    ),
                  if (controller.featuredStores.isNotEmpty)
                    const SizedBox(height: 32),

                  // ⑥ Featured Products
                  if (controller.featuredProducts.isNotEmpty)
                    FeaturedProductsSection(
                      products: controller.featuredProducts,
                      onSeeAll: () {},
                      onProductTap: (i) => _openProduct(controller.featuredProducts[i]),
                      onFavoriteToggle: (i) =>
                          controller.toggleFavorite(i, 'featured'),
                      onAddToCart: (i) => controller.addToCart(controller.featuredProducts[i]),
                    ),
                  if (controller.featuredProducts.isNotEmpty)
                    const SizedBox(height: 32),

                  // ⑦ Nearby Stores
                  if (controller.nearbyStores.isNotEmpty)
                    NearbyStoresSection(
                      stores: controller.nearbyStores,
                      onSeeAll: () {},
                      onStoreTap: (index) {
                        final id = controller.nearbyStores[index].id;
                        if (id != null && id.isNotEmpty) {
                          Get.toNamed(
                            AppRoute.buyerStoreDetail,
                            arguments: {'store_id': id},
                          );
                        }
                      },
                    ),
                  if (controller.nearbyStores.isNotEmpty)
                    const SizedBox(height: 32),

                  // ⑧ New Arrivals
                  if (controller.newArrivals.isNotEmpty)
                    NewArrivalsSection(
                      products: controller.newArrivals,
                      onSeeAll: () {},
                      onProductTap: (i) => _openProduct(controller.newArrivals[i]),
                      onFavoriteToggle: (i) =>
                          controller.toggleFavorite(i, 'new'),
                      onAddToCart: (i) => controller.addToCart(controller.newArrivals[i]),
                    ),
                  if (controller.newArrivals.isNotEmpty)
                    const SizedBox(height: 32),

                  // ⑨ Recommended For You
                  if (controller.recommendedProducts.isNotEmpty)
                    RecommendedSection(
                      products: controller.recommendedProducts,
                      onSeeAll: () {},
                      onProductTap: (i) => _openProduct(controller.recommendedProducts[i]),
                      onFavoriteToggle: (i) =>
                          controller.toggleFavorite(i, 'recommended'),
                      onAddToCart: (i) => controller.addToCart(controller.recommendedProducts[i]),
                    ),
                  if (controller.recommendedProducts.isNotEmpty)
                    const SizedBox(height: 32),

                  // ⑩ Deals & Offers
                  if (controller.offerProducts.isNotEmpty)
                    OffersSection(
                      products: controller.offerProducts,
                      onSeeAll: () {},
                      onProductTap: (i) => _openProduct(controller.offerProducts[i]),
                      onFavoriteToggle: (i) =>
                          controller.toggleFavorite(i, 'offers'),
                      onAddToCart: (i) => controller.addToCart(controller.offerProducts[i]),
                    ),
                  if (controller.offerProducts.isNotEmpty)
                    const SizedBox(height: 32),

                  // ⑪ Trending Now
                  if (controller.trendingProducts.isNotEmpty)
                    TrendingProductsSection(
                      products: controller.trendingProducts,
                      onSeeAll: () {},
                      onProductTap: (i) => _openProduct(controller.trendingProducts[i]),
                      onFavoriteToggle: (i) =>
                          controller.toggleFavorite(i, 'trending'),
                      onAddToCart: (i) => controller.addToCart(controller.trendingProducts[i]),
                    ),
                  if (controller.trendingProducts.isNotEmpty)
                    const SizedBox(height: 32),

                  // ⑫ Favorites (always shown if user is logged in)
                  FavoritesSection(
                    products: controller.favoriteProducts,
                    onSeeAll: () {},
                    onProductTap: (i) => _openProduct(controller.favoriteProducts[i]),
                    onFavoriteToggle: (i) =>
                        controller.toggleFavorite(i, 'favorites'),
                    onAddToCart: (i) => controller.addToCart(controller.favoriteProducts[i]),
                  ),
                  const SizedBox(height: 32),

                  // ─── Section divider ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColor.greyBorder,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            gradient: AppColor.mainGradient,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColor.greyBorder,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ⑬ All Products
                  AllProductsSection(
                    products: controller.allProducts,
                    isLoading: controller.isAllProductsLoading,
                    hasMore: controller.hasMoreProducts,
                    onLoadMore: () => controller.loadAllProducts(),
                    onProductTap: (i) => _openProduct(controller.allProducts[i]),
                    onFavoriteToggle: (i) =>
                        controller.toggleFavorite(i, 'all'),
                    onAddToCart: (i) => controller.addToCart(controller.allProducts[i]),
                  ),

                  // Bottom padding for nav bar
                  const SizedBox(height: 110),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Loading shimmer placeholder ─────────────────────────────────────────────

class _HomeLoadingShimmer extends StatelessWidget {
  const _HomeLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Header placeholder
        _shimmer(height: 30, width: 120, radius: 8),
        const SizedBox(height: 8),
        _shimmer(height: 16, width: 200, radius: 6),
        const SizedBox(height: 12),
        _shimmer(height: 54, radius: 18),
        const SizedBox(height: 24),
        // Banner placeholder
        _shimmer(height: 190, radius: 24),
        const SizedBox(height: 24),
        // Categories row
        Row(
          children: List.generate(
            4,
            (i) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _shimmer(height: 100, width: 78, radius: 20),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Section
        _shimmer(height: 200, radius: 20),
        const SizedBox(height: 24),
        _shimmer(height: 200, radius: 20),
      ],
    );
  }

  Widget _shimmer({
    double? height,
    double? width,
    double radius = 12,
  }) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColor.greyBorder,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
