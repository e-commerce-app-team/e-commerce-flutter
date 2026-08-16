import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/data/model/seller/chat_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuyerChatRoomController extends GetxController {
  BuyerChatRoomController({
    required this.sellerId,
    required this.storeName,
    required this.storeLogo,
    required this.initialBuyerId,
    required this.initialBuyerName,
  });

  final int sellerId;
  final String storeName;
  final String storeLogo;
  final int initialBuyerId;
  final String initialBuyerName;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final List<MessageModel> messages = [];
  StreamSubscription? _messagesSubscription;

  int get buyerId {
    if (initialBuyerId > 0) return initialBuyerId;
    try {
      return int.tryParse(
            Get.find<MyServices>().sharedPreferences.getString('id') ?? '0',
          ) ??
          0;
    } catch (_) {
      return 0;
    }
  }

  String get buyerName {
    if (initialBuyerName.trim().isNotEmpty) return initialBuyerName.trim();
    try {
      final prefs = Get.find<MyServices>().sharedPreferences;
      final first = prefs.getString('first_name') ?? '';
      final last = prefs.getString('last_name') ?? '';
      final name = '$first $last'.trim();
      return name.isNotEmpty ? name : (prefs.getString('name') ?? 'Buyer');
    } catch (_) {
      return 'Buyer';
    }
  }

  String get conversationId => 'buyer_${buyerId}_seller_$sellerId';

  @override
  void onInit() {
    super.onInit();
    _ensureConversation();
    _listenToMessages();
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || buyerId == 0 || sellerId == 0) return;

    messageController.clear();
    final firestore = FirebaseFirestore.instance;
    final conversationRef =
        firestore.collection('conversations').doc(conversationId);
    final messageRef = conversationRef.collection('messages').doc();
    final batch = firestore.batch();

    batch.set(messageRef, {
      'sender_id': buyerId,
      'content': text,
      'type': 'text',
      'image_url': null,
      'read_at': null,
      'created_at': FieldValue.serverTimestamp(),
    });

    batch.set(
      conversationRef,
      {
        'seller_id': sellerId,
        'buyer_id': buyerId,
        'buyer_name': buyerName,
        'store_name': storeName,
        'store_logo': storeLogo,
        'last_message': text,
        'last_time': FieldValue.serverTimestamp(),
        'unread_seller': FieldValue.increment(1),
        'unread_buyer': 0,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<void> _ensureConversation() async {
    if (buyerId == 0 || sellerId == 0) return;
    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .set(
      {
        'seller_id': sellerId,
        'buyer_id': buyerId,
        'buyer_name': buyerName,
        'store_name': storeName,
        'store_logo': storeLogo,
        'last_message': '',
        'last_time': FieldValue.serverTimestamp(),
        'unread_seller': 0,
        'unread_buyer': 0,
      },
      SetOptions(merge: true),
    );
  }

  void _listenToMessages() {
    _messagesSubscription?.cancel();
    _messagesSubscription = FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      messages
        ..clear()
        ..addAll(snapshot.docs.map(MessageModel.fromFirestore));
      update();
    });
  }

  @override
  void onClose() {
    _messagesSubscription?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
