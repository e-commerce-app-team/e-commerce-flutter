import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/data/model/seller/chat_models.dart';
import 'package:e_commerce/core/services/services.dart';
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
  Future<void> loadConversations() async {
    statusRequest = StatusRequest.loading;
    update();
    await Future.delayed(const Duration(milliseconds: 600));
    conversations = ConversationModel.mockList(myId);
    statusRequest = StatusRequest.success;
    update();
  }

  void markAsRead(String convId) {
    final idx = conversations.indexWhere((c) => c.id == convId);
    if (idx != -1 && conversations[idx].unreadSeller > 0) {
      // TODO: Firestore update
      conversations[idx] = ConversationModel(
        id:           conversations[idx].id,
        sellerId:     conversations[idx].sellerId,
        buyerId:      conversations[idx].buyerId,
        buyerName:    conversations[idx].buyerName,
        buyerAvatar:  conversations[idx].buyerAvatar,
        orderId:      conversations[idx].orderId,
        lastMessage:  conversations[idx].lastMessage,
        lastTime:     conversations[idx].lastTime,
        unreadSeller: 0,
      );
      update();
    }
  }

  Future<void> archiveConversation(String convId) async {
    conversations.removeWhere((c) => c.id == convId);
    // TODO: POST /api/conversations/{convId}/archive
    update();
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

  List<Map<String, dynamic>> messages = [];

  Future<void> loadMessages() async {
    await Future.delayed(const Duration(milliseconds: 400));
    messages = MockMessages.forConversation(myId);
    update();
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
    messages.insert(0, {
      'id':         'msg_${DateTime.now().millisecondsSinceEpoch}',
      'sender_id':  myId,
      'content':    text,
      'type':       'text',
      'read_at':    null,
      'created_at': DateTime.now(),
    });
    update();
    // TODO: Firestore write
  }

  Future<void> sendImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked == null) return;
    messages.insert(0, {
      'id':         'img_${DateTime.now().millisecondsSinceEpoch}',
      'sender_id':  myId,
      'content':    '📷 صورة',
      'type':       'image',
      'local_path': picked.path,
      'read_at':    null,
      'created_at': DateTime.now(),
    });
    update();
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
