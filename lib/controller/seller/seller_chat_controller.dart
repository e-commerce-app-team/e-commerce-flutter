import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/data/model/seller/chat_models.dart';
import 'package:e_commerce/core/services/services.dart';

class SellerChatController extends GetxController {

  MyServices myServices = Get.find();

  int get myId =>
      int.tryParse(myServices.sharedPreferences.getString('id') ?? '0') ?? 0;

  StatusRequest statusRequest = StatusRequest.none;
  List<ConversationModel> conversations = [];
  List<ConversationModel> get filteredConversations {
    if ( searchQuery.isEmpty) return conversations;
    final q =  searchQuery.toLowerCase();
    return conversations.where((c) =>
        c.buyerName.toLowerCase().contains(q) ||
        c.lastMessage.toLowerCase().contains(q)).toList();
  }

  String  searchQuery = '';
  void onSearch(String q) {  searchQuery = q.trim(); update(); }
  void clearSearch()       { searchQuery = '';       update(); }

  int get totalUnread =>
      conversations.fold(0, (sum, c) => sum + c.unreadSeller);

  List<QuickReplyModel> quickReplies = [];

  void loadQuickReplies() {
    // TODO: await API call
    quickReplies = QuickReplyModel.mockList();
    update();
  }



  //
  // FirebaseFirestore.instance
  //   .collection('conversations')
  //   .where('seller_id', isEqualTo: myId)
  //   .orderBy('last_time', descending: true)
  //   .snapshots()
  //   .listen((snap) {
  //     conversations = snap.docs
  //         .map((d) => ConversationModel.fromFirestore(d))
  //         .toList();
  //     update();
  //   });

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
      // TODO: Firestore update: unread_seller = 0
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

  @override
  void onInit() {
    super.onInit();
    loadConversations();
    loadQuickReplies();
  }
}


class ChatRoomController extends GetxController {

  final ConversationModel conversation;
  ChatRoomController(this.conversation);

  MyServices myServices = Get.find();
  int get myId =>
      int.tryParse(myServices.sharedPreferences.getString('id') ?? '0') ?? 0;


  // Stream<QuerySnapshot> get messagesStream =>
  //   FirebaseFirestore.instance
  //     .collection('conversations/${conversation.id}/messages')
  //     .orderBy('created_at', descending: true)
  //     .snapshots();

  List<Map<String, dynamic>> messages = [];

  Future<void> loadMessages() async {
    await Future.delayed(const Duration(milliseconds: 400));
    messages = MockMessages.forConversation(myId);
    update();
  }

  final messageCtrl   = TextEditingController();
  final scrollCtrl    = ScrollController();
  bool  showQuickReplies = false;
  bool  isTyping         = false;
  Timer? _typingTimer;

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

  Future<void> sendMessage() async {
    final text = messageCtrl.text.trim();
    if (text.isEmpty) return;
    messageCtrl.clear();
    showQuickReplies = false;
    isTyping         = false;
    update();

    messages.insert(0, {
      'id':         'msg_${DateTime.now().millisecondsSinceEpoch}',
      'sender_id':  myId,
      'content':    text,
      'type':       'text',
      'read_at':    null,
      'created_at': DateTime.now(),
    });
    update();

    // TODO: Firestore
    // await FirebaseFirestore.instance
    //   .collection('conversations/${conversation.id}/messages')
    //   .add({
    //     'sender_id':  myId,
    //     'content':    text,
    //     'type':       'text',
    //     'read_at':    null,
    //     'created_at': FieldValue.serverTimestamp(),
    //   });
    // await FirebaseFirestore.instance
    //   .collection('conversations')
    //   .doc(conversation.id)
    //   .update({
    //     'last_message':  text,
    //     'last_time':     FieldValue.serverTimestamp(),
    //     'unread_buyer':  FieldValue.increment(1),
    //   });
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
    //  Upload to storage then Firestore
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
