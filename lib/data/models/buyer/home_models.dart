import 'package:flutter/widgets.dart' show IconData;
import 'package:e_commerce/link_api.dart';

String _buyerImageUrl(dynamic value) {
  final path = value?.toString().trim() ?? '';
  if (path.isEmpty || path.startsWith('http')) return path;
  return AppLink.storageUrl(path.replaceFirst('/storage/', ''));
}

// ─── Banner / Ad ─────────────────────────────────────────────────────────────

class BuyerBannerItem {
  final String? id;
  final String imageUrl;
  final String title;
  final String subtitle;
  final String? badgeLabel;
  final int? sellerId;
  final String? link;

  const BuyerBannerItem({
    this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.badgeLabel,
    this.sellerId,
    this.link,
  });

  factory BuyerBannerItem.fromJson(Map<String, dynamic> json) {
    return BuyerBannerItem(
      id: json['id']?.toString(),
      imageUrl: _buyerImageUrl(json['image'] ?? json['image_url']),
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? json['description'] ?? '',
      badgeLabel: json['badge_label'],
      sellerId: json['seller_id'] is int ? json['seller_id'] : null,
      link: json['link'],
    );
  }
}

// ─── Category ─────────────────────────────────────────────────────────────────

class BuyerCategoryItem {
  final String id;
  final String label;
  final IconData? icon;
  final String? imageUrl;
  final String? colorHex;
  final int? productsCount;

  const BuyerCategoryItem({
    required this.id,
    required this.label,
    this.icon,
    this.imageUrl,
    this.colorHex,
    this.productsCount,
  });

  factory BuyerCategoryItem.fromJson(Map<String, dynamic> json) {
    return BuyerCategoryItem(
      id: json['id']?.toString() ?? '',
      label: json['name'] ?? json['label'] ?? '',
      imageUrl: _buyerImageUrl(json['icon'] ?? json['image_url']),
      colorHex: json['color'],
      productsCount: json['products_count'],
    );
  }
}

// ─── Store ────────────────────────────────────────────────────────────────────

class BuyerStoreItem {
  final String? id;
  final String coverUrl;
  final String logoUrl;
  final String name;
  final String category;
  final double rating;
  final bool isOpen;
  final bool isFeatured;
  final int? productsCount;
  final double? distance; // km, for nearby stores
  final String? adId;

  const BuyerStoreItem({
    this.id,
    required this.coverUrl,
    required this.logoUrl,
    required this.name,
    required this.category,
    required this.rating,
    this.isOpen = true,
    this.isFeatured = false,
    this.productsCount,
    this.distance,
    this.adId,
  });

  factory BuyerStoreItem.fromJson(Map<String, dynamic> json) {
    return BuyerStoreItem(
      id: json['id']?.toString(),
      coverUrl: _buyerImageUrl(json['store_cover'] ?? json['cover_url']),
      logoUrl: _buyerImageUrl(json['store_logo'] ?? json['logo_url']),
      name: json['store_name'] ?? json['name'] ?? '',
      category: json['category'] ?? json['store_type'] ?? '',
      rating: double.tryParse('${json['rating'] ?? 0}') ?? 0,
      isOpen: json['is_open'] == true || json['is_open'] == 1,
      isFeatured: json['is_featured'] == true || json['is_featured'] == 1,
      productsCount: int.tryParse('${json['products_count'] ?? 0}'),
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
      adId: json['ad_id']?.toString(),
    );
  }
}

// ─── Product ──────────────────────────────────────────────────────────────────

class BuyerProductItem {
  final String? id;
  final String imageUrl;
  final String name;
  final num price;
  final num? oldPrice;
  final double rating;
  final int ratingCount;
  final String? badgeLabel;
  final bool isFavorite;
  final String? storeId;
  final String? storeName;
  final String? adId;

  const BuyerProductItem({
    this.id,
    required this.imageUrl,
    required this.name,
    required this.price,
    this.oldPrice,
    this.rating = 0,
    this.ratingCount = 0,
    this.badgeLabel,
    this.isFavorite = false,
    this.storeId,
    this.storeName,
    this.adId,
  });

  double? get discountPercent {
    if (oldPrice == null || oldPrice == 0) return null;
    final diff = (oldPrice! - price) / oldPrice!;
    return diff > 0 ? diff * 100 : null;
  }

  factory BuyerProductItem.fromJson(Map<String, dynamic> json) {
    // Support both sale_price/price pattern and price/old_price pattern
    final rawPrice = num.tryParse('${json['price'] ?? 0}') ?? 0;
    final rawSale = json['sale_price'] == null
        ? null
        : num.tryParse('${json['sale_price']}');
    final rawOld = json['old_price'] == null
        ? null
        : num.tryParse('${json['old_price']}');

    final actualPrice = rawSale ?? rawPrice;
    num? actualOldPrice;
    if (rawSale != null && rawSale < rawPrice) {
      actualOldPrice = rawPrice;
    } else if (rawOld != null) {
      actualOldPrice = rawOld;
    }

    return BuyerProductItem(
      id: json['id']?.toString(),
      imageUrl: _buyerImageUrl(json['image'] ?? json['image_url']),
      name: json['name'] ?? '',
      price: actualPrice,
      oldPrice: actualOldPrice,
      rating: double.tryParse('${json['rating'] ?? 0}') ?? 0,
      ratingCount: int.tryParse(
            '${json['rating_count'] ?? json['reviews_count'] ?? 0}',
          ) ??
          0,
      badgeLabel: json['badge_label'],
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1,
      storeId: json['store_id']?.toString(),
      storeName: json['store_name'],
      adId: json['ad_id']?.toString(),
    );
  }

  BuyerProductItem copyWith({
    String? id,
    String? imageUrl,
    String? name,
    num? price,
    num? oldPrice,
    double? rating,
    int? ratingCount,
    String? badgeLabel,
    bool? isFavorite,
    String? storeId,
    String? storeName,
    String? adId,
  }) {
    return BuyerProductItem(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      badgeLabel: badgeLabel ?? this.badgeLabel,
      isFavorite: isFavorite ?? this.isFavorite,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      adId: adId ?? this.adId,
    );
  }
}
