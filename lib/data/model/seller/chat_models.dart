import 'package:cloud_firestore/cloud_firestore.dart';


class MessageModel {
  final String   id;
  final int      senderId;
  final String   content;
  final String   type;
  final String?  imageUrl;
  final DateTime? readAt;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.type,
    this.imageUrl,
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id:        doc.id,
      senderId:  d['sender_id']  ?? 0,
      content:   d['content']    ?? '',
      type:      d['type']       ?? 'text',
      imageUrl:  d['image_url'],
      readAt:    (d['read_at'] as Timestamp?)?.toDate(),
      createdAt: (d['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap(int senderId, String content, String type) => {
    'sender_id':  senderId,
    'content':    content,
    'type':       type,
    'image_url':  null,
    'read_at':    null,
    'created_at': FieldValue.serverTimestamp(),
  };
}


class ConversationModel {
  final String  id;
  final int     sellerId;
  final int     buyerId;
  final String  buyerName;
  final String? buyerAvatar;
  final String? orderId;
  final String  lastMessage;
  final DateTime lastTime;
  final int     unreadSeller;

  const ConversationModel({
    required this.id,
    required this.sellerId,
    required this.buyerId,
    required this.buyerName,
    this.buyerAvatar,
    this.orderId,
    required this.lastMessage,
    required this.lastTime,
    required this.unreadSeller,
  });

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ConversationModel(
      id:            doc.id,
      sellerId:      d['seller_id']     ?? 0,
      buyerId:       d['buyer_id']      ?? 0,
      buyerName:     d['buyer_name']    ?? '',
      buyerAvatar:   d['buyer_avatar'],
      orderId:       d['order_id'],
      lastMessage:   d['last_message']  ?? '',
      lastTime:      (d['last_time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadSeller:  d['unread_seller'] ?? 0,
    );
  }

  String get avatarInitials {
    final parts = buyerName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return parts[0].isNotEmpty ? parts[0][0] : '?';
  }

  String get formattedTime {
    final now  = DateTime.now();
    final diff = now.difference(lastTime);
    if (diff.inMinutes < 1)  return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes}د';
    if (diff.inHours   < 24) return 'منذ ${diff.inHours}س';
    if (diff.inDays    < 7)  return 'منذ ${diff.inDays}ي';
    return '${lastTime.day}/${lastTime.month}';
  }

  static List<ConversationModel> mockList(int sellerId) => [
    ConversationModel(
      id: 'conv_001', sellerId: sellerId, buyerId: 101,
      buyerName: 'alaa aldoos',
      orderId: '#ORD-2847',
      lastMessage: 'هل المنتج متوفر باللون البني؟',
      lastTime: DateTime.now().subtract(const Duration(minutes: 2)),
      unreadSeller: 2,
    ),
    ConversationModel(
      id: 'conv_002', sellerId: sellerId, buyerId: 102,
      buyerName: ' sdrah safar',
      orderId: '#ORD-2846',
      lastMessage: 'شكراً على التوصيل السريع!',
      lastTime: DateTime.now().subtract(const Duration(minutes: 15)),
      unreadSeller: 0,
    ),
    ConversationModel(
      id: 'conv_003', sellerId: sellerId, buyerId: 103,
      buyerName: 'maream ',
      orderId: null,
      lastMessage: 'متى سيصل طلبي؟',
      lastTime: DateTime.now().subtract(const Duration(hours: 1)),
      unreadSeller: 1,
    ),
    ConversationModel(
      id: 'conv_004', sellerId: sellerId, buyerId: 104,
      buyerName: 'ahmad',
      orderId: null,
      lastMessage: 'ما بحبك',
      lastTime: DateTime.now().subtract(const Duration(hours: 3)),
      unreadSeller: 0,
    ),
    ConversationModel(
      id: 'conv_005', sellerId: sellerId, buyerId: 105,
      buyerName: 'sdrah safar',
      orderId: '#ORD-2843',
      lastMessage:'',
      lastTime: DateTime.now().subtract(const Duration(hours: 5)),
      unreadSeller: 0,
    ),
  ];
}


class QuickReplyModel {
  final int    id;
  final String title;
  final String content;

  const QuickReplyModel({
    required this.id,
    required this.title,
    required this.content,
  });

  factory QuickReplyModel.fromJson(Map json) => QuickReplyModel(
    id:      json['id']      ?? 0,
    title:   json['title']   ?? '',
    content: json['content'] ?? '',
  );

  static List<QuickReplyModel> mockList() => const [
    QuickReplyModel(id:1, title:'طلبك قيد التجهيز',
        content:'طلبك قيد التجهيز وسيصلك خلال 30-60 دقيقة إن شاء الله 🚀'),
    QuickReplyModel(id:2, title:'المنتج متوفر',
        content:'نعم المنتج متوفر حالياً، يمكنك الطلب مباشرة من المتجر 😊'),
    QuickReplyModel(id:3, title:'شكراً لتواصلك',
        content:'شكراً لتواصلك معنا، كيف يمكنني مساعدتك؟'),
    QuickReplyModel(id:4, title:'سياسة الإرجاع',
        content:'يمكن إرجاع المنتج خلال 48 ساعة من الاستلام في حال وجود عيب مصنعي.'),
    QuickReplyModel(id:5, title:'رد الغياب',
        content:'شكراً لتواصلك، نحن خارج أوقات الدوام حالياً. سنرد عليك قريباً ⏰'),
  ];
}


class MockMessages {
  static List<Map<String, dynamic>> forConversation(int sellerId) => [
    {
      'id': 'msg_001', 'sender_id': 101,
      'content': 'السلام عليكم، هل المنتج متوفر باللون البني؟',
      'type': 'text', 'read_at': DateTime.now().subtract(const Duration(minutes: 3)),
      'created_at': DateTime.now().subtract(const Duration(minutes: 4)),
    },
    {
      'id': 'msg_002', 'sender_id': sellerId,
      'content': 'وعليكم السلام! نعم متوفر باللون البني والأسود 😊',
      'type': 'text', 'read_at': DateTime.now().subtract(const Duration(minutes: 2)),
      'created_at': DateTime.now().subtract(const Duration(minutes: 3)),
    },
    {
      'id': 'msg_003', 'sender_id': 101,
      'content': 'ممتاز! ما هي مدة التوصيل؟',
      'type': 'text', 'read_at': null,
      'created_at': DateTime.now().subtract(const Duration(minutes: 2)),
    },
  ];
}
