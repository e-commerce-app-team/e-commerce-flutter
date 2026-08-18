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
  final String imageUrl;
  final String storeName;
  final String storeId;
  final String categoryId;
  final String categoryName;
  final double price;
  final double? salePrice;
  final double rating;
  final int reviewCount;
  final int quantity;
  final bool hasFreeShipping;
  final bool hasWholesalePrice;
  final bool isFavorite;

  const ExploreProductModel({
    required this.id,
    required this.name,
    this.imageUrl = '',
    required this.storeName,
    required this.storeId,
    required this.categoryId,
    this.categoryName = '',
    required this.price,
    this.salePrice,
    this.rating = 0,
    this.reviewCount = 0,
    this.quantity = 0,
    this.hasFreeShipping = false,
    this.hasWholesalePrice = false,
    this.isFavorite = false,
  });

  double get displayPrice => salePrice ?? price;

  bool get hasDiscount => salePrice != null && salePrice! < price;

  int get discountPercent =>
      hasDiscount ? (((price - salePrice!) / price) * 100).round() : 0;

  factory ExploreProductModel.fromJson(Map<String, dynamic> json) {
    final rawPrice = double.tryParse('${json['price'] ?? 0}') ?? 0;
    final rawSalePrice = json['sale_price'] == null
        ? null
        : double.tryParse('${json['sale_price']}');
    final rawOldPrice = json['old_price'] == null
        ? null
        : double.tryParse('${json['old_price']}');
    final effectivePrice = rawSalePrice ?? rawPrice;
    final originalPrice =
        rawOldPrice != null && rawOldPrice > effectivePrice ? rawOldPrice : rawPrice;

    return ExploreProductModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      imageUrl: (json['image'] ?? json['image_url'] ?? '').toString(),
      storeName: json['store_name']?.toString() ?? '',
      storeId: json['store_id']?.toString() ?? '',
      categoryId: (json['category_id'] ?? json['department_id'] ?? '').toString(),
      categoryName: (json['category_name'] ?? json['department_name'] ?? '').toString(),
      price: originalPrice,
      salePrice: originalPrice > effectivePrice ? effectivePrice : null,
      rating: double.tryParse(json['rating'].toString()) ?? 0,
      reviewCount: int.tryParse(json['review_count'].toString()) ?? 0,
      quantity: int.tryParse('${json['quantity'] ?? 0}') ?? 0,
      hasFreeShipping: json['free_shipping'] == true || json['free_shipping'] == 1,
      hasWholesalePrice: json['has_wholesale'] == true || json['has_wholesale'] == 1,
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1,
    );
  }

  ExploreProductModel copyWith({bool? isFavorite}) {
    return ExploreProductModel(
      id: id,
      name: name,
      imageUrl: imageUrl,
      storeName: storeName,
      storeId: storeId,
      categoryId: categoryId,
      categoryName: categoryName,
      price: price,
      salePrice: salePrice,
      rating: rating,
      reviewCount: reviewCount,
      quantity: quantity,
      hasFreeShipping: hasFreeShipping,
      hasWholesalePrice: hasWholesalePrice,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class ExploreStoreModel {
  final String id;
  final String name;
  final String logoUrl;
  final String coverUrl;
  final String categoryId;
  final String category;
  final double rating;
  final int reviewCount;
  final bool isOpen;
  final int productCount;
  final bool isFollowing;
  final double? distance;

  const ExploreStoreModel({
    required this.id,
    required this.name,
    this.logoUrl = '',
    this.coverUrl = '',
    this.categoryId = '',
    required this.category,
    this.rating = 0,
    this.reviewCount = 0,
    this.isOpen = true,
    this.productCount = 0,
    this.isFollowing = false,
    this.distance,
  });

  factory ExploreStoreModel.fromJson(Map<String, dynamic> json) {
    return ExploreStoreModel(
      id: json['id'].toString(),
      name: (json['store_name'] ?? json['name'] ?? '').toString(),
      logoUrl: (json['store_logo'] ?? json['logo_url'] ?? '').toString(),
      coverUrl: (json['store_cover'] ?? json['cover_url'] ?? '').toString(),
      categoryId: (json['category_id'] ?? '').toString(),
      category: (json['category'] ?? json['store_type'] ?? '').toString(),
      rating: double.tryParse(json['rating'].toString()) ?? 0,
      reviewCount: int.tryParse('${json['review_count'] ?? json['reviews_count'] ?? 0}') ?? 0,
      isOpen: json['is_open'] == true || json['is_open'] == 1,
      productCount: int.tryParse('${json['products_count'] ?? json['product_count'] ?? 0}') ?? 0,
      isFollowing: json['is_following'] == true || json['is_following'] == 1,
      distance: json['distance'] == null ? null : double.tryParse('${json['distance']}'),
    );
  }
}
