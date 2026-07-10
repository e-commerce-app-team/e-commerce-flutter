import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/data/model/seller/chat_models.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_commerce/data/datasource/remote/seller/chat_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AutoReplyModel is defined in chat_models.dart

// ─────────────────────────────────────────────────────────────────────────────
// SellerChatController  (قائمة المحادثات)
// ─────────────────────────────────────────────────────────────────────────────
class SellerChatController extends GetxController {

  MyServices myServices = Get.find();
  late SellerChatData chatData;

  int get myId =>
      int.tryParse(myServices.sharedPreferences.getString('id') ?? '0') ?? 0;

  String get _token => myServices.sharedPreferences.getString('token') ?? '';

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
    var response = await chatData.getQuickReplies(_token);
    response.fold((l) {
      quickReplies = QuickReplyModel.mockList();
    }, (r) {
      if (r['status'] == 'success') {
        List data = r['data'] ?? [];
        quickReplies = data.map((e) => QuickReplyModel(id: e['id'], title: e['title'], content: e['content'])).toList();
      } else {
        quickReplies = QuickReplyModel.mockList();
      }
    });
    update();
  }

  Future<void> addQuickReply(String title, String content) async {
    final newId = DateTime.now().millisecondsSinceEpoch;
    quickReplies.add(QuickReplyModel(id: newId, title: title, content: content));
    update();
    await chatData.addQuickReply(_token, title, content);
  }

  Future<void> updateQuickReply(int id, String title, String content) async {
    final idx = quickReplies.indexWhere((r) => r.id == id);
    if (idx != -1) {
      quickReplies[idx] = QuickReplyModel(id: id, title: title, content: content);
      update();
      await chatData.updateQuickReply(_token, id, title, content);
    }
  }

  Future<void> deleteQuickReply(int id) async {
    quickReplies.removeWhere((r) => r.id == id);
    update();
    await chatData.deleteQuickReply(_token, id);
  }

  // ── Auto Replies ───────────────────────────────────────────────────────────
  List<AutoReplyModel> autoReplies = [];

  Future<void> loadAutoReplies() async {
    var response = await chatData.getAutoReplies(_token);
    response.fold((l) {
      autoReplies = AutoReplyModel.defaults();
    }, (r) {
      if (r['status'] == 'success') {
        List data = r['data'] ?? [];
        autoReplies = data.map((e) => AutoReplyModel(id: e['id'].toString(), trigger: e['keyword'] ?? 'welcome', content: e['message'] ?? '', isEnabled: e['is_active'] == 1 || e['is_active'] == true)).toList();
      } else {
        autoReplies = AutoReplyModel.defaults();
      }
    });
    update();
  }

  Future<void> toggleAutoReply(String id, bool enabled) async {
    final idx = autoReplies.indexWhere((r) => r.id == id);
    if (idx != -1) {
      autoReplies[idx] = autoReplies[idx].copyWith(isEnabled: enabled);
      update();
      await chatData.toggleAutoReply(_token, id, enabled);
    }
  }

  Future<void> updateAutoReply(AutoReplyModel updated) async {
    final idx = autoReplies.indexWhere((r) => r.id == updated.id);
    if (idx != -1) {
      autoReplies[idx] = updated;
      update();
      await chatData.updateAutoReply(_token, updated.id, updated.trigger, updated.content);
    }
  }

  // ── Blocked Users ──────────────────────────────────────────────────────────
  List<int> blockedUserIds = [];
  List<Map<String, dynamic>> blockedUsers = [];

  bool isBlocked(int userId) => blockedUserIds.contains(userId);

  Future<void> loadBlockedUsers() async {
    var response = await chatData.getBlockedUsers(_token);
    response.fold((l) {
      print("Error loading blocked users: $l");
    }, (r) {
      List data = r is List ? r : (r['data'] ?? []);
      blockedUsers = List<Map<String, dynamic>>.from(data);
      blockedUserIds = blockedUsers
          .map<int>((e) => int.tryParse(e['blocked_id'].toString()) ?? 0)
          .toList();
      update();
    });
  }

  Future<void> blockUser(int userId, String convId) async {
    blockedUserIds.add(userId);
    conversations.removeWhere((c) => c.id == convId);
    update();
    await chatData.blockUser(_token, userId);
    await loadBlockedUsers();
  }

  Future<void> unblockUser(int userId) async {
    blockedUserIds.remove(userId);
    update();
    await chatData.unblockUser(_token, userId);
    await loadBlockedUsers();
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
      Get.snackbar('Firestore Error', e.toString(), duration: const Duration(seconds: 5));
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

  Future<void> simulateBuyerMessage() async {
    try {
      final firestore = FirebaseFirestore.instance;
      String convId = 'test_conv_$myId';
      
      // Create or update conversation document
      await firestore.collection('conversations').doc(convId).set({
        'seller_id': myId,
        'buyer_id': 999,
        'buyer_name': 'مشتري تجريبي (Test)',
        'last_message': 'مرحباً، هل يمكنني الاستفسار عن هذا المنتج؟',
        'last_time': FieldValue.serverTimestamp(),
        'unread_seller': FieldValue.increment(1),
        'unread_buyer': 0,
      }, SetOptions(merge: true));

      // Add a message from the buyer
      await firestore.collection('conversations').doc(convId).collection('messages').add({
        'sender_id': 999,
        'content': 'مرحباً، هل يمكنني الاستفسار عن هذا المنتج؟',
        'type': 'text',
        'created_at': FieldValue.serverTimestamp(),
      });
      
      Get.snackbar('نجاح', 'تمت محاكاة رسالة المشتري بنجاح!', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Firestore Error', e.toString(), duration: const Duration(seconds: 5), backgroundColor: Colors.red, colorText: Colors.white);
      print("Simulation error: $e");
    }
  }

  Future<void> archiveConversation(String convId) async {
    // Optional: add 'is_archived_by_seller': true in Firestore instead of deleting
    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(convId)
        .update({'is_archived_by_seller': true});
  }

  Future<void> signInWithFirebase() async {
    statusRequest = StatusRequest.loading;
    update();
    var response = await chatData.getFirebaseAuthToken(_token);
    response.fold((l) {
      statusRequest = StatusRequest.serverfailure;
      update();
      Get.snackbar('Error', 'Failed to connect to chat server.');
    }, (r) async {
      if (r['status'] == 'success' || r.containsKey('firebase_token')) {
        String firebaseToken = r['firebase_token'] ?? r['data']?['firebase_token'] ?? '';
        if (firebaseToken.isNotEmpty) {
          try {
            await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
            loadConversations();
          } catch (e) {
            statusRequest = StatusRequest.failure;
            update();
            Get.snackbar('Firebase Auth Error', e.toString(), duration: const Duration(seconds: 5));
            print("Firebase auth error: $e");
          }
        } else {
          statusRequest = StatusRequest.failure;
          update();
        }
      } else {
        statusRequest = StatusRequest.failure;
        update();
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    chatData = SellerChatData(Get.find());
    signInWithFirebase();
    loadQuickReplies();
    loadAutoReplies();
    loadBlockedUsers();
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
    final String text = 'image_sent_placeholder'.tr;

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
    final chatData = Get.find<SellerChatController>().chatData;
    final token = Get.find<SellerChatController>()._token;
    await chatData.reportUser(token, conversation.buyerId, reason);
    Get.snackbar('report_submitted'.tr, 'report_submitted_msg'.tr);
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
