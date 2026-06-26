class StaffPermission {
  static const String viewOrders      = 'view_orders';
  static const String manageInventory = 'manage_inventory';
  static const String viewReports     = 'view_reports';
  static const String chatWithBuyers  = 'chat_with_buyers';

  static const List<String> all = [
    viewOrders,
    manageInventory,
    viewReports,
    chatWithBuyers,
  ];
}

class StaffRole {
  static const String manager   = 'manager';
  static const String support   = 'support';
  static const String warehouse = 'warehouse';

  static const List<String> all = [manager, support, warehouse];
}

class StaffModel {
  final int          id;
  final String       name;
  final String       email;
  final String       role;
  final List<String> permissions;
  final String       status;
  final String       joinedAt;
  final String?      avatar;

  const StaffModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
    required this.status,
    required this.joinedAt,
    this.avatar,
  });

  bool get isActive  => status == 'active';
  bool get isPending => status == 'pending';

  bool hasPermission(String perm) => permissions.contains(perm);

  factory StaffModel.fromJson(Map json) => StaffModel(
        id:          json['id']          ?? 0,
        name:        json['name']        ?? '',
        email:       json['email']       ?? '',
        role:        json['role']        ?? StaffRole.support,
        permissions: List<String>.from(json['permissions'] ?? []),
        status:      json['status']      ?? 'pending',
        joinedAt:    json['joined_at']   ?? '',
        avatar:      json['avatar'],
      );

  Map<String, dynamic> toJson() => {
        'id':          id,
        'name':        name,
        'email':       email,
        'role':        role,
        'permissions': permissions,
        'status':      status,
        'joined_at':   joinedAt,
      };

  StaffModel copyWith({
    String?       name,
    String?       role,
    List<String>? permissions,
    String?       status,
  }) =>
      StaffModel(
        id:          id,
        name:        name        ?? this.name,
        email:       email,
        role:        role        ?? this.role,
        permissions: permissions ?? List.from(this.permissions),
        status:      status      ?? this.status,
        joinedAt:    joinedAt,
        avatar:      avatar,
      );

  static List<StaffModel> mockList() => [
        const StaffModel(
          id: 1,
          name: 'سدرة سفر ',
          email: 'sara@example.com',
          role: StaffRole.manager,
          permissions: [
            StaffPermission.viewOrders,
            StaffPermission.manageInventory,
            StaffPermission.viewReports,
            StaffPermission.chatWithBuyers,
          ],
          status: 'active',
          joinedAt: '01 يناير 2025',
        ),
        const StaffModel(
          id: 2,
          name: 'علاء الدوس ',
          email: 'khalid@example.com',
          role: StaffRole.warehouse,
          permissions: [
            StaffPermission.viewOrders,
            StaffPermission.manageInventory,
          ],
          status: 'active',
          joinedAt: '15 فبراير 2025',
        ),
        const StaffModel(
          id: 3,
          name: 'مريم ',
          email: 'nour@example.com',
          role: StaffRole.support,
          permissions: [
            StaffPermission.viewOrders,
            StaffPermission.chatWithBuyers,
          ],
          status: 'pending',
          joinedAt: '01 يونيو 2025',
        ),
      ];
}
