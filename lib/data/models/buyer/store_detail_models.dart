import 'package:e_commerce/link_api.dart';

num _numValue(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? 0;
  return 0;
}

int _intValue(dynamic value) => _numValue(value).toInt();

double _doubleValue(dynamic value) => _numValue(value).toDouble();

bool _boolValue(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final normalized = value.toLowerCase();
    return normalized == '1' || normalized == 'true' || normalized == 'yes';
  }
  return fallback;
}

String _imageUrl(dynamic value) {
  final raw = value?.toString() ?? '';
  if (raw.isEmpty || raw.startsWith('http')) return raw;
  return AppLink.storageUrl(raw);
}

class BuyerStoreDetailModel {
  final String id;
  final int sellerId;
  final String name;
  final String description;
  final String category;
  final String logoUrl;
  final String coverUrl;
  final String phone;
  final String email;
  final String address;
  final Map<String, String> socialLinks;
  final double rating;
  final int reviewsCount;
  final int followersCount;
  final int productsCount;
  final bool isFollowing;
  final bool isOpen;

  const BuyerStoreDetailModel({
    required this.id,
    required this.sellerId,
    required this.name,
    this.description = '',
    this.category = '',
    this.logoUrl = '',
    this.coverUrl = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.socialLinks = const {},
    this.rating = 0,
    this.reviewsCount = 0,
    this.followersCount = 0,
    this.productsCount = 0,
    this.isFollowing = false,
    this.isOpen = true,
  });

  factory BuyerStoreDetailModel.fromJson(Map<String, dynamic> json) {
    final seller = json['seller'];
    final settings = json['settings'];
    final source = <String, dynamic>{
      ...json,
      if (settings is Map) ...Map<String, dynamic>.from(settings),
    };
    final socialsRaw = source['social_links'] ?? source['socials'];
    final socialLinks = <String, String>{};
    if (socialsRaw is Map) {
      socialsRaw.forEach((key, value) {
        if (value != null && value.toString().trim().isNotEmpty) {
          socialLinks[key.toString()] = value.toString();
        }
      });
    }

    return BuyerStoreDetailModel(
      id: (source['id'] ?? source['store_id'] ?? source['seller_id'] ?? '')
          .toString(),
      sellerId: _intValue(source['seller_id'] ??
          (seller is Map ? seller['id'] : null) ??
          source['merchant_id']),
      name: (source['store_name'] ?? source['name'] ?? '').toString(),
      description:
          (source['description'] ?? source['bio'] ?? source['about'] ?? '')
              .toString(),
      category: (source['category'] ?? source['store_type'] ?? '').toString(),
      logoUrl: _imageUrl(source['store_logo'] ?? source['logo_url'] ?? source['logo']),
      coverUrl:
          _imageUrl(source['store_cover'] ?? source['cover_url'] ?? source['cover']),
      phone: (source['phone'] ?? source['mobile'] ?? '').toString(),
      email: (source['email'] ?? '').toString(),
      address: (source['address'] ?? source['location'] ?? '').toString(),
      socialLinks: socialLinks,
      rating: _doubleValue(source['rating'] ?? source['average_rating']),
      reviewsCount: _intValue(source['reviews_count'] ?? source['rating_count']),
      followersCount: _intValue(source['followers_count']),
      productsCount: _intValue(source['products_count'] ?? source['product_count']),
      isFollowing: _boolValue(source['is_following']),
      isOpen: _boolValue(source['is_open'], fallback: true),
    );
  }

  BuyerStoreDetailModel copyWith({
    bool? isFollowing,
    int? followersCount,
    double? rating,
    int? reviewsCount,
  }) {
    return BuyerStoreDetailModel(
      id: id,
      sellerId: sellerId,
      name: name,
      description: description,
      category: category,
      logoUrl: logoUrl,
      coverUrl: coverUrl,
      phone: phone,
      email: email,
      address: address,
      socialLinks: socialLinks,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      followersCount: followersCount ?? this.followersCount,
      productsCount: productsCount,
      isFollowing: isFollowing ?? this.isFollowing,
      isOpen: isOpen,
    );
  }
}

