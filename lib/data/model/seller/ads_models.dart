// ─── lib/data/model/seller/ads_models.dart ───────────────────────────────────

class AdTypeModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final Map<String, int> pricing; // duration_key → price SP
  final String placement; // where it appears

  const AdTypeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.pricing,
    required this.placement,
  });

  static List<AdTypeModel> all() => const [
        AdTypeModel(
          id: 'banner',
          title: 'بانر رئيسي',
          description: 'ظهور في أعلى الشاشة الرئيسية للمشترين',
          icon: 'banner',
          pricing: {'1': 5000, '3': 12000, '7': 25000, '30': 80000},
          placement: 'الشاشة الرئيسية',
        ),
        AdTypeModel(
          id: 'product',
          title: 'منتج معزَّز',
          description: 'منتجك يظهر أول نتائج البحث والاستكشاف',
          icon: 'product',
          pricing: {'1': 3000, '3': 8000, '7': 15000, '30': 50000},
          placement: 'نتائج البحث والاستكشاف',
        ),
        AdTypeModel(
          id: 'store',
          title: 'متجر مميز',
          description: 'متجرك يظهر في قسم "متاجر مميزة" للمشترين',
          icon: 'store',
          pricing: {'1': 4000, '3': 10000, '7': 20000, '30': 65000},
          placement: 'قسم المتاجر المميزة',
        ),
        AdTypeModel(
          id: 'notification',
          title: 'إشعار مُدفوع',
          description: 'إشعار يصل لجميع مستخدمي التطبيق مباشرة',
          icon: 'notification',
          pricing: {'1': 15000, '3': 35000, '7': 60000, '30': 180000},
          placement: 'إشعارات التطبيق',
        ),
      ];
}

class AdDurationOption {
  final String key;
  final String label;
  final bool popular;

  const AdDurationOption({
    required this.key,
    required this.label,
    this.popular = false,
  });

  static List<AdDurationOption> all() => const [
        AdDurationOption(key: '1', label: 'يوم واحد'),
        AdDurationOption(key: '3', label: '3 أيام', popular: true),
        AdDurationOption(key: '7', label: 'أسبوع'),
        AdDurationOption(key: '30', label: 'شهر'),
      ];
}

enum AdStatus { pending, active, paused, rejected, expired }

extension AdStatusExt on AdStatus {
  String get label {
    switch (this) {
      case AdStatus.pending:
        return 'قيد المراجعة';
      case AdStatus.active:
        return 'نشط';
      case AdStatus.paused:
        return 'موقوف';
      case AdStatus.rejected:
        return 'مرفوض';
      case AdStatus.expired:
        return 'منتهي';
    }
  }

  String get statusKey {
    switch (this) {
      case AdStatus.pending:
        return 'pending';
      case AdStatus.active:
        return 'active';
      case AdStatus.paused:
        return 'paused';
      case AdStatus.rejected:
        return 'rejected';
      case AdStatus.expired:
        return 'expired';
    }
  }

  static AdStatus fromKey(String key) {
    switch (key) {
      case 'active':
        return AdStatus.active;
      case 'paused':
        return AdStatus.paused;
      case 'rejected':
        return AdStatus.rejected;
      case 'expired':
        return AdStatus.expired;
      default:
        return AdStatus.pending;
    }
  }
}

class AdModel {
  final int id;
  final String adType; // banner / product / store / notification
  final String title;
  final String? description;
  final String? imageUrl;
  final int? linkedProductId;
  final String? linkedProductName;
  final int durationDays;
  final int totalCost;
  final AdStatus status;
  final String startDate;
  final String endDate;
  final String createdAt;
  final int impressions;
  final int clicks;
  final String? rejectionReason;

  const AdModel({
    required this.id,
    required this.adType,
    required this.title,
    this.description,
    this.imageUrl,
    this.linkedProductId,
    this.linkedProductName,
    required this.durationDays,
    required this.totalCost,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.impressions,
    required this.clicks,
    this.rejectionReason,
  });

  double get ctr => impressions > 0 ? (clicks / impressions) * 100 : 0;

  factory AdModel.fromJson(Map json) => AdModel(
        id: json['id'] ?? 0,
        adType: json['ad_type'] ?? 'banner',
        title: json['title'] ?? '',
        description: json['description'],
        imageUrl: json['image_url'],
        linkedProductId: json['linked_product_id'],
        linkedProductName: json['linked_product_name'],
        durationDays: json['duration_days'] ?? 1,
        totalCost: json['total_cost'] ?? 0,
        status: AdStatusExt.fromKey(json['status'] ?? 'pending'),
        startDate: json['start_date'] ?? '',
        endDate: json['end_date'] ?? '',
        createdAt: json['created_at'] ?? '',
        impressions: json['impressions'] ?? 0,
        clicks: json['clicks'] ?? 0,
        rejectionReason: json['rejection_reason'],
      );

  static List<AdModel> mockList() => const [
        AdModel(
          id: 1,
          adType: 'banner',
          title: 'عرض نهاية الموسم — تخفيضات 30%',
          description: 'تخفيضات حصرية على جميع المنتجات اليدوية',
          durationDays: 7,
          totalCost: 25000,
          status: AdStatus.active,
          startDate: '2025-06-01',
          endDate: '2025-06-07',
          createdAt: 'منذ 3 أيام',
          impressions: 4200,
          clicks: 315,
        ),
        AdModel(
          id: 2,
          adType: 'product',
          title: 'حقيبة جلدية يدوية',
          linkedProductId: 1,
          linkedProductName: 'حقيبة جلدية يدوية',
          durationDays: 3,
          totalCost: 8000,
          status: AdStatus.pending,
          startDate: '2025-06-05',
          endDate: '2025-06-07',
          createdAt: 'منذ ساعتين',
          impressions: 0,
          clicks: 0,
        ),
        AdModel(
          id: 3,
          adType: 'store',
          title: 'متجر أحمد للحرف اليدوية',
          durationDays: 30,
          totalCost: 65000,
          status: AdStatus.expired,
          startDate: '2025-05-01',
          endDate: '2025-05-31',
          createdAt: 'منذ شهر',
          impressions: 12500,
          clicks: 890,
        ),
        AdModel(
          id: 4,
          adType: 'notification',
          title: 'تخفيض 20% — لفترة محدودة!',
          description: 'عرض خاص لجميع مستخدمي التطبيق',
          durationDays: 1,
          totalCost: 15000,
          status: AdStatus.rejected,
          startDate: '',
          endDate: '',
          createdAt: 'منذ أسبوع',
          impressions: 0,
          clicks: 0,
          rejectionReason: 'المحتوى لا يتوافق مع سياسة الإعلانات',
        ),
      ];
}

class AdFormData {
  String adType = 'banner';
  String title = '';
  String description = '';
  String durationKey = '3';
  int? linkedProductId;
  String? linkedProductName;
  // image picked from device
}
