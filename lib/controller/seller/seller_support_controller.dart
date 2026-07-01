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

abstract class SellerSupportController extends GetxController {
  void loadTickets();
  void changeFilter(String filter);
  void setFormSubject(String key);
  Future<void> pickAttachment();
  void removeAttachment(int index);
  Future<void> submitTicket();
}

class SellerSupportControllerImp extends SellerSupportController {
  late SellerSupportData supportData;
  MyServices myServices = Get.find();

  String get _token => myServices.sharedPreferences.getString('token') ?? '';
  String get _sellerName {
    final firstName = myServices.sharedPreferences.getString('first_name') ?? '';
    final storeName = myServices.sharedPreferences.getString('store_name') ?? '';
    return storeName.isNotEmpty ? storeName : firstName;
  }

  StatusRequest statusRequest     = StatusRequest.none;
  StatusRequest formStatusRequest = StatusRequest.none;

  List<TicketModel> _allTickets = [];
  String selectedFilter = 'all';

  List<TicketModel> get filteredTickets {
    if (selectedFilter == 'all') return _allTickets;
    return _allTickets.where((t) => t.status == selectedFilter).toList();
  }

  List<TicketModel> get recentTickets => _allTickets.take(3).toList();

  int get openCount    => _allTickets.where((t) => t.isOpen).length;
  int get pendingCount => _allTickets.where((t) => t.isPending).length;
  int get closedCount  => _allTickets.where((t) => t.isClosed).length;
  int get unreadCount  => _allTickets.where((t) => t.hasNewReply).length;

  List<FaqItemModel> faqs = FaqItemModel.all();

  final formKey         = GlobalKey<FormState>();
  final titleCtrl       = TextEditingController();
  final messageCtrl     = TextEditingController();
  String formSubjectKey = '';
  List<File> attachments = [];

  @override
  void onInit() {
    super.onInit();
    supportData = SellerSupportData(Get.find<Crud>());
    loadTickets();
  }

  @override
  void loadTickets() async {
    statusRequest = StatusRequest.loading;
    update();

    final response = await supportData.getTickets(_token);

    response.fold(
      (failure) {
        _allTickets = TicketModel.mockList();
        statusRequest = StatusRequest.success;
        update();
      },
      (data) {
        if (data is List) {
          _allTickets = data.map((e) => TicketModel.fromJson(e)).toList();
        } else if (data['success'] == true && data['data'] is List) {
          _allTickets = (data['data'] as List)
              .map((e) => TicketModel.fromJson(e))
              .toList();
        } else {
          _allTickets = TicketModel.mockList();
        }
        statusRequest = StatusRequest.success;
        update();
      },
    );
  }

  @override
  void changeFilter(String filter) {
    selectedFilter = filter;
    update();
  }

  void prepareNewTicketForm() {
    titleCtrl.clear();
    messageCtrl.clear();
    formSubjectKey = '';
    attachments.clear();
    formStatusRequest = StatusRequest.none;
    update();
  }

  @override
  void setFormSubject(String key) {
    formSubjectKey = key;
    update();
  }

  @override
  Future<void> pickAttachment() async {
    if (attachments.length >= 3) {
      customSnackbar('support_warning'.tr, 'support_max_images'.tr);
      return;
    }
    final source = await showImagePickerBottomSheet();
    if (source == null) return;
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      attachments.add(File(picked.path));
      update();
    }
  }

  @override
  void removeAttachment(int index) {
    attachments.removeAt(index);
    update();
  }

  @override
  Future<void> submitTicket() async {
    if (!formKey.currentState!.validate()) return;
    if (formSubjectKey.isEmpty) {
      customSnackbar('support_warning'.tr, 'ticket_select_subject'.tr);
      return;
    }

    formStatusRequest = StatusRequest.loading;
    update();

    final data = {
      'title':        titleCtrl.text.trim(),
      'subject_type': formSubjectKey,
      'message':      messageCtrl.text.trim(),
    };

    final files = <String, File>{};
    for (int i = 0; i < attachments.length; i++) {
      files['images[$i]'] = attachments[i];
    }

    final response = await supportData.createTicket(
      _token,
      data: data,
      files: files,
    );

    response.fold(
      (failure) {
        formStatusRequest = failure;
        update();
        customSnackbar('support_warning'.tr, 'ticket_create_failed'.tr);
      },
      (data) {
        if (data['success'] == true || data['id'] != null) {
          final newTicket = data['data'] != null
              ? TicketModel.fromJson(data['data'])
              : TicketModel(
                  id: DateTime.now().millisecondsSinceEpoch,
                  ticketNumber: 'TKT-NEW',
                  title: titleCtrl.text.trim(),
                  subjectType: formSubjectKey,
                  status: 'open',
                  lastMessage: messageCtrl.text.trim(),
                  lastMessageAt: 'الآن',
                  createdAt: 'الآن',
                  messagesCount: 1,
                  hasNewReply: false,
                );
          _allTickets.insert(0, newTicket);
          formStatusRequest = StatusRequest.success;
          update();
          Get.back();
          customSnackbar(
            'ticket_created_success'.tr,
            'ticket_created_msg'.tr,
            isError: false,
          );
        } else {
          formStatusRequest = StatusRequest.failure;
          update();
          customSnackbar('support_warning'.tr, data['message'] ?? 'ticket_create_failed'.tr);
        }
      },
    );
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    messageCtrl.dispose();
    super.onClose();
  }
}
