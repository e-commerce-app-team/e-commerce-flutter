class WorkingHoursEntry {
  final String dayKey;
  bool   isOpen;
  String openTime;
  String closeTime;

  WorkingHoursEntry({
    required this.dayKey,
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
  });

  WorkingHoursEntry copyWith({
    bool?   isOpen,
    String? openTime,
    String? closeTime,
  }) =>
      WorkingHoursEntry(
        dayKey:    dayKey,
        isOpen:    isOpen    ?? this.isOpen,
        openTime:  openTime  ?? this.openTime,
        closeTime: closeTime ?? this.closeTime,
      );

  factory WorkingHoursEntry.fromJson(Map json) => WorkingHoursEntry(
        dayKey:    json['day_key']    ?? '',
        isOpen:    json['is_open']    ?? true,
        openTime:  json['open_time']  ?? '09:00',
        closeTime: json['close_time'] ?? '21:00',
      );

  Map<String, dynamic> toJson() => {
        'day_key':    dayKey,
        'is_open':    isOpen,
        'open_time':  openTime,
        'close_time': closeTime,
      };
}

class BranchModel {
  final int?    id;
  final String  name;
  final String  address;
  final double? lat;
  final double? lng;
  final String  phone;
  final String  managerName;
  final List<WorkingHoursEntry> workingHours;
  final bool    isActive;
  final int     productCount;
  final String? createdAt;

  const BranchModel({
    this.id,
    required this.name,
    required this.address,
    this.lat,
    this.lng,
    required this.phone,
    required this.managerName,
    required this.workingHours,
    required this.isActive,
    this.productCount = 0,
    this.createdAt,
  });

  bool get hasLocation => lat != null && lng != null;

  BranchModel copyWith({
    int?    id,
    String? name,
    String? address,
    double? lat,
    double? lng,
    String? phone,
    String? managerName,
    List<WorkingHoursEntry>? workingHours,
    bool?   isActive,
    int?    productCount,
  }) =>
      BranchModel(
        id:           id           ?? this.id,
        name:         name         ?? this.name,
        address:      address      ?? this.address,
        lat:          lat          ?? this.lat,
        lng:          lng          ?? this.lng,
        phone:        phone        ?? this.phone,
        managerName:  managerName  ?? this.managerName,
        workingHours: workingHours ?? this.workingHours,
        isActive:     isActive     ?? this.isActive,
        productCount: productCount ?? this.productCount,
        createdAt:    createdAt,
      );

  factory BranchModel.fromJson(Map json) => BranchModel(
        id:           json['id'],
        name:         json['name']          ?? '',
        address:      json['address']       ?? '',
        lat:          json['lat'] != null   ? (json['lat'] as num).toDouble() : null,
        lng:          json['lng'] != null   ? (json['lng'] as num).toDouble() : null,
        phone:        json['phone']         ?? '',
        managerName:  json['manager_name']  ?? '',
        workingHours: (json['working_hours'] as List? ?? [])
            .map((e) => WorkingHoursEntry.fromJson(e))
            .toList(),
        isActive:     json['is_active']     ?? true,
        productCount: json['product_count'] ?? 0,
        createdAt:    json['created_at'],
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name':          name,
        'address':       address,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        'phone':         phone,
        'manager_name':  managerName,
        'working_hours': workingHours.map((e) => e.toJson()).toList(),
        'is_active':     isActive,
      };

  static List<WorkingHoursEntry> defaultWorkingHours() => [
        WorkingHoursEntry(dayKey: 'sunday',    isOpen: true,  openTime: '09:00', closeTime: '21:00'),
        WorkingHoursEntry(dayKey: 'monday',    isOpen: true,  openTime: '09:00', closeTime: '21:00'),
        WorkingHoursEntry(dayKey: 'tuesday',   isOpen: true,  openTime: '09:00', closeTime: '21:00'),
        WorkingHoursEntry(dayKey: 'wednesday', isOpen: true,  openTime: '09:00', closeTime: '21:00'),
        WorkingHoursEntry(dayKey: 'thursday',  isOpen: true,  openTime: '09:00', closeTime: '21:00'),
        WorkingHoursEntry(dayKey: 'friday',    isOpen: false, openTime: '14:00', closeTime: '21:00'),
        WorkingHoursEntry(dayKey: 'saturday',  isOpen: true,  openTime: '10:00', closeTime: '20:00'),
      ];

  static List<BranchModel> mockList() => [
        BranchModel(
          id: 1, name: 'الفرع الرئيسي', address: 'دمشق، المزة، شارع الزهراء',
          lat: 33.5138, lng: 36.2765,
          phone: '0911234567', managerName: 'أحمد محمد',
          workingHours: defaultWorkingHours(),
          isActive: true, productCount: 48, createdAt: '01 يناير 2025',
        ),
        BranchModel(
          id: 2, name: 'فرع الميدان', address: 'دمشق، الميدان، شارع الثلاثين',
          lat: 33.4950, lng: 36.2980,
          phone: '0917654321', managerName: 'سارة علي',
          workingHours: defaultWorkingHours(),
          isActive: true, productCount: 31, createdAt: '15 فبراير 2025',
        ),
        BranchModel(
          id: 3, name: 'مستودع حلب', address: 'حلب، العزيزية',
          lat: 36.2021, lng: 37.1343,
          phone: '0944112233', managerName: 'خالد إبراهيم',
          workingHours: defaultWorkingHours(),
          isActive: false, productCount: 72, createdAt: '10 مارس 2025',
        ),
      ];
}
