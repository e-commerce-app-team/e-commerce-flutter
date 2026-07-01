import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/data/model/seller/chat_models.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AutoReplyModel is defined in chat_models.dart

// ─────────────────────────────────────────────────────────────────────────────
// SellerChatController  (قائمة المحادثات)
// ─────────────────────────────────────────────────────────────────────────────
class SellerChatController extends GetxController {

  MyServices myServices = Get.find();

  int get myId =>
      int.tryParse(myServices.sharedPreferences.getString('id') ?? '0') ?? 0;

  StatusRequest statusRequest = StatusRequest.none;
  List<ConversationModel> conversations = [];

  List<ConversationModel> get filteredConversations {
    var list = conversations;
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((c) =>
          c.buyerName.toLowerCase().contains(q) ||
          c.lastMessage.toLowerCase().contains(q)).toList();
    }
    if (filterUnread) {
      list = list.where((c) => c.unreadSeller > 0).toList();
    }
    return list;
  }

  String searchQuery = '';
  bool   filterUnread = false;

  void onSearch(String q) { searchQuery = q.trim(); update(); }
  void clearSearch()       { searchQuery = '';       update(); }
  void toggleFilterUnread(){ filterUnread = !filterUnread; update(); }

  int get totalUnread =>
      conversations.fold(0, (sum, c) => sum + c.unreadSeller);

  // ── Quick Replies ──────────────────────────────────────────────────────────
  List<QuickReplyModel> quickReplies = [];

  Future<void> loadQuickReplies() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getStringList('quick_replies_v1');
    if (raw != null && raw.isNotEmpty) {
      // TODO: parse from JSON when backend is ready
      quickReplies = QuickReplyModel.mockList();
    } else {
      quickReplies = QuickReplyModel.mockList();
    }
    update();
  }

  Future<void> addQuickReply(String title, String content) async {
    final newId = DateTime.now().millisecondsSinceEpoch;
    quickReplies.add(QuickReplyModel(id: newId, title: title, content: content));
    // TODO: POST /api/quick-replies
    update();
  }

  Future<void> updateQuickReply(int id, String title, String content) async {
    final idx = quickReplies.indexWhere((r) => r.id == id);
    if (idx != -1) {
      quickReplies[idx] = QuickReplyModel(id: id, title: title, content: content);
      // TODO: PUT /api/quick-replies/{id}
      update();
    }
  }

  Future<void> deleteQuickReply(int id) async {
    quickReplies.removeWhere((r) => r.id == id);
    // TODO: DELETE /api/quick-replies/{id}
    update();
  }

  // ── Auto Replies ───────────────────────────────────────────────────────────
  List<AutoReplyModel> autoReplies = [];

  Future<void> loadAutoReplies() async {
    // TODO: GET /api/auto-replies
    autoReplies = AutoReplyModel.defaults();
    update();
  }

  Future<void> toggleAutoReply(String id, bool enabled) async {
    final idx = autoReplies.indexWhere((r) => r.id == id);
    if (idx != -1) {
      autoReplies[idx] = autoReplies[idx].copyWith(isEnabled: enabled);
      // TODO: PATCH /api/auto-replies/{id}
      update();
    }
  }

  Future<void> updateAutoReply(AutoReplyModel updated) async {
    final idx = autoReplies.indexWhere((r) => r.id == updated.id);
    if (idx != -1) {
      autoReplies[idx] = updated;
      // TODO: PUT /api/auto-replies/{id}
      update();
    }
  }

  // ── Blocked Users ──────────────────────────────────────────────────────────
  List<int> blockedUserIds = [];

  bool isBlocked(int userId) => blockedUserIds.contains(userId);

  Future<void> blockUser(int userId, String convId) async {
    blockedUserIds.add(userId);
    conversations.removeWhere((c) => c.id == convId);
    // TODO: POST /api/block/{userId}
    update();
  }

  Future<void> unblockUser(int userId) async {
    blockedUserIds.remove(userId);
    // TODO: DELETE /api/block/{userId}
    update();
  }

  // ── Conversations ──────────────────────────────────────────────────────────
  StreamSubscription? _conversationsSub;

  Future<void> loadConversations() async {
    statusRequest = StatusRequest.loading;
    update();

    final firestore = FirebaseFirestore.instance;
    _conversationsSub?.cancel();
    _conversationsSub = firestore
        .collection('conversations')
        .where('seller_id', isEqualTo: myId)
        .orderBy('last_time', descending: true)
        .snapshots()
        .listen((snapshot) {
      conversations = snapshot.docs
          .map((doc) => ConversationModel.fromFirestore(doc))
          .toList();
      statusRequest = StatusRequest.success;
      update();
    }, onError: (e) {
      statusRequest = StatusRequest.failure;
      update();
      print("Error loading conversations: $e");
    });
  }

  Future<void> markAsRead(String convId) async {
    final idx = conversations.indexWhere((c) => c.id == convId);
    if (idx != -1 && conversations[idx].unreadSeller > 0) {
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(convId)
          .update({'unread_seller': 0});
    }
  }

  Future<void> archiveConversation(String convId) async {
    // Optional: add 'is_archived_by_seller': true in Firestore instead of deleting
    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(convId)
        .update({'is_archived_by_seller': true});
  }

  @override
  void onInit() {
    super.onInit();
    loadConversations();
    loadQuickReplies();
    loadAutoReplies();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ChatRoomController  (شاشة المحادثة)
// ─────────────────────────────────────────────────────────────────────────────
class ChatRoomController extends GetxController {

  final ConversationModel conversation;
  ChatRoomController(this.conversation);

  MyServices myServices = Get.find();
  int get myId =>
      int.tryParse(myServices.sharedPreferences.getString('id') ?? '0') ?? 0;

  StreamSubscription? _messagesSub;
  List<MessageModel> messagesList = [];

  Future<void> loadMessages() async {
    final firestore = FirebaseFirestore.instance;
    _messagesSub?.cancel();
    _messagesSub = firestore
        .collection('conversations')
        .doc(conversation.id)
        .collection('messages')
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      messagesList = snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();
      update();
    });
  }

  final messageCtrl     = TextEditingController();
  final scrollCtrl      = ScrollController();
  bool  showQuickReplies = false;
  bool  isTyping         = false;
  Timer? _typingTimer;

  // ── Input ──────────────────────────────────────────────────────────────────
  void onMessageChanged(String v) {
    if (v == '/') {
      showQuickReplies = true;
    } else if (v.isEmpty) {
      showQuickReplies = false;
    }
    isTyping = v.isNotEmpty;
    update();
  }

  void applyQuickReply(QuickReplyModel reply) {
    messageCtrl.text = reply.content;
    showQuickReplies  = false;
    isTyping          = true;
    update();
    messageCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: messageCtrl.text.length));
  }

  void toggleQuickReplies() {
    showQuickReplies = !showQuickReplies;
    update();
  }

  // ── Send ───────────────────────────────────────────────────────────────────
  Future<void> sendMessage() async {
    final text = messageCtrl.text.trim();
    if (text.isEmpty) return;
    messageCtrl.clear();
    showQuickReplies = false;
    isTyping         = false;
    update();

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // 1. Add message
    final msgRef = firestore
        .collection('conversations')
        .doc(conversation.id)
        .collection('messages')
        .doc();

    final newMsg = MessageModel(
      id: msgRef.id,
      senderId: myId,
      content: text,
      type: 'text',
      createdAt: DateTime.now(),
    );
    batch.set(msgRef, newMsg.toMap(myId, text, 'text'));

    // 2. Update conversation last message & unread buyer count
    final convRef = firestore.collection('conversations').doc(conversation.id);
    batch.update(convRef, {
      'last_message': text,
      'last_time': FieldValue.serverTimestamp(),
      'unread_buyer': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<void> sendImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked == null) return;
    
    // Typically you upload to FirebaseStorage here and get the URL.
    // For now, we simulate the firestore write assuming image is uploaded.
    // final imageUrl = await uploadImage(picked.path);
    final String text = '📷 صورة';

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    final msgRef = firestore
        .collection('conversations')
        .doc(conversation.id)
        .collection('messages')
        .doc();

    batch.set(msgRef, {
      'sender_id':  myId,
      'content':    text,
      'type':       'image',
      'image_url':  picked.path, // Should be network URL in real app
      'read_at':    null,
      'created_at': FieldValue.serverTimestamp(),
    });

    final convRef = firestore.collection('conversations').doc(conversation.id);
    batch.update(convRef, {
      'last_message': text,
      'last_time': FieldValue.serverTimestamp(),
      'unread_buyer': FieldValue.increment(1),
    });

    await batch.commit();
  }

  // ── Report ─────────────────────────────────────────────────────────────────
  Future<void> reportUser(String reason) async {
    // TODO: POST /api/reports { buyerId, reason }
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  void onInit() {
    super.onInit();
    loadMessages();
  }

  @override
  void onClose() {
    messageCtrl.dispose();
    scrollCtrl.dispose();
    _typingTimer?.cancel();
    super.onClose();
  }
}
