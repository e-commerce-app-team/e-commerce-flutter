import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/data/datasource/remote/auth/staff_invite_data.dart';

class StaffAcceptInviteController extends GetxController {
  late final StaffInviteData inviteData;
  final MyServices myServices = Get.find();

  StatusRequest statusRequest = StatusRequest.none;

  final formKey           = GlobalKey<FormState>();
  final firstNameCtrl     = TextEditingController();
  final lastNameCtrl      = TextEditingController();
  final passwordCtrl      = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  bool isPasswordHidden        = true;
  bool isConfirmPasswordHidden = true;

  // The invitation token extracted from the deep link / route arguments
  String invitationToken = '';

  // Optional: store name shown on the accept page (passed from route args)
  String storeName = '';

  @override
  void onInit() {
    super.onInit();
    inviteData = StaffInviteData(Get.find<Crud>());

    // Extract token and optional store name from navigation arguments
    final args = Get.arguments;
    if (args is Map) {
      invitationToken = args['token']?.toString() ?? '';
      storeName       = args['store_name']?.toString() ?? '';
    } else if (args is String) {
      invitationToken = args;
    }
  }

  void togglePassword() {
    isPasswordHidden = !isPasswordHidden;
    update();
  }

  void toggleConfirmPassword() {
    isConfirmPasswordHidden = !isConfirmPasswordHidden;
    update();
  }

  Future<void> submitAcceptInvite() async {
    if (!formKey.currentState!.validate()) return;
    if (invitationToken.isEmpty) {
      customSnackbar(
        'staff_warning'.tr,
        'staff_invite_token_invalid'.tr,
      );
      return;
    }

    statusRequest = StatusRequest.loading;
    update();

    final response = await inviteData.acceptInvite(
      invitationToken:      invitationToken,
      firstName:            firstNameCtrl.text.trim(),
      lastName:             lastNameCtrl.text.trim(),
      password:             passwordCtrl.text.trim(),
      passwordConfirmation: confirmPasswordCtrl.text.trim(),
    );

    response.fold(
      (failure) {
        statusRequest = failure;
        update();
        customSnackbar('staff_warning'.tr, 'staff_invite_accept_failed'.tr);
      },
      (data) async {
        if (data['success'] == true) {
          // Save session data — same as regular login
          final user = data['user'];
          myServices.sharedPreferences.setString('id',    user['id'].toString());
          myServices.sharedPreferences.setString('role',  user['role'] ?? 'staff');
          myServices.sharedPreferences.setString('token', data['access_token'] ?? '');
          myServices.sharedPreferences.setString('email', user['email'] ?? '');
          myServices.sharedPreferences.setString('onboarding', '1');

          // Save permissions
          final rawPerms = user['permissions'];
          if (rawPerms != null && rawPerms is List) {
            await myServices.savePermissions(
              List<String>.from(rawPerms.map((e) => e.toString())),
            );
          }

          statusRequest = StatusRequest.success;
          update();

          customSnackbar(
            'staff_welcome'.tr,
            storeName.isNotEmpty
                ? '${'staff_welcome'.tr} $storeName!'
                : 'staff_invited_title'.tr,
            isError: false,
          );

          // Navigate to the seller main screen (tabs filtered by permissions)
          Get.offAllNamed(AppRoute.sellerMain);
        } else {
          // Handle specific backend error messages
          final message = data['message'] ?? 'staff_invite_accept_failed'.tr;
          statusRequest = StatusRequest.failure;
          update();

          if (message.toString().toLowerCase().contains('expired')) {
            customSnackbar('staff_warning'.tr, 'staff_invite_token_expired'.tr);
          } else if (message.toString().toLowerCase().contains('invalid')) {
            customSnackbar('staff_warning'.tr, 'staff_invite_token_invalid'.tr);
          } else {
            customSnackbar('staff_warning'.tr, message.toString());
          }
        }
      },
    );
  }

  @override
  void onClose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }
}
