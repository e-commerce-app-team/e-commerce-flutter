class NotificationModel {
  final String id;
  final String type;
  final String titleKey;
  final String messageKey;
  final String? titleAr;
  final String? titleEn;
  final String? messageAr;
  final String? messageEn;
  final Map<String, dynamic> params;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.titleKey,
    required this.messageKey,
    this.titleAr,
    this.titleEn,
    this.messageAr,
    this.messageEn,
    this.params = const {},
    this.data = const {},
    required this.isRead,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map raw) {
    final json = Map<String, dynamic>.from(raw);
    Map<String, dynamic> mapValue(dynamic value) =>
        value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
    return NotificationModel(
      id: '${json['id'] ?? ''}',
      type: '${json['type'] ?? ''}',
      titleKey: '${json['title_key'] ?? ''}',
      messageKey: '${json['message_key'] ?? ''}',
      titleAr: json['title_ar']?.toString(),
      titleEn: json['title_en']?.toString(),
      messageAr: json['message_ar']?.toString(),
      messageEn: json['message_en']?.toString(),
      params: mapValue(json['params']),
      data: json,
      isRead: json['is_read'] == true || '${json['is_read']}' == '1',
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}'),
    );
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id: id,
    type: type,
    titleKey: titleKey,
    messageKey: messageKey,
    titleAr: titleAr,
    titleEn: titleEn,
    messageAr: messageAr,
    messageEn: messageEn,
    params: params,
    data: data,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
  );
}
