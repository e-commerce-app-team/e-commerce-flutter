/// Plain display models for the buyer home screen widgets.
///
/// These are intentionally simple data holders with no business logic
/// and no networking. They only describe the *shape* of the data each
/// widget expects, so the real controller/data layer can be wired in
/// later without touching the UI. [IconData] is imported because it is
/// a lightweight value type, not because this pulls in any UI logic.
library home_models;

import 'package:flutter/widgets.dart' show IconData;

class BuyerBannerItem {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String? badgeLabel;

  const BuyerBannerItem({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.badgeLabel,
  });
}

class BuyerCategoryItem {
  final String id;
  final String label;
  final IconData icon;

  const BuyerCategoryItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class BuyerStoreItem {
  final String coverUrl;
  final String logoUrl;
  final String name;
  final String category;
  final double rating;
  final bool isOpen;
  final bool isFeatured;

  const BuyerStoreItem({
    required this.coverUrl,
    required this.logoUrl,
    required this.name,
    required this.category,
    required this.rating,
    this.isOpen = true,
    this.isFeatured = false,
  });
}

class BuyerProductItem {
  final String imageUrl;
  final String name;
  final num price;
  final num? oldPrice;
  final double rating;
  final int ratingCount;
  final String? badgeLabel;
  final bool isFavorite;

  const BuyerProductItem({
    required this.imageUrl,
    required this.name,
    required this.price,
    this.oldPrice,
    this.rating = 0,
    this.ratingCount = 0,
    this.badgeLabel,
    this.isFavorite = false,
  });

  double? get discountPercent {
    if (oldPrice == null || oldPrice == 0) return null;
    final diff = (oldPrice! - price) / oldPrice!;
    return diff > 0 ? diff * 100 : null;
  }

  BuyerProductItem copyWith({
    String? imageUrl,
    String? name,
    num? price,
    num? oldPrice,
    double? rating,
    int? ratingCount,
    String? badgeLabel,
    bool? isFavorite,
  }) {
    return BuyerProductItem(
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      badgeLabel: badgeLabel ?? this.badgeLabel,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
