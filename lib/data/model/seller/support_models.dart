import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class TicketModel {
  final int id;
  final String ticketNumber;
  final String title;
  final String subjectType;
  final String status;
  final String lastMessage;
  final String lastMessageAt;
  final String createdAt;
  final int messagesCount;
  final bool hasNewReply;

  const TicketModel({
    required this.id,
    required this.ticketNumber,
    required this.title,
    required this.subjectType,
    required this.status,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.createdAt,
    required this.messagesCount,
    required this.hasNewReply,
  });

  bool get isOpen    => status == 'open';
  bool get isPending => status == 'pending';
  bool get isClosed  => status == 'closed';

  String get statusLabel {
    switch (status) {
      case 'open':    return 'ticket_status_open'.tr;
      case 'pending': return 'ticket_status_pending'.tr;
      case 'closed':  return 'ticket_status_closed'.tr;
      default:        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'open':    return AppColor.primaryColor;
      case 'pending': return AppColor.warning;
      case 'closed':  return AppColor.success;
      default:        return AppColor.grey;
    }
  }

  Color get statusLightColor {
    switch (status) {
      case 'open':    return AppColor.primarySurface;
      case 'pending': return AppColor.warningLight;
      case 'closed':  return AppColor.successLight;
      default:        return AppColor.secondBackground;
    }
  }

  factory TicketModel.fromJson(Map json) => TicketModel(
    id:            json['id']              ?? 0,
    ticketNumber:  json['ticket_number']   ?? '',
    title:         json['title']           ?? '',
    subjectType:   json['subject_type']    ?? '',
    status:        json['status']          ?? 'open',
    lastMessage:   json['last_message']    ?? '',
    lastMessageAt: json['last_message_at'] ?? '',
    createdAt:     json['created_at']      ?? '',
    messagesCount: json['messages_count']  ?? 0,
    hasNewReply:   json['has_new_reply']   ?? false,
  );

  static List<TicketModel> mockList() => const [
    TicketModel(
      id: 1, ticketNumber: 'TKT-0001',
      title: 'مشكلة في سحب الأرباح',
      subjectType: 'withdrawal', status: 'pending',
      lastMessage: 'تم استلام طلبك وسنتواصل معك قريباً',
      lastMessageAt: 'منذ ساعتين',
      createdAt: '05 يونيو 2025', messagesCount: 4, hasNewReply: true,
    ),
    TicketModel(
      id: 2, ticketNumber: 'TKT-0002',
      title: 'استفسار عن شروط رفع المنتجات',
      subjectType: 'products', status: 'closed',
      lastMessage: 'تم حل المشكلة بنجاح، شكراً لتواصلك',
      lastMessageAt: 'منذ يومين',
      createdAt: '03 يونيو 2025', messagesCount: 5, hasNewReply: false,
    ),
    TicketModel(
      id: 3, ticketNumber: 'TKT-0003',
      title: 'طلب تعديل بيانات المتجر',
      subjectType: 'account', status: 'open',
      lastMessage: 'أحتاج مساعدة في تعديل اسم المتجر',
      lastMessageAt: 'منذ 5 دقائق',
      createdAt: '06 يونيو 2025', messagesCount: 1, hasNewReply: false,
    ),
    TicketModel(
      id: 4, ticketNumber: 'TKT-0004',
      title: 'مشكلة تقنية في واجهة المخزون',
      subjectType: 'technical', status: 'open',
      lastMessage: 'لا أستطيع رفع صور المنتجات',
      lastMessageAt: 'منذ ساعة',
      createdAt: '06 يونيو 2025', messagesCount: 2, hasNewReply: false,
    ),
  ];
}

class TicketMessageModel {
  final int id;
  final String senderName;
  final String senderRole;
  final String message;
  final List<String> attachments;
  final DateTime createdAt;
  final bool isRead;

  const TicketMessageModel({
    required this.id,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.attachments,
    required this.createdAt,
    required this.isRead,
  });

