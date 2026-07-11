import 'package:flutter/material.dart';

class ExploreSubCategoryModel {
  final String id;
  final String name;

  const ExploreSubCategoryModel({
    required this.id,
    required this.name,
  });
}

class ExploreCategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final List<ExploreSubCategoryModel> subCategories;

  const ExploreCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.subCategories = const [],
  });
}

class ExploreProductModel {
  final String id;
  final String name;
  final String storeName;
  final String storeId;
  final String categoryId;
  final double price;
  final double? salePrice;
  final double rating;
  final int reviewCount;
  final bool hasFreeShipping;
  final bool hasWholesalePrice;
  final bool isFavorite;

  const ExploreProductModel({
    required this.id,
    required this.name,
    required this.storeName,
    required this.storeId,
    required this.categoryId,
    required this.price,
    this.salePrice,
    this.rating = 0,
    this.reviewCount = 0,
    this.hasFreeShipping = false,
    this.hasWholesalePrice = false,
    this.isFavorite = false,
  });

  double get displayPrice => salePrice ?? price;

  bool get hasDiscount => salePrice != null && salePrice! < price;

  int get discountPercent =>
      hasDiscount ? (((price - salePrice!) / price) * 100).round() : 0;

  factory ExploreProductModel.fromJson(Map<String, dynamic> json) {
    return ExploreProductModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      storeName: json['store_name']?.toString() ?? '',
      storeId: json['store_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      salePrice: json['sale_price'] == null
          ? null
          : double.tryParse(json['sale_price'].toString()),
      rating: double.tryParse(json['rating'].toString()) ?? 0,
      reviewCount: int.tryParse(json['review_count'].toString()) ?? 0,
      hasFreeShipping: json['free_shipping'] == true,
      hasWholesalePrice: json['has_wholesale'] == true,
      isFavorite: json['is_favorite'] == true,
    );
  }

  ExploreProductModel copyWith({bool? isFavorite}) {
    return ExploreProductModel(
      id: id,
      name: name,
      storeName: storeName,
      storeId: storeId,
      categoryId: categoryId,
      price: price,
      salePrice: salePrice,
      rating: rating,
      reviewCount: reviewCount,
      hasFreeShipping: hasFreeShipping,
      hasWholesalePrice: hasWholesalePrice,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class ExploreStoreModel {
  final String id;
  final String name;
  final String category;
  final double rating;
  final int reviewCount;
  final bool isOpen;
  final int productCount;
  final bool isFollowing;

  const ExploreStoreModel({
    required this.id,
    required this.name,
    required this.category,
    this.rating = 0,
    this.reviewCount = 0,
    this.isOpen = true,
    this.productCount = 0,
    this.isFollowing = false,
  });

  factory ExploreStoreModel.fromJson(Map<String, dynamic> json) {
    return ExploreStoreModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      rating: double.tryParse(json['rating'].toString()) ?? 0,
      reviewCount: int.tryParse(json['review_count'].toString()) ?? 0,
      isOpen: json['is_open'] == true,
      productCount: int.tryParse(json['product_count'].toString()) ?? 0,
      isFollowing: json['is_following'] == true,
    );
  }
}
