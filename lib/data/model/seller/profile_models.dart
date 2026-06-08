class SellerProfileModel {
  final int    userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? profilePhoto;
  final int    storeId;
  final String storeName;
  final String? description;
  final String? logo;
  final String? cover;
  final String  category;
  final String  city;
  final double? lat;
  final double? lng;
  final String  returnPolicy;
  final String  sellerType;
  final String  status;
  final double  ratingAvg;
  final int     reviewCount;
  final int     followersCount;
  final String? crNumber;
  final String? taxNumber;

  const SellerProfileModel({
    required this.userId, required this.firstName, required this.lastName,
    required this.email, required this.phone, this.profilePhoto,
    required this.storeId, required this.storeName, this.description,
    this.logo, this.cover, required this.category, required this.city,
    this.lat, this.lng, required this.returnPolicy,
    required this.sellerType, required this.status,
    required this.ratingAvg, required this.reviewCount,
    required this.followersCount, this.crNumber, this.taxNumber,
  });

  String get fullName    => '$firstName $lastName';
  bool   get isWholesale => sellerType == 'wholesale';

  factory SellerProfileModel.fromJson(Map json) {
    final u = json['user']  as Map? ?? {};
    final s = json['store'] as Map? ?? {};
    return SellerProfileModel(
      userId: u['id'] ?? 0, firstName: u['first_name'] ?? '',
      lastName: u['last_name'] ?? '', email: u['email'] ?? '',
      phone: u['phone'] ?? '', profilePhoto: u['profile_photo'],
      storeId: s['id'] ?? 0, storeName: s['name'] ?? '',
      description: s['description'], logo: s['logo'], cover: s['cover'],
      category: s['category'] ?? '', city: s['city'] ?? '',
      lat: (s['lat'] as num?)?.toDouble(),
      lng: (s['lng'] as num?)?.toDouble(),
      returnPolicy: s['return_policy'] ?? '',
      sellerType: s['seller_type'] ?? 'vendor',
      status: s['status'] ?? 'active',
      ratingAvg: (s['rating_avg'] as num?)?.toDouble() ?? 0,
      reviewCount: s['review_count'] ?? 0,
      followersCount: s['followers_count'] ?? 0,
      crNumber: s['cr_number'], taxNumber: s['tax_number'],

    );
  }

  static SellerProfileModel mock() => const SellerProfileModel(
    userId: 143, firstName: 'أحمد', lastName: 'حسن',
    email: 'ahmad@mail.com', phone: '0911234567',
    storeId: 55, storeName: 'متجر أحمد للحرف اليدوية',
    description: 'متجر متخصص في الحرف اليدوية والمنتجات الأصيلة',
    category: 'حرف يدوية', city: 'دمشق',
    lat: 33.510, lng: 36.291,
    returnPolicy: '7 أيام للمنتجات المعيبة',
    sellerType: 'wholesale', status: 'active',
    ratingAvg: 4.8, reviewCount: 312, followersCount: 1450,
  );
}

class WalletModel {
  final int    balance;
  final int    heldBalance;
  final String currency;
  final List<WalletTransaction> transactions;

  const WalletModel({
    required this.balance, required this.heldBalance,
    required this.currency, required this.transactions,
  });

  factory WalletModel.fromJson(Map json) => WalletModel(
    balance: json['balance'] ?? 0, heldBalance: json['held_balance'] ?? 0,
    currency: json['currency'] ?? 'SYP',
    transactions: (json['transactions'] as List? ?? [])
        .map((t) => WalletTransaction.fromJson(t)).toList(),
  );

  static WalletModel mock() => const WalletModel(
    balance: 342000, heldBalance: 45000, currency: 'SYP',
    transactions: [
      WalletTransaction(id:1, type:'credit', amount:45000,
          description:'تحرير أموال الطلب #ORD-2844',
          createdAt:'منذ 3 ساعات'),
      WalletTransaction(id:2, type:'debit',  amount:4500,
          description:'عمولة المنصة 10%', createdAt:'منذ 3 ساعات'),
      WalletTransaction(id:3, type:'credit', amount:75000,
          description:'تحرير أموال الطلب #ORD-2840', createdAt:'أمس'),
      WalletTransaction(id:4, type:'debit',  amount:100000,
          description:'سحب إلى الحساب البنكي', createdAt:'منذ يومين'),
    ],
  );
}

class WalletTransaction {
  final int    id;
  final String type;
  final int    amount;
  final String description;
  final String createdAt;

  const WalletTransaction({
    required this.id, required this.type, required this.amount,
    required this.description, required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map json) => WalletTransaction(
    id: json['id'] ?? 0, type: json['type'] ?? 'credit',
    amount: json['amount'] ?? 0, description: json['description'] ?? '',
    createdAt: json['created_at'] ?? '',
  );

  bool get isCredit => type == 'credit' || type == 'release';
}