class BuyerStoreDepartmentModel {
  final int id;
  final String name;
  final int? parentId;
  final int productsCount;
  final bool isVisible;
  final String imageUrl;
  final List<BuyerStoreDepartmentModel> children;

  const BuyerStoreDepartmentModel({
    required this.id,
    required this.name,
    this.parentId,
    this.productsCount = 0,
    this.isVisible = true,
    this.imageUrl = '',
    this.children = const [],
  });

  bool get hasChildren => children.isNotEmpty;

  factory BuyerStoreDepartmentModel.fromJson(Map<String, dynamic> json) {
    final childrenRaw =
        json['recursive_children'] ?? json['recursiveChildren'] ?? json['children'];
    return BuyerStoreDepartmentModel(
      id: _intValue(json['id']),
      name: (json['name'] ?? '').toString(),
      parentId: json['parent_id'] == null ? null : _intValue(json['parent_id']),
      productsCount: _intValue(json['products_count'] ?? json['product_count']),
      isVisible: _boolValue(json['is_visible'], fallback: true),
      imageUrl: _imageUrl(json['image_url'] ?? json['image'] ?? json['icon_url']),
      children: (childrenRaw is List ? childrenRaw : const [])
          .whereType<Map>()
          .map((e) => BuyerStoreDepartmentModel.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList(),
    );
  }
}

class BuyerStoreProductModel {
  final String id;
  final String name;
  final String imageUrl;
  final num price;
  final num? oldPrice;
  final double rating;
  final int ratingCount;
  final int departmentId;
  final int stock;
  final bool isFavorite;
  final bool isFreeShipping;
  final String badgeLabel;

  const BuyerStoreProductModel({
    required this.id,
    required this.name,
    this.imageUrl = '',
    required this.price,
    this.oldPrice,
    this.rating = 0,
    this.ratingCount = 0,
    this.departmentId = 0,
    this.stock = 0,
    this.isFavorite = false,
    this.isFreeShipping = false,
    this.badgeLabel = '',
  });

  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  factory BuyerStoreProductModel.fromJson(Map<String, dynamic> json) {
    final original = _numValue(json['original_price'] ?? json['price']);
    final offer = json['offer_price'] ?? json['sale_price'];
    final price = offer == null ? original : _numValue(offer);
    final oldPrice =
        offer != null && original > price ? original : _numValue(json['old_price']);

    return BuyerStoreProductModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      imageUrl: _imageUrl(json['image'] ??
          json['image_url'] ??
          (json['images'] is List && (json['images'] as List).isNotEmpty
              ? (json['images'] as List).first
              : null)),
      price: price,
      oldPrice: oldPrice > 0 ? oldPrice : null,
      rating: _doubleValue(json['rating'] ?? json['average_rating']),
      ratingCount: _intValue(json['reviews_count'] ?? json['rating_count']),
      departmentId: _intValue(json['department_id'] ?? json['category_id']),
      stock: _intValue(json['quantity'] ?? json['stock']),
      isFavorite: _boolValue(json['is_favorite']),
      isFreeShipping: _boolValue(json['is_free_shipping']),
      badgeLabel: (json['badge_label'] ?? '').toString(),
    );
  }
}

class BuyerStoreReviewModel {
  final String id;
  final String buyerName;
  final double rating;
  final String comment;
  final DateTime? createdAt;

  const BuyerStoreReviewModel({
    required this.id,
    required this.buyerName,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory BuyerStoreReviewModel.fromJson(Map<String, dynamic> json) {
    final buyer = json['buyer'] ?? json['user'];
    return BuyerStoreReviewModel(
      id: (json['id'] ?? '').toString(),
      buyerName: (json['buyer_name'] ??
              json['user_name'] ??
              (buyer is Map ? buyer['name'] : null) ??
              '')
          .toString(),
      rating: _doubleValue(json['rating']),
      comment: (json['comment'] ?? json['review'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
    );
  }
}
