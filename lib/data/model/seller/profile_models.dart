import 'package:e_commerce/link_api.dart';

/// Model يعكس بيانات /seller/store-settings (GET) الموجود فعلاً على الباك.
/// الحقول مُستخرجة من UserController@getStoreSettings.
class SellerProfileModel {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? profilePhoto;
  final String storeName;
  final String? storeDescription;
  final String? storeLogo;
  final String? storeCoverPhoto;
  final String? storeReturnPolicy; // renamed to avoid conflict with getter
  final String? storeEmail;
  final String? detailedAddress;
  final double? latitude;
  final double? longitude;
  final List<dynamic> workingHours;
  final Map<String, dynamic> socialLinks;

  // ─── حقول محلية مشتقة لتوافق الـ UI القائم ─────────────────────────────
  /// يُحسب من دور المستخدم المحفوظ في SharedPreferences
  final String sellerType;

  /// ثابت - الباك لا يُرجع هذه القيم في store-settings بعد
  final double  ratingAvg      = 0;
  final int     reviewCount    = 0;
  final int     followersCount = 0;

  const SellerProfileModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.profilePhoto,
    required this.storeName,
    this.storeDescription,
    this.storeLogo,
    this.storeCoverPhoto,
    this.storeReturnPolicy,
    this.storeEmail,
    this.detailedAddress,
    this.latitude,
    this.longitude,
    this.workingHours = const [],
    this.socialLinks  = const {},
    this.sellerType   = 'vendor',
  });

  // ─── Getters لتوافق الـ UI القائم ────────────────────────────────────────
  String get fullName      => '$firstName $lastName'.trim();
  String get city          => detailedAddress ?? '';
  String get description   => storeDescription ?? '';
  String get returnPolicy  => storeReturnPolicy ?? '';

  /// Compatibility getters للـ widgets القائمة
  String get category      => ''; // الباك لا يُرجع التصنيف في store-settings
  int    get storeId       => 0;  // الباك لا يُرجع store ID في store-settings
  String? get logo         => storeLogo;
  String? get cover        => storeCoverPhoto;
  String? get crNumber     => null;
  String? get taxNumber    => null;

  // ─── Image URLs ───────────────────────────────────────────────────────────
  String? get logoUrl => (storeLogo != null && storeLogo!.isNotEmpty)
      ? (storeLogo!.startsWith('http') ? storeLogo : AppLink.storageUrl(storeLogo!))
      : null;

  String? get coverUrl => (storeCoverPhoto != null && storeCoverPhoto!.isNotEmpty)
      ? (storeCoverPhoto!.startsWith('http') ? storeCoverPhoto : AppLink.storageUrl(storeCoverPhoto!))
      : null;

  String? get profilePhotoUrl => (profilePhoto != null && profilePhoto!.isNotEmpty)
      ? (profilePhoto!.startsWith('http') ? profilePhoto : AppLink.storageUrl(profilePhoto!))
      : null;

  bool get isWholesale => sellerType == 'wholesale';
  bool get isActive    => true;

  /// يُفسّر الاستجابة القادمة من /seller/store-settings
  /// البنية:  { "success": true, "data": { "first_name": ..., "store_name": ..., ... } }
  factory SellerProfileModel.fromJson(Map json, {String sellerType = 'vendor'}) {
    // البيانات قد تكون مباشرة أو ضمن مفتاح "data"
    final d = (json['data'] as Map?) ?? json;

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    List<dynamic> parseList(dynamic v) {
      if (v == null) return [];
      if (v is List) return v;
      return [];
    }

    Map<String, dynamic> parseMap(dynamic v) {
      if (v == null) return {};
      if (v is Map) return Map<String, dynamic>.from(v);
      return {};
    }

    return SellerProfileModel(
      firstName:         d['first_name']?.toString() ?? '',
      lastName:          d['last_name']?.toString()  ?? '',
      email:             d['email']?.toString()       ?? '',
      phone:             d['phone']?.toString()       ?? '',
      profilePhoto:      d['profile_photo']?.toString(),
      storeName:         d['store_name']?.toString()  ?? '',
      storeDescription:  d['store_description']?.toString(),
      storeLogo:         d['store_logo']?.toString(),
      storeCoverPhoto:   d['store_cover_photo']?.toString(),
      storeReturnPolicy: d['return_policy']?.toString(),
      storeEmail:        d['store_email']?.toString(),
      detailedAddress:   d['detailed_address']?.toString(),
      latitude:          parseDouble(d['latitude']),
      longitude:         parseDouble(d['longitude']),
      workingHours:      parseList(d['working_hours']),
      socialLinks:       parseMap(d['social_links']),
      sellerType:        sellerType,
    );
  }

  SellerProfileModel copyWith({
    String? firstName,
    String? lastName,
    String? storeName,
    String? storeDescription,
    String? detailedAddress,
    String? phone,
    String? storeReturnPolicy,
    String? storeLogo,
    String? storeCoverPhoto,
    String? storeEmail,
  }) => SellerProfileModel(
    firstName:         firstName         ?? this.firstName,
    lastName:          lastName          ?? this.lastName,
    email:             email,
    phone:             phone             ?? this.phone,
    profilePhoto:      profilePhoto,
    storeName:         storeName         ?? this.storeName,
    storeDescription:  storeDescription  ?? this.storeDescription,
    storeLogo:         storeLogo         ?? this.storeLogo,
    storeCoverPhoto:   storeCoverPhoto   ?? this.storeCoverPhoto,
    storeReturnPolicy: storeReturnPolicy ?? this.storeReturnPolicy,
    storeEmail:        storeEmail        ?? this.storeEmail,
    detailedAddress:   detailedAddress   ?? this.detailedAddress,
    latitude:          latitude,
    longitude:         longitude,
    workingHours:      workingHours,
    socialLinks:       socialLinks,
    sellerType:        sellerType,
  );
}
