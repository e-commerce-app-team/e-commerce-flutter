import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_inventory_controller.dart';
import 'package:e_commerce/data/model/seller/inventory_models.dart';
import 'package:e_commerce/view/screen/seller/inventory/add_edit_product_screen.dart';
import 'package:e_commerce/view/widget/seller/inventory/product_card.dart';

class ProductList extends StatelessWidget {
  final SellerInventoryController ctrl;
  const ProductList({super.key, required this.ctrl});


  void _goToEdit(ProductModel product) {
    ctrl.prepareEditForm(product);
    Get.to(() => const AddEditProductScreen(), transition: Transition.cupertino);
  }

  @override
  Widget build(BuildContext context) {
    final products = ctrl.displayedProducts;

    if (ctrl.isGridView) {
      return GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:  2,
          crossAxisSpacing: 12,
          mainAxisSpacing:  12,
          childAspectRatio: 0.72,
        ),
        itemCount: products.length,
        itemBuilder: (_, i) => ProductGridCard(
          product: products[i],
          index:   i,
          onEdit:         () => _goToEdit(products[i]),
          onToggleStatus: () => ctrl.toggleProductStatus(products[i]),
          onDelete:       () => ctrl.deleteProduct(products[i]),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      itemCount: products.length,
      itemBuilder: (_, i) => ProductListCard(
        product: products[i],
        index:   i,
        onEdit:         () => _goToEdit(products[i]),
        onToggleStatus: () => ctrl.toggleProductStatus(products[i]),
        onDelete:       () => ctrl.deleteProduct(products[i]),
      ),
    );
  }
}