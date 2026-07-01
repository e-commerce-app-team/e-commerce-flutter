import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/core/functions/show_image_picker.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/data/datasource/remote/seller/seller_support_data.dart';
import 'package:e_commerce/data/model/seller/support_models.dart';

abstract class TicketDetailsController extends GetxController {
  void loadMessages();
  Future<void> sendReply();
  Future<void> pickImage();
  void removeImage();
}

class TicketDetailsControllerImp extends TicketDetailsController {
  final TicketModel ticket;
  TicketDetailsControllerImp(this.ticket);

  late SellerSupportData supportData;
  MyServices myServices = Get.find();

  String get _token => myServices.sharedPreferences.getString('token') ?? '';
  String get _sellerName {
    final storeName = myServices.sharedPreferences.getString('store_name') ?? '';
    final firstName = myServices.sharedPreferences.getString('first_name') ?? '';
    return storeName.isNotEmpty ? storeName : firstName;
  }

  StatusRequest statusRequest     = StatusRequest.none;
  StatusRequest replyStatusRequest = StatusRequest.none;

  List<TicketMessageModel> messages = [];

  final replyCtrl   = TextEditingController();
  final scrollCtrl  = ScrollController();
  File? attachedImage;
  bool isTyping = false;

  @override
  void onInit() {
    super.onInit();
    supportData = SellerSupportData(Get.find<Crud>());
    loadMessages();
  }

  @override
  void loadMessages() async {
    statusRequest = StatusRequest.loading;
    update();

    final response = await supportData.getTicketMessages(_token, ticket.id);

    response.fold(
      (failure) {
        messages = TicketMessageModel.mockMessages(_sellerName);
        statusRequest = StatusRequest.success;
        update();
      },
      (data) {
        if (data['data'] is List) {
          messages = (data['data'] as List)
              .map((e) => TicketMessageModel.fromJson(e))
              .toList();
        } else {
          messages = TicketMessageModel.mockMessages(_sellerName);
        }
        statusRequest = StatusRequest.success;
        update();
        _scrollToBottom();
      },
    );
  }

  void onReplyChanged(String val) {
    isTyping = val.trim().isNotEmpty;
    update();
  }

  @override
  Future<void> pickImage() async {
    final source = await showImagePickerBottomSheet();
    if (source == null) return;
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      attachedImage = File(picked.path);
      update();
    }
  }

  @override
  void removeImage() {
    attachedImage = null;
    update();
  }

  @override
  Future<void> sendReply() async {
    final text = replyCtrl.text.trim();
    if (text.isEmpty && attachedImage == null) return;

    replyStatusRequest = StatusRequest.loading;
    update();

    final data = {'message': text.isNotEmpty ? text : '📷 صورة'};
    final files = <String, File>{};
    if (attachedImage != null) files['image'] = attachedImage!;

    final response = await supportData.replyToTicket(
      _token,
      ticket.id,
      data: data,
      files: files,
    );

    response.fold(
      (failure) {
        replyStatusRequest = failure;
        update();
      },
      (responseData) {
        final localMsg = TicketMessageModel(
          id:          DateTime.now().millisecondsSinceEpoch,
          senderName:  _sellerName,
          senderRole:  'seller',
          message:     text.isNotEmpty ? text : '📷 صورة',
          attachments: attachedImage != null ? [attachedImage!.path] : [],
          createdAt:   DateTime.now(),
          isRead:      false,
        );
        messages.add(localMsg);
        replyCtrl.clear();
        attachedImage = null;
        isTyping = false;
        replyStatusRequest = StatusRequest.success;
        update();
        _scrollToBottom();
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollCtrl.hasClients) {
        scrollCtrl.animateTo(
          scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    replyCtrl.dispose();
    scrollCtrl.dispose();
    super.onClose();
  }
}
