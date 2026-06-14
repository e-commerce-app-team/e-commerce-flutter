import 'package:flutter/material.dart';
import 'widgets/home_header.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/home_banner_slider.dart';
import 'widgets/top_stores_section.dart';
import 'widgets/categories_section.dart';
import 'widgets/recommended_stores_section.dart';
import 'widgets/flash_sales_section.dart';
import 'widgets/trending_products_section.dart';
import 'widgets/nearby_stores_section.dart';

class BuyerHomeScreen extends StatelessWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: SingleChildScrollView(
            child: Column(
            children: [
              HomeHeader(),

              SizedBox(height: 12),



            SizedBox(height: 20),

            HomeSearchBar(),

            SizedBox(height: 20),

            HomeBannerSlider(),

              SizedBox(height: 16),

              TopStoresSection(),
              SizedBox(height: 16),

              CategoriesSection(),
              const SizedBox(height: 16),

              RecommendedStoresSection(),
              const SizedBox(height: 16),

              FlashSalesSection(),

              const SizedBox(height: 16),
              TrendingProductsSection(),

              const SizedBox(height: 16),

              NearbyStoresSection(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      ),
    );

  }
}