import 'package:flutter/material.dart';

import 'widgets/store_header.dart';
import 'widgets/store_info.dart';
import 'widgets/store_categories.dart';
import 'widgets/store_products_grid.dart';
import 'widgets/store_reviews.dart';

class BuyerStoreDetailsScreen extends StatelessWidget {
  const BuyerStoreDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: const [
              StoreHeader(),

              SizedBox(height: 16),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: StoreInfo(),
              ),

              SizedBox(height: 20),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: StoreCategories(),
              ),

              SizedBox(height: 20),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: StoreProductsGrid(),
              ),

              SizedBox(height: 20),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: StoreReviews(),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}