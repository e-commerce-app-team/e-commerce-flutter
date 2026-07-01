import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/data/model/seller/dashboard/spin_wheel_models.dart';

class SpinWheelController extends GetxController {

  StatusRequest statusRequest     = StatusRequest.none;
  StatusRequest saveStatusRequest = StatusRequest.none;

  SpinWheelConfig config = SpinWheelConfig(enabled: false, spinLimit: 'daily');
  List<SpinSegmentModel> segments = [];

  int get totalProbability =>
      segments.fold(0, (sum, s) => sum + s.probability);
  bool get isProbabilityValid => totalProbability == 100;
  bool get canAddSegment      => segments.length < 8;

  Future<void> loadConfig() async {
    statusRequest = StatusRequest.loading;
    update();
    await Future.delayed(const Duration(milliseconds: 600));
    // TODO: var res = await spinData.getConfig();
    config   = SpinWheelConfig.mock();
    segments = SpinSegmentModel.mockList();
    statusRequest = StatusRequest.success;
    update();
  }

  void toggleEnabled() {
    config.enabled = !config.enabled;
    update();
  }

  void setSpinLimit(String limit) {
    config.spinLimit = limit;
    update();
  }

  void addSegment() {
    if (!canAddSegment) {
      customSnackbar('spin_max_segments'.tr, 'spin_max_segments_sub'.tr);
      return;
    }
    final newId = segments.isEmpty
        ? 1
        : segments.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1;
    segments.add(SpinSegmentModel(
      id:          newId,
      label:       'spin_new_segment'.tr,
      type:        'none',
      value:       0,
      probability: 0,
      color:       '#B0BEC5',
    ));
    update();
  }

  void removeSegment(int id) {
    if (segments.length <= 2) {
      customSnackbar('spin_min_segments'.tr, 'spin_min_segments_sub'.tr);
      return;
    }
    segments.removeWhere((s) => s.id == id);
    update();
  }

  void updateSegmentLabel(int id, String label) {
    final idx = segments.indexWhere((s) => s.id == id);
    if (idx != -1) { segments[idx] = segments[idx].copyWith(label: label); update(); }
  }

  void updateSegmentType(int id, String type) {
    final idx = segments.indexWhere((s) => s.id == id);
    if (idx != -1) {
      segments[idx] = segments[idx].copyWith(
        type:  type,
        value: type == 'none' ? 0 : segments[idx].value,
      );
      update();
    }
  }

  void updateSegmentValue(int id, int value) {
    final idx = segments.indexWhere((s) => s.id == id);
    if (idx != -1) { segments[idx] = segments[idx].copyWith(value: value); update(); }
  }

  void updateSegmentProbability(int id, int probability) {
    final idx = segments.indexWhere((s) => s.id == id);
    if (idx != -1) {
      segments[idx] = segments[idx].copyWith(probability: probability);
      update();
    }
  }

  void updateSegmentColor(int id, String color) {
    final idx = segments.indexWhere((s) => s.id == id);
    if (idx != -1) { segments[idx] = segments[idx].copyWith(color: color); update(); }
  }

  void autoDistributeProbability() {
    if (segments.isEmpty) return;
    final each = (100 / segments.length).floor();
    final remainder = 100 - (each * segments.length);
    for (int i = 0; i < segments.length; i++) {
      segments[i] = segments[i].copyWith(
        probability: i == 0 ? each + remainder : each,
      );
    }
    update();
  }

  Future<void> saveConfig() async {
    if (!isProbabilityValid) {
      customSnackbar(
        'spin_probability_error'.tr,
        'spin_probability_error_sub'.tr
            .replaceAll('@total', totalProbability.toString()),
      );
      return;
    }
    for (final s in segments) {
      if (s.label.trim().isEmpty) {
        customSnackbar('spin_empty_label'.tr, 'spin_empty_label_sub'.tr);
        return;
      }
    }
    saveStatusRequest = StatusRequest.loading;
    update();
    await Future.delayed(const Duration(milliseconds: 700));
    //  await spinData.updateConfig(config, segments);
    saveStatusRequest = StatusRequest.success;
    customSnackbar('success'.tr, 'spin_saved'.tr, isError: false);
    update();
  }

  @override
  void onInit() { super.onInit(); loadConfig(); }
}
