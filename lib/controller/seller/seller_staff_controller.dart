// lib/controller/seller/seller_staff_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/data/datasource/remote/seller/seller_staff_data.dart';
import 'package:e_commerce/data/model/seller/staff_model.dart';

class SellerStaffController extends GetxController {
  late final SellerStaffData staffData;
  final MyServices myServices = Get.find();

  StatusRequest statusRequest     = StatusRequest.none;
  StatusRequest formStatusRequest = StatusRequest.none;

  List<StaffModel> staff     = [];
  Set<int>         deletingIds = {};
  Set<int>         updatingIds = {};

  String get _token => myServices.sharedPreferences.getString('token') ?? '';

  int get activeCount  => staff.where((s) => s.isActive).length;
  int get pendingCount => staff.where((s) => s.isPending).length;
  int get totalCount   => staff.length;

  StaffModel? _editingStaff;
  bool get isEditing => _editingStaff != null;

  final formKey      = GlobalKey<FormState>();
  final emailCtrl    = TextEditingController();
  String       formRole        = StaffRole.support;
  List<String> formPermissions = [];

  @override
  void onInit() {
    super.onInit();
    staffData = SellerStaffData(Get.find<Crud>());
    loadStaff();
  }

  Future<void> loadStaff() async {
    statusRequest = StatusRequest.loading;
    update();

    final response = await staffData.getStaff(_token);

    response.fold(
      (failure) {
        staff         = StaffModel.mockList();
        statusRequest = StatusRequest.success;
        update();
      },
      (data) {
        if (data is List) {
          staff = data.map((e) => StaffModel.fromJson(e)).toList();
        } else if (data['success'] == true && data['data'] is List) {
          staff = (data['data'] as List)
              .map((e) => StaffModel.fromJson(e))
              .toList();
        } else {
          staff = StaffModel.mockList();
        }
        statusRequest = StatusRequest.success;
        update();
      },
    );
  }

  Future<void> refreshStaff() => loadStaff();

  void initInviteForm() {
    _editingStaff  = null;
    emailCtrl.clear();
    formRole        = StaffRole.support;
    formPermissions = _defaultPermissions(StaffRole.support);
    formStatusRequest = StatusRequest.none;
    update();
  }

  void initEditForm(StaffModel s) {
    _editingStaff   = s;
    emailCtrl.text  = s.email;
    formRole        = s.role;
    formPermissions = List.from(s.permissions);
    formStatusRequest = StatusRequest.none;
    update();
  }

  void setRole(String role) {
    formRole        = role;
    formPermissions = _defaultPermissions(role);
    update();
  }

  void togglePermission(String perm) {
    if (formPermissions.contains(perm)) {
      formPermissions.remove(perm);
    } else {
      formPermissions.add(perm);
    }
    update();
  }

  List<String> _defaultPermissions(String role) {
    switch (role) {
      case StaffRole.manager:
        return List.from(StaffPermission.all);
      case StaffRole.warehouse:
        return [StaffPermission.viewOrders, StaffPermission.manageInventory];
      case StaffRole.support:
        return [StaffPermission.viewOrders, StaffPermission.chatWithBuyers];
      default:
        return [];
    }
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;
    if (formPermissions.isEmpty) {
      customSnackbar('staff_warning'.tr, 'staff_no_permissions'.tr);
      return;
    }

    formStatusRequest = StatusRequest.loading;
    update();

    if (isEditing) {
      await _updateStaff();
    } else {
      await _inviteStaff();
    }
  }

  Future<void> _inviteStaff() async {
    final response = await staffData.inviteStaff(
      _token,
      email:       emailCtrl.text.trim(),
      role:        formRole,
      permissions: formPermissions,
    );

    response.fold(
      (failure) {
        formStatusRequest = failure;
        update();
        customSnackbar('staff_warning'.tr, 'staff_invite_failed'.tr);
      },
      (data) {
        if (data['success'] == true || data is Map) {
          final newStaff = data['data'] != null
              ? StaffModel.fromJson(data['data'])
              : StaffModel(
                  id:          DateTime.now().millisecondsSinceEpoch,
                  name:        emailCtrl.text.split('@').first,
                  email:       emailCtrl.text.trim(),
                  role:        formRole,
                  permissions: formPermissions,
                  status:      'pending',
                  joinedAt:    'الآن',
                );
          staff.insert(0, newStaff);
          formStatusRequest = StatusRequest.success;
          update();
          Get.back();
          customSnackbar(
            'staff_invited_title'.tr,
            'staff_invited_body'.tr,
            isError: false,
          );
        } else {
          formStatusRequest = StatusRequest.failure;
          update();
          customSnackbar('staff_warning'.tr, data['message'] ?? 'staff_invite_failed'.tr);
        }
      },
    );
  }

  Future<void> _updateStaff() async {
    final id = _editingStaff!.id;

    final response = await staffData.updateStaff(
      _token,
      id,
      role:        formRole,
      permissions: formPermissions,
    );

    response.fold(
      (failure) {
        formStatusRequest = failure;
        update();
        customSnackbar('staff_warning'.tr, 'staff_update_failed'.tr);
      },
      (data) {
        final idx = staff.indexWhere((s) => s.id == id);
        if (idx != -1) {
          staff[idx] = staff[idx].copyWith(
            role:        formRole,
            permissions: formPermissions,
          );
        }
        formStatusRequest = StatusRequest.success;
        update();
        Get.back();
        customSnackbar(
          'staff_updated_title'.tr,
          'staff_updated_body'.tr,
          isError: false,
        );
      },
    );
  }

  Future<void> deleteStaff(StaffModel member) async {
    if (deletingIds.contains(member.id)) return;

    final confirmed = await Get.dialog<bool>(
      _StaffDeleteDialog(name: member.name),
    );
    if (confirmed != true) return;

    deletingIds.add(member.id);
    update();

    final response = await staffData.deleteStaff(_token, member.id);

    response.fold(
      (failure) {
        deletingIds.remove(member.id);
        update();
        customSnackbar('staff_warning'.tr, 'staff_delete_failed'.tr);
      },
      (data) {
        staff.removeWhere((s) => s.id == member.id);
        deletingIds.remove(member.id);
        update();
        customSnackbar(
          'staff_deleted_title'.tr,
          'staff_deleted_body'.tr,
          isError: false,
        );
      },
    );
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    super.onClose();
  }
}

class _StaffDeleteDialog extends StatelessWidget {
  final String name;
  const _StaffDeleteDialog({required this.name});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('staff_delete_title'.tr),
      content: Text('${'staff_delete_body'.tr} "$name"؟'),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text('cancel'.tr),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffDC2626),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Get.back(result: true),
          child: Text('delete'.tr,
              style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
