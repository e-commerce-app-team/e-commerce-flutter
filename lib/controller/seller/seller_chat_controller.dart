import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/data/model/seller/chat_models.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/data/datasource/remote/seller/chat_data.dart';
import 'package:e_commerce/core/services/chat_service.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/data/datasource/remote/notification_data.dart';

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
      list = list
          .where(
            (c) =>
                c.buyerName.toLowerCase().contains(q) ||
                c.lastMessage.toLowerCase().contains(q),
          )
          .toList();
    }
    if (filterUnread) {
      list = list.where((c) => c.unreadSeller > 0).toList();
    }
    return list;
  }

  String searchQuery = '';
  bool filterUnread = false;

  void onSearch(String q) {
    searchQuery = q.trim();
    update();
  }

  void clearSearch() {
    searchQuery = '';
    update();
  }

  void toggleFilterUnread() {
    filterUnread = !filterUnread;
    update();
  }

  int get totalUnread =>
      conversations.fold(0, (sum, c) => sum + c.unreadSeller);

  // ── Quick Replies ──────────────────────────────────────────────────────────
  List<QuickReplyModel> quickReplies = [];

  Future<void> loadQuickReplies() async {
    var response = await chatData.getQuickReplies(_token);
    response.fold(
      (l) {
        quickReplies = QuickReplyModel.mockList();
      },
      (r) {
        if (r['status'] == 'success') {
          List data = r['data'] ?? [];
          quickReplies = data
              .map(
                (e) => QuickReplyModel(
                  id: e['id'],
                  title: e['title'],
                  content: e['content'],
                ),
              )
              .toList();
        } else {
          quickReplies = QuickReplyModel.mockList();
        }
      },
    );
    update();
  }

  Future<void> addQuickReply(String title, String content) async {
    final newId = DateTime.now().millisecondsSinceEpoch;
    quickReplies.add(
      QuickReplyModel(id: newId, title: title, content: content),
    );
    update();
    await chatData.addQuickReply(_token, title, content);
  }

  Future<void> updateQuickReply(int id, String title, String content) async {
    final idx = quickReplies.indexWhere((r) => r.id == id);
    if (idx != -1) {
      quickReplies[idx] = QuickReplyModel(
        id: id,
        title: title,
        content: content,
      );
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
  final Map<int, String> _buyerNames = {};
  Future<void>? _autoRepliesLoad;

  Future<void> loadAutoReplies() async {
    var response = await chatData.getAutoReplies(_token);
    response.fold(
      (l) {
        autoReplies = AutoReplyModel.defaults();
      },
      (r) {
        final rawData = r['data'];
        if (rawData is List) {
          final List data = rawData;
          autoReplies = data
              .map(
                (e) => AutoReplyModel(
                  id: e['id'].toString(),
                  trigger: e['keyword']?.toString().isNotEmpty == true
                      ? e['keyword'].toString()
                      : 'welcome',
                  content: e['message']?.toString() ?? '',
                  isEnabled:
                      e['is_active'] == 1 ||
                      e['is_active'] == true ||
                      e['is_active']?.toString().toLowerCase() == 'true',
                ),
              )
              .toList();
        } else {
          autoReplies = AutoReplyModel.defaults();
        }
      },
    );
    update();
  }

  Future<bool> toggleAutoReply(String id, bool enabled) async {
    final idx = autoReplies.indexWhere((r) => r.id == id);
    if (idx == -1) return false;
    final response = await chatData.toggleAutoReply(_token, id, enabled);
    final success = response.fold(
      (_) => false,
      (data) => (data['_http_status'] is int)
          ? data['_http_status'] >= 200 && data['_http_status'] < 300
          : true,
    );
    if (success) {
      autoReplies[idx] = autoReplies[idx].copyWith(isEnabled: enabled);
      update();
    } else {
      Get.snackbar('error'.tr, 'server_error'.tr);
    }
    return success;
  }

  Future<bool> addAutoReply(String keyword, String message) async {
    final response = await chatData.addAutoReply(_token, keyword, message);
    final success = response.fold(
      (_) => false,
      (data) => (data['_http_status'] is int)
          ? data['_http_status'] >= 200 && data['_http_status'] < 300
          : true,
    );
    if (success) {
      await loadAutoReplies();
    } else {
      Get.snackbar('error'.tr, 'server_error'.tr);
    }
    return success;
  }

  Future<bool> updateAutoReply(AutoReplyModel updated) async {
    final idx = autoReplies.indexWhere((r) => r.id == updated.id);
    if (idx == -1) return false;
    final response = await chatData.updateAutoReply(
      _token,
      updated.id,
      updated.trigger,
      updated.content,
    );
    final success = response.fold(
      (_) => false,
      (data) => (data['_http_status'] is int)
          ? data['_http_status'] >= 200 && data['_http_status'] < 300
          : true,
    );
    if (success) {
      autoReplies[idx] = updated;
      update();
    } else {
      Get.snackbar('error'.tr, 'server_error'.tr);
    }
    return success;
  }

  // ── Blocked Users ──────────────────────────────────────────────────────────
  List<int> blockedUserIds = [];
  List<Map<String, dynamic>> blockedUsers = [];

  bool isBlocked(int userId) => blockedUserIds.contains(userId);

  Future<void> loadBlockedUsers() async {
    var response = await chatData.getBlockedUsers(_token);
    response.fold(
      (l) {
        print("Error loading blocked users: $l");
      },
      (r) {
        List data = r is List ? r : (r['data'] ?? []);
        blockedUsers = List<Map<String, dynamic>>.from(data);
        blockedUserIds = blockedUsers
            .map<int>((e) => int.tryParse(e['blocked_id'].toString()) ?? 0)
            .toList();
        update();
      },
    );
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
  final Map<String, StreamSubscription> _autoReplySubscriptions = {};
  final Set<String> _handledAutoReplyMessages = {};

  Future<void> loadConversations() async {
    statusRequest = StatusRequest.loading;
    update();

    final firestore = FirebaseFirestore.instance;
    _conversationsSub?.cancel();
    _conversationsSub = firestore
        .collection('conversations')
        .where('seller_uid', isEqualTo: myServices.userId)
        .snapshots()
        .listen(
          (snapshot) {
            conversations =
                snapshot.docs
                    .map((doc) => ConversationModel.fromFirestore(doc))
                    .toList()
                  ..sort((a, b) => b.lastTime.compareTo(a.lastTime));
            _resolveMissingBuyerNames();
            statusRequest = StatusRequest.success;
            update();
          },
          onError: (e) {
            statusRequest = StatusRequest.failure;
            update();
            Get.snackbar(
              'Firestore Error',
              e.toString(),
              duration: const Duration(seconds: 5),
            );
            print("Error loading conversations: $e");
          },
        );
  }

  Future<void> _resolveMissingBuyerNames() async {
    final pending = conversations
        .where(
          (c) =>
              c.buyerId > 0 &&
              (!_buyerNames.containsKey(c.buyerId) ||
                  c.buyerName.trim().isEmpty ||
                  c.buyerName.trim().toLowerCase() == 'buyer'),
        )
        .map((c) => c.buyerId)
        .toSet();
    for (final buyerId in pending) {
      final response = await chatData.getChatUser(_token, buyerId);
      response.fold((_) {}, (data) {
        final raw = data['data'] is Map ? data['data'] as Map : data;
        final first = raw['first_name']?.toString().trim() ?? '';
        final last = raw['last_name']?.toString().trim() ?? '';
        final name = '$first $last'.trim();
        if (name.isNotEmpty) _buyerNames[buyerId] = name;
      });
    }
    if (_buyerNames.isNotEmpty) {
      conversations = conversations
          .map(
            (c) => _buyerNames[c.buyerId] == null
                ? c
                : c.copyWith(buyerName: _buyerNames[c.buyerId]),
          )
          .toList();
      update();
    }
  }

  void _watchAutomaticReplies(ConversationModel conversation) {
    if (_autoReplySubscriptions.containsKey(conversation.id)) return;
    var initialSnapshot = true;
    final subscription = FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversation.id)
        .collection('messages')
        .orderBy('created_at')
        .snapshots()
        .listen((snapshot) {
          if (initialSnapshot) {
            _handledAutoReplyMessages.addAll(
              snapshot.docs.map((doc) => doc.id),
            );
            initialSnapshot = false;
            if (conversation.unreadSeller > 0 && snapshot.docs.isNotEmpty) {
              final latest = snapshot.docs.last.data();
              final latestSender =
                  int.tryParse('${latest['sender_id'] ?? 0}') ?? 0;
              if (latestSender == conversation.buyerId) {
                _sendAutomaticReply(conversation, snapshot.docs);
              }
            }
            return;
          }
          for (final change in snapshot.docChanges) {
            if (change.type != DocumentChangeType.added ||
                _handledAutoReplyMessages.contains(change.doc.id)) {
              continue;
            }
            _handledAutoReplyMessages.add(change.doc.id);
            final data = change.doc.data();
            if (data == null) continue;
            final senderId = int.tryParse('${data['sender_id'] ?? 0}') ?? 0;
            if (senderId == conversation.buyerId) {
              _sendAutomaticReply(conversation, snapshot.docs);
            }
          }
        });
    _autoReplySubscriptions[conversation.id] = subscription;
  }

  Future<void> _sendAutomaticReply(
    ConversationModel conversation,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> messages,
  ) async {
    await _autoRepliesLoad;
    final buyerMessages = messages.where((doc) {
      final senderId = int.tryParse('${doc.data()['sender_id'] ?? 0}') ?? 0;
      return senderId == conversation.buyerId;
    }).length;
    AutoReplyModel? reply;
    final buyerMessageDocs = messages
        .where(
          (doc) =>
              int.tryParse('${doc.data()['sender_id'] ?? 0}') ==
              conversation.buyerId,
        )
        .toList();
    final latestBuyerMessage = buyerMessageDocs.isEmpty
        ? null
        : buyerMessageDocs.last.data();
    final latestContent =
        latestBuyerMessage?['content']?.toString().toLowerCase() ?? '';
    for (final candidate in autoReplies) {
      final keyword = candidate.trigger.trim().toLowerCase();
      if (candidate.isEnabled &&
          keyword.isNotEmpty &&
          keyword != 'welcome' &&
          keyword != 'instant_ack' &&
          keyword != 'away' &&
          latestContent.contains(keyword)) {
        reply = candidate;
        break;
      }
    }
    for (final candidate in autoReplies) {
      if (reply == null &&
          candidate.isEnabled &&
          candidate.trigger == 'instant_ack') {
        reply = candidate;
        break;
      }
    }
    if (reply == null && buyerMessages == 1) {
      for (final candidate in autoReplies) {
        if (candidate.isEnabled && candidate.trigger == 'welcome') {
          reply = candidate;
          break;
        }
      }
    }
    if (reply == null) {
      for (final candidate in autoReplies) {
        if (candidate.isEnabled &&
            candidate.trigger != 'welcome' &&
            candidate.trigger != 'instant_ack' &&
            candidate.trigger != 'away') {
          reply = candidate;
          break;
        }
      }
    }
    if (reply == null) return;

    final conversationRef = ChatService.conversationRef(
      sellerId: conversation.sellerId,
      buyerId: conversation.buyerId,
    );
    final messageRef = conversationRef.collection('messages').doc();
    final batch = FirebaseFirestore.instance.batch();
    batch.set(messageRef, {
      'message_id': messageRef.id,
      'sender_id': myId,
      'sender_uid': myId.toString(),
      'receiver_id': conversation.buyerId,
      'receiver_uid': conversation.buyerId.toString(),
      'content': reply.content,
      'type': 'text',
      'image_url': null,
      'read_at': null,
      'created_at': FieldValue.serverTimestamp(),
      'is_automatic_reply': true,
    });
    batch.set(conversationRef, {
      'last_message': reply.content,
      'last_time': FieldValue.serverTimestamp(),
      'unread_buyer': FieldValue.increment(1),
    }, SetOptions(merge: true));
    await batch.commit();
    if (_token.isNotEmpty) {
      await NotificationData(Get.find<Crud>()).sendChatNotification(_token, {
        'recipient_id': conversation.buyerId,
        'conversation_id': conversationRef.id,
        'preview': reply.content,
      });
    }
  }

  @override
  void onClose() {
    _conversationsSub?.cancel();
    for (final subscription in _autoReplySubscriptions.values) {
      subscription.cancel();
    }
    _autoReplySubscriptions.clear();
    super.onClose();
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

  Future<void> signInWithFirebase() async {
    statusRequest = StatusRequest.loading;
    update();
    var response = await chatData.getFirebaseAuthToken(_token);
    response.fold(
      (l) {
        statusRequest = StatusRequest.serverfailure;
        update();
        Get.snackbar('Error', 'Failed to connect to chat server.');
      },
      (r) async {
        if (r['status'] == 'success' || r.containsKey('firebase_token')) {
          try {
            await ChatService.ensureFirebaseAuth(
              token: _token,
              expectedUserId: myServices.userId,
              fetchCustomToken: (token) async =>
                  (r['firebase_token'] ?? r['data']?['firebase_token'])
                      ?.toString(),
            );
            await loadConversations();
          } catch (e) {
            statusRequest = StatusRequest.failure;
            update();
            Get.snackbar(
              'Firebase Auth Error',
              e.toString(),
              duration: const Duration(seconds: 5),
            );
            print("Firebase auth error: $e");
          }
        } else {
          statusRequest = StatusRequest.failure;
          update();
        }
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
    chatData = SellerChatData(Get.find());
    signInWithFirebase();
    loadQuickReplies();
    _autoRepliesLoad = loadAutoReplies();
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

  String get _token => myServices.sharedPreferences.getString('token') ?? '';

  String get conversationId => ChatConversationId.forUsers(
    sellerId: conversation.sellerId,
    buyerId: conversation.buyerId,
  );

  StreamSubscription? _messagesSub;
  List<MessageModel> messagesList = [];

  Future<void> loadMessages() async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('conversations').doc(conversationId).set({
      'unread_seller': 0,
    }, SetOptions(merge: true));
    _messagesSub?.cancel();
    _messagesSub = firestore
        .collection('conversations')
        .doc(conversationId)
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

  final messageCtrl = TextEditingController();
  final scrollCtrl = ScrollController();
  bool showQuickReplies = false;
  bool isTyping = false;
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
    showQuickReplies = false;
    isTyping = true;
    update();
    messageCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: messageCtrl.text.length),
    );
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
    isTyping = false;
    update();

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // 1. Add message
    final msgRef = firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();

    final newMsg = MessageModel(
      id: msgRef.id,
      senderId: myId,
      receiverId: conversation.buyerId,
      content: text,
      type: 'text',
      createdAt: DateTime.now(),
    );
    batch.set(
      msgRef,
      newMsg.toMap(myId, text, 'text', receiverId: conversation.buyerId),
    );

    // 2. Update conversation last message & unread buyer count
    final convRef = firestore.collection('conversations').doc(conversationId);
    batch.set(convRef, {
      'seller_id': conversation.sellerId,
      'seller_uid': conversation.sellerId.toString(),
      'buyer_id': conversation.buyerId,
      'buyer_uid': conversation.buyerId.toString(),
      'last_message': text,
      'last_time': FieldValue.serverTimestamp(),
      'unread_buyer': FieldValue.increment(1),
    }, SetOptions(merge: true));

    await batch.commit();
    if (_token.isNotEmpty) {
      await NotificationData(Get.find<Crud>()).sendChatNotification(_token, {
        'recipient_id': conversation.buyerId,
        'conversation_id': conversationId,
        'preview': text,
      });
    }
  }

  Future<void> sendImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked == null) return;

    // Typically you upload to FirebaseStorage here and get the URL.
    // For now, we simulate the firestore write assuming image is uploaded.
    // final imageUrl = await uploadImage(picked.path);
    final String text = 'image_sent_placeholder'.tr;

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    final msgRef = firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();

    batch.set(msgRef, {
      'message_id': msgRef.id,
      'sender_id': myId,
      'sender_uid': myId.toString(),
      'receiver_id': conversation.buyerId,
      'receiver_uid': conversation.buyerId.toString(),
      'content': text,
      'type': 'image',
      'image_url': picked.path, // Should be network URL in real app
      'read_at': null,
      'created_at': FieldValue.serverTimestamp(),
    });

    final convRef = firestore.collection('conversations').doc(conversationId);
    batch.set(convRef, {
      'seller_id': conversation.sellerId,
      'seller_uid': conversation.sellerId.toString(),
      'buyer_id': conversation.buyerId,
      'buyer_uid': conversation.buyerId.toString(),
      'last_message': text,
      'last_time': FieldValue.serverTimestamp(),
      'unread_buyer': FieldValue.increment(1),
    }, SetOptions(merge: true));

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
