class AdTypeModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final Map<String, int> pricing;
  final String placement;

  const AdTypeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.pricing,
    required this.placement,
  });

  factory AdTypeModel.fromJson(Map json) {
    Map<String, int> parsedPricing = {};
    if (json['prices'] != null) {
      json['prices'].forEach((key, value) {
        parsedPricing[key.toString()] = int.tryParse(value.toString()) ?? 0;
      });
    }
    return AdTypeModel(
      id: json['type'] ?? '',
      title: json['label'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'star', // fallback icon string
      pricing: parsedPricing,
      placement: json['location'] ?? '',
    );
  }

  static List<AdTypeModel> all() => const [
        AdTypeModel(
          id: 'banner',
          title: 'بانر رئيسي',
          description: 'ظهور في أعلى الشاشة الرئيسية للمشترين',
          icon: 'banner',
          pricing: {'1_day': 3000, '3_days': 8000, '1_week': 15000, '1_month': 50000},
          placement: 'الشاشة الرئيسية',
        ),
        AdTypeModel(
          id: 'product',
          title: 'منتج معزَّز',
          description: 'منتجك يظهر أول نتائج البحث والاستكشاف',
          icon: 'product',
          pricing: {'1_day': 3000, '3_days': 8000, '1_week': 15000, '1_month': 50000},
          placement: 'نتائج البحث والاستكشاف',
        ),
        AdTypeModel(
          id: 'store',
          title: 'متجر مميز',
          description: 'متجرك يظهر في قسم "متاجر مميزة" للمشترين',
          icon: 'store',
          pricing: {'1_day': 4000, '3_days': 10000, '1_week': 20000, '1_month': 60000},
          placement: 'قسم المتاجر المميزة',
        ),
        AdTypeModel(
          id: 'notification',
          title: 'إشعار مُدفوع',
          description: 'إشعار يصل لجميع مستخدمي التطبيق مباشرة',
          icon: 'notification',
          pricing: {'1_day': 15000, '3_days': 35000, '1_week': 60000, '1_month': 180000},
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
        AdDurationOption(key: '1_day', label: 'يوم واحد'),
        AdDurationOption(key: '3_days', label: '3 أيام', popular: true),
        AdDurationOption(key: '1_week', label: 'أسبوع'),
        AdDurationOption(key: '1_month', label: 'شهر'),
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
  final String adType; // backend: type
  final String title;
  final String? description;
  final String? imageUrl;
  final String? link; // backend: link
  final String duration; // backend: duration (e.g. '1_day')
  final double totalCost; // backend: price
  final AdStatus status;
  final String? startsAt; // backend: starts_at
  final String? expiresAt; // backend: expires_at
  final String createdAt;
  final int impressions; // backend: views_count
  final int clicks; // backend: clicks_count
  final String? adminNotes; // backend: admin_notes

  const AdModel({
    required this.id,
    required this.adType,
    required this.title,
    this.description,
    this.imageUrl,
    this.link,
    required this.duration,
    required this.totalCost,
    required this.status,
    this.startsAt,
    this.expiresAt,
    required this.createdAt,
    required this.impressions,
    required this.clicks,
    this.adminNotes,
  });

  double get ctr => impressions > 0 ? (clicks / impressions) * 100 : 0;
  
  String get durationDays => duration;
  String? get rejectionReason => adminNotes;
  String? get startDate => startsAt;
  String? get endDate => expiresAt;

  factory AdModel.fromJson(Map json) => AdModel(
        id: json['id'] ?? 0,
        adType: json['type'] ?? 'banner',
        title: json['title'] ?? '',
        description: json['description'],
        imageUrl: json['image_url'],
        link: json['link'],
        duration: json['duration'] ?? '1_day',
        totalCost: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
        status: AdStatusExt.fromKey(json['status'] ?? 'pending'),
        startsAt: json['starts_at'],
        expiresAt: json['expires_at'],
        createdAt: json['created_at'] ?? '',
        impressions: json['views_count'] ?? 0,
        clicks: json['clicks_count'] ?? 0,
        adminNotes: json['admin_notes'],
      );

  static List<AdModel> mockList() => const [];
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
