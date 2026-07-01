import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/color.dart';

class CouponModel {
  final int id;
  final String code;
  final String type;
  final double value;
  final int minOrderAmount;
  final int? maxUsage;
  final int maxUsagePerUser;
  final int usedCount;
  final String status;
  final String startDate;
  final String endDate;
  final String appliesTo;
  final int? categoryId;
  final String? categoryName;

  const CouponModel({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.minOrderAmount,
    this.maxUsage,
    required this.maxUsagePerUser,
    required this.usedCount,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.appliesTo,
    this.categoryId,
    this.categoryName,
  });

  bool get isActive    => status == 'active';
  bool get isExpired   => status == 'expired';
  bool get isPaused    => status == 'paused';
  bool get isFullyUsed => maxUsage != null && usedCount >= maxUsage!;

  double get usageProgress =>
      (maxUsage != null && maxUsage! > 0)
          ? (usedCount / maxUsage!).clamp(0.0, 1.0)
          : 0.0;

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
    switch (status) {
      case 'active':  return AppColor.success;
      case 'paused':  return AppColor.warning;
      default:        return AppColor.greyLight;
    }
  }

  Color get statusLightColor {
    switch (status) {
      case 'active':  return AppColor.successLight;
      case 'paused':  return AppColor.warningLight;
      default:        return AppColor.greyBorder;
    }
  }

  factory CouponModel.fromJson(Map json) => CouponModel(
    id:              json['id']                          ?? 0,
    code:            json['code']                         ?? '',
    type:            json['type']                         ?? 'percentage',
    value:           (json['value'] as num?)?.toDouble()  ?? 0,
    minOrderAmount:  json['min_order_amount']             ?? 0,
    maxUsage:        json['max_usage'],
    maxUsagePerUser: json['max_usage_per_user']           ?? 1,
    usedCount:       json['used_count']                   ?? 0,
    status:          json['status']                       ?? 'active',
    startDate:       json['start_date']                   ?? '',
    endDate:         json['end_date']                     ?? '',
    appliesTo:       json['applies_to']                   ?? 'all',
    categoryId:      json['category_id'],
    categoryName:    json['category_name'],
  );

  CouponModel copyWith({String? status, String? endDate}) => CouponModel(
    id: id, code: code, type: type, value: value,
    minOrderAmount: minOrderAmount, maxUsage: maxUsage,
    maxUsagePerUser: maxUsagePerUser, usedCount: usedCount,
    status:   status   ?? this.status,
    startDate: startDate,
    endDate:  endDate  ?? this.endDate,
    appliesTo: appliesTo, categoryId: categoryId, categoryName: categoryName,
  );

  static List<CouponModel> mockList() => const [
    CouponModel(id:1, code:'SUMMER25',   type:'percentage',    value:25,    minOrderAmount:50000, maxUsage:100,  maxUsagePerUser:1, usedCount:67,  status:'active',  startDate:'2025-06-01', endDate:'2025-08-31', appliesTo:'all'),
    CouponModel(id:2, code:'WELCOME10K', type:'fixed',         value:10000, minOrderAmount:30000, maxUsage:50,   maxUsagePerUser:1, usedCount:50,  status:'expired', startDate:'2025-01-01', endDate:'2025-05-31', appliesTo:'all'),
    CouponModel(id:3, code:'FREESHIP',   type:'free_shipping', value:0,     minOrderAmount:20000, maxUsage:null, maxUsagePerUser:3, usedCount:145, status:'active',  startDate:'2025-06-01', endDate:'2025-12-31', appliesTo:'all'),
    CouponModel(id:4, code:'DECO20',     type:'percentage',    value:20,    minOrderAmount:0,     maxUsage:30,   maxUsagePerUser:1, usedCount:12,  status:'paused',  startDate:'2025-04-01', endDate:'2025-09-30', appliesTo:'category', categoryId:2, categoryName:'ديكور المنزل'),
    CouponModel(id:5, code:'VIP5000',    type:'fixed',         value:5000,  minOrderAmount:25000, maxUsage:200,  maxUsagePerUser:2, usedCount:89,  status:'active',  startDate:'2025-05-01', endDate:'2025-11-30', appliesTo:'all'),
  ];
}
