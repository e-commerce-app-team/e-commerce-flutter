import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_inventory_controller.dart';
import 'package:e_commerce/data/model/seller/inventory_models.dart';
import 'package:e_commerce/view/screen/seller/inventory/add_edit_product_screen.dart';
import 'package:e_commerce/view/widget/seller/inventory/product_card.dart';

class ProductSliverList extends StatelessWidget {
  final SellerInventoryController ctrl;
  const ProductSliverList({super.key, required this.ctrl});

  void _goEdit(ProductModel p) {
    ctrl.prepareEditForm(p);
    Get.to(() => const AddEditProductScreen(), transition: Transition.cupertino);
  }

  @override
  Widget build(BuildContext context) {
    final products = ctrl.displayedProducts;

    if (ctrl.isGridView) {
      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
              (_, i) => ProductGridCard(
            product: products[i],
            index: i,
            onEdit: () => _goEdit(products[i]),
            onToggleStatus: () => ctrl.toggleProductStatus(products[i]),
            onDelete: () => ctrl.deleteProduct(products[i]),
          ),
          childCount: products.length,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (_, i) => ProductListCard(
          product: products[i],
          index: i,
          onEdit: () => _goEdit(products[i]),
          onToggleStatus: () => ctrl.toggleProductStatus(products[i]),
          onDelete: () => ctrl.deleteProduct(products[i]),
        ),
        childCount: products.length,
      ),
    );
  }
}



