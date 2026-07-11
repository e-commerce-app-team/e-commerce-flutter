import 'package:flutter/material.dart';

import 'widgets/explore_search_bar.dart';
import 'widgets/filter_section.dart';
import 'widgets/category_chips.dart';
import 'widgets/stores_grid.dart';
import 'widgets/products_grid.dart';

class BuyerExploreScreen extends StatelessWidget {
  const BuyerExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExploreSearchBar(),

                SizedBox(height: 16),

                FilterSection(),

                SizedBox(height: 16),

                CategoryChips(),

                SizedBox(height: 20),

                StoresGrid(),

                SizedBox(height: 20),

                ProductsGrid(),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}