  bool get isFromSeller => senderRole == 'seller';

  String get formattedTime {
    final now  = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1)  return 'الآن';
    if (diff.inMinutes < 60) return '${diff.inMinutes}د';
    if (diff.inHours   < 24) return '${diff.inHours}س';
    return '${createdAt.day}/${createdAt.month}';
  }

  factory TicketMessageModel.fromJson(Map json) => TicketMessageModel(
    id:          json['id']          ?? 0,
    senderName:  json['sender_name'] ?? '',
    senderRole:  json['sender_role'] ?? 'seller',
    message:     json['message']     ?? '',
    attachments: List<String>.from(json['attachments'] ?? []),
    createdAt:   json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
        : DateTime.now(),
    isRead: json['is_read'] ?? false,
  );

  static List<TicketMessageModel> mockMessages(String sellerName) => [
    TicketMessageModel(
      id: 1, senderName: sellerName, senderRole: 'seller',
      message: 'السلام عليكم، أواجه مشكلة في سحب أرباحي منذ 3 أيام ولم تُعالج طلبي بعد',
      attachments: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
    ),
    TicketMessageModel(
      id: 2, senderName: 'فريق الدعم الفني', senderRole: 'support',
      message: 'وعليكم السلام، نعتذر عن هذا التأخير. يرجى مشاركتنا رقم طلب السحب حتى نتمكن من متابعته',
      attachments: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      isRead: true,
    ),
    TicketMessageModel(
      id: 3, senderName: sellerName, senderRole: 'seller',
      message: 'رقم الطلب هو #WD-4821، وتم تقديمه منذ 3 أيام ولا يزال بحالة "قيد المعالجة"',
      attachments: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    TicketMessageModel(
      id: 4, senderName: 'فريق الدعم الفني', senderRole: 'support',
      message: 'تم استلام طلبك ومراجعته، سنتواصل معك خلال 24 ساعة بعد التحقق من البيانات',
      attachments: [],
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      isRead: false,
    ),
  ];
}

class FaqItemModel {
  final String categoryKey;
  final String questionKey;
  final String answerKey;

  const FaqItemModel({
    required this.categoryKey,
    required this.questionKey,
    required this.answerKey,
  });

  String get category => categoryKey.tr;
  String get question => questionKey.tr;
  String get answer   => answerKey.tr;

  static List<FaqItemModel> all() => const [
    FaqItemModel(categoryKey: 'faq_cat_financial', questionKey: 'faq_q1', answerKey: 'faq_a1'),
    FaqItemModel(categoryKey: 'faq_cat_financial', questionKey: 'faq_q2', answerKey: 'faq_a2'),
    FaqItemModel(categoryKey: 'faq_cat_products',  questionKey: 'faq_q3', answerKey: 'faq_a3'),
    FaqItemModel(categoryKey: 'faq_cat_products',  questionKey: 'faq_q4', answerKey: 'faq_a4'),
    FaqItemModel(categoryKey: 'faq_cat_orders',    questionKey: 'faq_q5', answerKey: 'faq_a5'),
    FaqItemModel(categoryKey: 'faq_cat_account',   questionKey: 'faq_q6', answerKey: 'faq_a6'),
  ];
}

class SupportSubjectType {
  final String key;
  final String labelKey;

  const SupportSubjectType({required this.key, required this.labelKey});

  String get label => labelKey.tr;

  static const List<SupportSubjectType> all = [
    SupportSubjectType(key: 'withdrawal', labelKey: 'sub_withdrawal'),
    SupportSubjectType(key: 'products',   labelKey: 'sub_products'),
    SupportSubjectType(key: 'orders',     labelKey: 'sub_orders'),
    SupportSubjectType(key: 'account',    labelKey: 'sub_account'),
    SupportSubjectType(key: 'payments',   labelKey: 'sub_payments'),
    SupportSubjectType(key: 'technical',  labelKey: 'sub_technical'),
    SupportSubjectType(key: 'other',      labelKey: 'sub_other'),
  ];
}
