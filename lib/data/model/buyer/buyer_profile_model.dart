class BuyerProfileModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? profilePhotoUrl;
  final String createdAt;
  final int ordersCount;
  final int favoritesCount;
  final int reviewsCount;
  final bool isVip;

  String get fullName => '$firstName $lastName';

  BuyerProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.profilePhotoUrl,
    required this.createdAt,
    required this.ordersCount,
    required this.favoritesCount,
    required this.reviewsCount,
    required this.isVip,
  });

  factory BuyerProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    int asInt(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
    bool asBool(dynamic value) => value == true || value.toString() == '1' || value.toString().toLowerCase() == 'true';
    return BuyerProfileModel(
      id: asInt(data['id']),
      firstName: data['first_name'] ?? '',
      lastName: data['last_name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profilePhotoUrl: data['profile_photo'],
      createdAt: data['created_at'] ?? '',
      ordersCount: asInt(data['orders_count']),
      favoritesCount: asInt(data['favorites_count']),
      reviewsCount: asInt(data['reviews_count']),
      isVip: asBool(data['is_vip']),
    );
  }
}
