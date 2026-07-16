import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/data/datasource/remote/seller/seller_branches_data.dart';
import 'package:e_commerce/data/model/seller/branch_model.dart';


class SellerBranchesController extends GetxController {
  late SellerBranchesData branchesData;
  MyServices myServices = Get.find();

  StatusRequest statusRequest     = StatusRequest.none;
  StatusRequest formStatusRequest = StatusRequest.none;

  List<BranchModel> branches     = [];
  Set<int>          togglingIds  = {};
  Set<int>          deletingIds  = {};

  BranchModel? editingBranch;
  bool get isEditing => editingBranch != null;

  final formKey      = GlobalKey<FormState>();
  final nameCtrl     = TextEditingController();
  final addressCtrl  = TextEditingController();
  final phoneCtrl    = TextEditingController();
  final managerCtrl  = TextEditingController();

  double? selectedLat;
  double? selectedLng;
  bool    locationConfirmed = false;

  List<WorkingHoursEntry> formWorkingHours = [];

  @override
  void onInit() {
    super.onInit();
    branchesData = SellerBranchesData(Get.find<Crud>());
    loadBranches();
  }

  Future<void> loadBranches() async {
    statusRequest = StatusRequest.loading;
    update();

    String token = myServices.sharedPreferences.getString("token") ?? "";
    final response = await branchesData.getBranches(token);

    response.fold((failure) {
      statusRequest = failure;
    }, (resData) {
      if (resData['success'] == true) {
        List data = resData['data'] ?? [];
        branches = data.map((e) => BranchModel.fromJson(e)).toList();
        statusRequest = StatusRequest.success;
      } else {
        branches      = [];
        statusRequest = StatusRequest.success;
      }
    });

    update();
  }

  void initForm([BranchModel? branch]) {
    editingBranch = branch;

    if (branch != null) {
      nameCtrl.text    = branch.name;
      addressCtrl.text = branch.address;
      phoneCtrl.text   = branch.phone;
      managerCtrl.text = branch.managerName;
      selectedLat      = branch.lat;
      selectedLng      = branch.lng;
      locationConfirmed = branch.hasLocation;
      formWorkingHours = branch.workingHours
          .map((e) => e.copyWith())
          .toList();
    } else {
      nameCtrl.clear();
      addressCtrl.clear();
      phoneCtrl.clear();
      managerCtrl.clear();
      selectedLat       = null;
      selectedLng       = null;
      locationConfirmed = false;
      formWorkingHours  = BranchModel.defaultWorkingHours();
    }

    formStatusRequest = StatusRequest.none;
    update();
  }

  Future<void> openMap() async {
    final result = await Get.toNamed('/seller/branches/location');
    if (result != null && result is LatLng) {
      setLocation(result.latitude, result.longitude);
    }
  }

  void setLocation(double lat, double lng) {
    selectedLat       = lat;
    selectedLng       = lng;
    locationConfirmed = true;
    update();
  }

  void clearLocation() {
    selectedLat       = null;
    selectedLng       = null;
    locationConfirmed = false;
    update();
  }

  void updateWorkingHoursEntry(
      int index, {
        bool?   isOpen,
        String? openTime,
        String? closeTime,
      }) {
    formWorkingHours[index] = formWorkingHours[index].copyWith(
      isOpen:    isOpen,
      openTime:  openTime,
      closeTime: closeTime,
    );
    update();
  }

  Future<void> saveBranch() async {
    if (!formKey.currentState!.validate()) return;

    if (!locationConfirmed) {
      customSnackbar("تنبيه", "الرجاء تحديد الموقع على الخريطة", isError: true);
      return;
    }

    formStatusRequest = StatusRequest.loading;
    update();

    final branch = BranchModel(
      id:           editingBranch?.id ?? 0,
      name:         nameCtrl.text.trim(),
      address:      addressCtrl.text.trim(),
      lat:          selectedLat,
      lng:          selectedLng,
      phone:        phoneCtrl.text.trim(),
      managerName:  managerCtrl.text.trim(),
      workingHours: formWorkingHours,
      isActive:     editingBranch?.isActive ?? true,
      productCount: editingBranch?.productCount ?? 0,
    );

    dynamic response;
    final bool wasEditing = isEditing;
    final int? editedId   = editingBranch?.id;
    String token = myServices.sharedPreferences.getString("token") ?? "";

    if (isEditing) {
      response = await branchesData.updateBranch(token, branch);
    } else {
      response = await branchesData.addBranch(token, branch);
    }

    bool success = false;
    response.fold((failure) {
      formStatusRequest = failure;
    }, (resData) {
      if (resData['success'] == true) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(resData['data'] ?? {});
        if (wasEditing) {
          final idx = branches.indexWhere((b) => b.id == editedId);
          if (idx != -1) branches[idx] = BranchModel.fromJson(data);
        } else {
          branches.insert(0, BranchModel.fromJson(data));
        }
        formStatusRequest = StatusRequest.success;
        success = true;
      } else {
        formStatusRequest = StatusRequest.serverfailure;
      }
    });

    update();

    if (success) {
      Get.back();
      customSnackbar(
        wasEditing ? 'branch_updated_title'.tr : 'branch_added_title'.tr,
        wasEditing ? 'branch_updated_body'.tr  : 'branch_added_body'.tr,
        isError: false,
      );
    }
  }

  Future<void> toggleActive(int id) async {
    if (togglingIds.contains(id)) return;

    togglingIds.add(id);
    update();

    final idx = branches.indexWhere((b) => b.id == id);
    if (idx == -1) { togglingIds.remove(id); update(); return; }

    final newState = !branches[idx].isActive;
    String token = myServices.sharedPreferences.getString("token") ?? "";

    final response = await branchesData.toggleActive(token, id, newState);
    response.fold((l) {}, (r) {
      if (r['success'] == true) {
        branches[idx] = branches[idx].copyWith(isActive: newState);
      }
    });
    togglingIds.remove(id);
    update();
  }

  Future<void> deleteBranch(int id) async {
    if (deletingIds.contains(id)) return;

    final confirmed = await Get.dialog<bool>(
      _DeleteDialog(name: branches.firstWhere((b) => b.id == id).name),
    );

    if (confirmed != true) return;

    deletingIds.add(id);
    update();

    String token = myServices.sharedPreferences.getString("token") ?? "";
    final response = await branchesData.deleteBranch(token, id);

    response.fold((l) {}, (r) {
      if (r['success'] == true) {
        branches.removeWhere((b) => b.id == id);
      }
    });

    deletingIds.remove(id);
    update();

    customSnackbar('branch_deleted_title'.tr, 'branch_deleted_body'.tr, isError: false);
  }

  String? validateName(String? v) {
    if (v == null || v.trim().length < 2) return 'branch_name_required'.tr;
    return null;
  }

  String? validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'branch_phone_required'.tr;
    if (v.trim().length < 9)           return 'branch_phone_invalid'.tr;
    return null;
  }

  String? validateManager(String? v) {
    if (v == null || v.trim().length < 2) return 'branch_manager_required'.tr;
    return null;
  }

  String? validateAddress(String? v) {
    if (v == null || v.trim().length < 5) return 'branch_address_required'.tr;
    return null;
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    addressCtrl.dispose();
    phoneCtrl.dispose();
    managerCtrl.dispose();
    super.onClose();
  }
}

class _DeleteDialog extends StatelessWidget {
  final String name;
  const _DeleteDialog({required this.name});

  @override
  Widget build(BuildContext context) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    title: Text('branch_delete_confirm_title'.tr),
    content: Text('${'branch_delete_confirm_body'.tr} "$name"؟'),
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