import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/color.dart';

class CouponModel {
  final int id;
  final String code;
  final String type;
  final double value;
  final double minOrderAmount; // backend: decimal
  final int? maxUses; // backend: max_uses
  final String usageLimitPerUser; // backend: usage_limit_per_user ('unlimited', 'once')
  final int usedCount;
  final bool isActive; // backend: is_active
  final String? startsAt; // backend: starts_at
  final String? expiresAt; // backend: expires_at
  final bool applyToAllProducts; // backend: apply_to_all_products
  final List<dynamic>? productIds; // backend: product_ids

  const CouponModel({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.minOrderAmount,
    this.maxUses,
    required this.usageLimitPerUser,
    required this.usedCount,
    required this.isActive,
    this.startsAt,
    this.expiresAt,
    required this.applyToAllProducts,
    this.productIds,
  });

  bool get isExpired => false; // We would need current date to check this, simplify for now
  bool get isPaused => !isActive;
  bool get isFullyUsed => maxUses != null && usedCount >= maxUses!;

  double get usageProgress =>
      (maxUses != null && maxUses! > 0)
          ? (usedCount / maxUses!).clamp(0.0, 1.0)
          : 0.0;

  int? get maxUsage => maxUses;
  String? get startDate => startsAt;
  String? get endDate => expiresAt;
  String get appliesTo => applyToAllProducts ? 'all' : 'category';
  String? get categoryName => applyToAllProducts ? 'All Products' : 'Selected Products';

  Color get typeColor {
    switch (type) {
      case 'fixed':         return AppColor.statOrders;
      case 'free_shipping': return AppColor.success;
      default:              return AppColor.primaryColor;
    }
  }

  Color get typeLightColor {
    switch (type) {
      case 'fixed':         return AppColor.statOrdersLight;
      case 'free_shipping': return AppColor.successLight;
      default:              return AppColor.primarySurface;
    }
  }

  Color get statusColor {
    if (isActive) return AppColor.success;
    return AppColor.warning;
  }

  Color get statusLightColor {
    if (isActive) return AppColor.successLight;
    return AppColor.warningLight;
  }

  factory CouponModel.fromJson(Map json) => CouponModel(
    id:              json['id']                          ?? 0,
    code:            json['code']                         ?? '',
    type:            json['type']                         ?? 'percentage',
    value:           double.tryParse(json['value']?.toString() ?? '0') ?? 0,
    minOrderAmount:  double.tryParse(json['min_order_amount']?.toString() ?? '0') ?? 0,
    maxUses:         json['max_uses'],
    usageLimitPerUser: json['usage_limit_per_user']       ?? 'unlimited',
    usedCount:       json['used_count']                   ?? 0,
    isActive:        json['is_active'] == 1 || json['is_active'] == true,
    startsAt:        json['starts_at'],
    expiresAt:       json['expires_at'],
    applyToAllProducts: json['apply_to_all_products'] == 1 || json['apply_to_all_products'] == true,
    productIds:      json['product_ids'],
  );

  CouponModel copyWith({bool? isActive, String? expiresAt}) => CouponModel(
    id: id, code: code, type: type, value: value,
    minOrderAmount: minOrderAmount, maxUses: maxUses,
    usageLimitPerUser: usageLimitPerUser, usedCount: usedCount,
    isActive:   isActive   ?? this.isActive,
    startsAt: startsAt,
    expiresAt:  expiresAt  ?? this.expiresAt,
    applyToAllProducts: applyToAllProducts, productIds: productIds,
  );

  static List<CouponModel> mockList() => const [];
}
