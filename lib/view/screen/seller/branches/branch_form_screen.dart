import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:e_commerce/controller/seller/seller_branches_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/branch_model.dart';
import 'package:e_commerce/view/widget/shared/app_text_field.dart';

class BranchFormScreen extends StatelessWidget {
  const BranchFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SellerBranchesController>(
      builder: (ctrl) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        appBar: _FormAppBar(ctrl: ctrl),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          child: Form(
            key: ctrl.formKey,
            child: Column(children: [
              _FormSection(
                icon: Icons.storefront_outlined,
                title: 'branch_basic_info'.tr,
                child: Column(children: [
                  AppField(
                    controller: ctrl.nameCtrl,
                    label: 'branch_name_label'.tr,
                    hint: 'branch_name_hint'.tr,
                    validator: ctrl.validateName,
                  ),
                  const SizedBox(height: 12),
                  AppField(
                    controller: ctrl.phoneCtrl,
                    label: 'branch_phone_label'.tr,
                    hint: 'branch_phone_hint'.tr,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: ctrl.validatePhone,
                  ),
                  const SizedBox(height: 12),
                  AppField(
                    controller: ctrl.managerCtrl,
                    label: 'branch_manager_label'.tr,
                    hint: 'branch_manager_hint'.tr,
                    validator: ctrl.validateManager,
                  ),
                  const SizedBox(height: 12),
                  AppField(
                    controller: ctrl.addressCtrl,
                    label: 'branch_address_label'.tr,
                    hint: 'branch_address_hint'.tr,
                    maxLines: 2,
                    validator: ctrl.validateAddress,
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              _FormSection(
                icon: Icons.location_on_outlined,
                title: 'branch_location'.tr,
                child: Column(children: [
                  _LocationPickerButton(ctrl: ctrl),
                  if (ctrl.locationConfirmed && ctrl.selectedLat != null) ...[
                    const SizedBox(height: 10),
                    _LocationPreview(ctrl: ctrl),
                  ],
                ]),
              ),
              const SizedBox(height: 16),
              _FormSection(
                icon: Icons.schedule_outlined,
                title: 'branch_working_hours'.tr,
                child: Column(
                  children: List.generate(
                    ctrl.formWorkingHours.length,
                        (i) => _WorkingHoursRow(
                      entry: ctrl.formWorkingHours[i],
                      index: i,
                      ctrl: ctrl,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: ctrl.formStatusRequest == StatusRequest.loading
                      ? null
                      : ctrl.saveBranch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    disabledBackgroundColor:
                    AppColor.primaryColor.withOpacity(0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: ctrl.formStatusRequest == StatusRequest.loading
                      ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                      : Text(
                    ctrl.isEditing
                        ? 'branch_save_edit'.tr
                        : 'branch_save_add'.tr,
                    style: AppTextStyle.buttonMedium,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _FormAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SellerBranchesController ctrl;
  const _FormAppBar({required this.ctrl});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: AppColor.primaryColor,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_rounded,
          color: Colors.white, size: 20),
      onPressed: Get.back,
    ),
    title: Text(
      ctrl.isEditing ? 'branch_edit_title'.tr : 'branch_add_title'.tr,
      style: AppTextStyle.appBarTitle,
    ),
    centerTitle: true,
  );
}

class _FormSection extends StatelessWidget {
  final IconData icon;
  final String   title;
  final Widget   child;
  const _FormSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppColor.cardShadow,
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: AppColor.primarySurface,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 15, color: AppColor.primaryColor),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: AppTextStyle.heading3.copyWith(fontSize: 14)),
      ]),
      const Divider(height: 18, color: AppColor.greyBorder),
      child,
    ]),
  );
}

class _LocationPickerButton extends StatelessWidget {
  final SellerBranchesController ctrl;
  const _LocationPickerButton({required this.ctrl});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: ctrl.openMap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: ctrl.locationConfirmed
            ? AppColor.successLight
            : AppColor.secondBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ctrl.locationConfirmed
              ? AppColor.success
              : AppColor.greyBorder,
          width: ctrl.locationConfirmed ? 1.5 : 0.8,
        ),
      ),
      child: Row(children: [
        Icon(
          ctrl.locationConfirmed
              ? Icons.location_on_rounded
              : Icons.add_location_alt_outlined,
          size: 20,
          color: ctrl.locationConfirmed
              ? AppColor.success : AppColor.greyLight,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            ctrl.locationConfirmed
                ? 'branch_location_set'.tr
                : 'branch_pick_location'.tr,
            style: AppTextStyle.labelMedium.copyWith(
              color: ctrl.locationConfirmed
                  ? AppColor.successDark : AppColor.grey,
              fontSize: 13,
            ),
          ),
        ),
        if (ctrl.locationConfirmed)
          GestureDetector(
            onTap: ctrl.clearLocation,
            child: const Icon(Icons.close_rounded,
                size: 16, color: AppColor.error),
          )
        else
          const Icon(Icons.chevron_left_rounded,
              size: 18, color: AppColor.greyLight),
      ]),
    ),
  );
}

