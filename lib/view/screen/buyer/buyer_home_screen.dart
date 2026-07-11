import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/controller/buyer/buyer_home_controller.dart';
import 'package:e_commerce/view/widget/buyer/home/buyer_home_header.dart';
import 'package:e_commerce/view/widget/buyer/home/hero_banner_carousel.dart';
import 'package:e_commerce/view/widget/buyer/home/categories_bar.dart';
import 'package:e_commerce/view/widget/buyer/home/flash_sale_section.dart';
import 'package:e_commerce/view/widget/buyer/home/featured_stores_section.dart';
import 'package:e_commerce/view/widget/buyer/home/trending_products_section.dart';
import 'package:e_commerce/view/widget/buyer/home/recommended_section.dart';

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
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: BuyerHomeHeader(
                    userName: 'خالد',
                    deliveryLocation: 'دمشق - المزة، شارع الشيخ سعد',
                    notificationCount: 3,
                    cartCount: 2,
                    searchHint: 'search_hint_home'.tr,
                    onNotificationTap: () {},
                    onCartTap: () {},
                    onSearchTap: () {},
                    onLocationTap: () {},
                  ),
                ),
                const SizedBox(height: 22),
                if (controller.banners.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: HeroBannerCarousel(banners: controller.banners),
                  ),
                const SizedBox(height: 26),
                CategoriesBar(
                  categories: controller.categories,
                  selectedId: controller.selectedCategoryId,
                  onSelected: (c) => controller.changeCategory(c.id),
                ),
                const SizedBox(height: 26),
                FlashSaleSection(
                  products: controller.flashSaleProducts,
                  remaining: controller.flashSaleRemaining,
                  onSeeAll: () {},
                  onProductTap: (index) {},
                  onAddToCart: (index) {},
                ),
                const SizedBox(height: 32),
                FeaturedStoresSection(
                  stores: controller.featuredStores,
                  onSeeAll: () {},
                ),
                const SizedBox(height: 32),
                TrendingProductsSection(
                  products: controller.trendingProducts,
                  onSeeAll: () {},
                  onProductTap: (index) {},
                  onFavoriteToggle: (index) => controller.toggleFavorite(index, 'trending'),
                ),
                const SizedBox(height: 32),
                RecommendedSection(
                  products: controller.recommendedProducts,
                  onProductTap: (index) {},
                  onFavoriteToggle: (index) => controller.toggleFavorite(index, 'recommended'),
                ),
                const SizedBox(height: 110),
              ],
            );
          }
        ),
      ),
    );
  }
}