class _LocationPreview extends StatelessWidget {
  final SellerBranchesController ctrl;
  const _LocationPreview({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final latLng = LatLng(ctrl.selectedLat!, ctrl.selectedLng!);

    return Container(
      height: 140,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColor.success.withOpacity(0.4)),
      ),
      child: Stack(children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: latLng,
            initialZoom: 14.0,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.e_commerce',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: latLng,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: AppColor.primaryColor,
                    size: 35,
                  ),
                ),
              ],
            ),
          ],
        ),

        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6),
            color: Colors.black.withOpacity(0.45),
            child: Text(
              '${ctrl.selectedLat!.toStringAsFixed(5)}'
                  ', ${ctrl.selectedLng!.toStringAsFixed(5)}',
              style: AppTextStyle.orderNumber.copyWith(
                  color: Colors.white, fontSize: 11),
            ),
          ),
        ),
      ]),
    );
  }
}

class _WorkingHoursRow extends StatelessWidget {
  final WorkingHoursEntry        entry;
  final int                      index;
  final SellerBranchesController ctrl;
  const _WorkingHoursRow({
    required this.entry,
    required this.index,
    required this.ctrl,
  });

  static const Map<String, String> _dayLabels = {
    'sunday':    'day_sunday',
    'monday':    'day_monday',
    'tuesday':   'day_tuesday',
    'wednesday': 'day_wednesday',
    'thursday':  'day_thursday',
    'friday':    'day_friday',
    'saturday':  'day_saturday',
  };

  Future<void> _pickTime(
      BuildContext context,
      bool isOpen,
      ) async {
    final parts = (isOpen ? entry.openTime : entry.closeTime).split(':');
    final initial = TimeOfDay(
      hour:   int.tryParse(parts.first) ?? 9,
      minute: int.tryParse(parts.last)  ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    ctrl.updateWorkingHoursEntry(
      index,
      openTime:  isOpen ? formatted : null,
      closeTime: isOpen ? null : formatted,
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      SizedBox(
        width: 72,
        child: Text(
          (_dayLabels[entry.dayKey] ?? entry.dayKey).tr,
          style: AppTextStyle.labelMedium.copyWith(fontSize: 12),
        ),
      ),
      Switch(
        value:          entry.isOpen,
        activeColor:    AppColor.primaryColor,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onChanged: (v) =>
            ctrl.updateWorkingHoursEntry(index, isOpen: v),
      ),
      if (entry.isOpen) ...[
        const SizedBox(width: 4),
        _TimeChip(
          time: entry.openTime,
          onTap: () => _pickTime(context, true),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('—',
              style: AppTextStyle.labelSmall
                  .copyWith(color: AppColor.greyLight)),
        ),
        _TimeChip(
          time: entry.closeTime,
          onTap: () => _pickTime(context, false),
        ),
      ] else
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Text('branch_closed'.tr,
              style: AppTextStyle.labelSmall
                  .copyWith(color: AppColor.error, fontSize: 11)),
        ),
    ]),
  );
}

class _TimeChip extends StatelessWidget {
  final String     time;
  final VoidCallback onTap;
  const _TimeChip({required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColor.primarySurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AppColor.primaryColor.withOpacity(0.3)),
      ),
      child: Text(time,
          style: AppTextStyle.orderNumber.copyWith(
              color: AppColor.primaryColor, fontSize: 12)),
    ),
  );
}