import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_profile_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/functions/valid_input.dart';

class StoreEditScreen extends StatelessWidget {
  const StoreEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SellerProfileController>(
      builder: (ctrl) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        appBar: AppBar(
          backgroundColor: AppColor.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text('ØªØ¹Ø¯ÙŠÙ„ Ø¨ÙŠØ§Ù†Ø§Øª Ø§Ù„Ù…ØªØ¬Ø±',
              style: AppTextStyle.appBarTitle),
          centerTitle: true,
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  _SectionCard(
                    title: 'Ù‡ÙˆÙŠØ© Ø§Ù„Ù…ØªØ¬Ø±',
                    icon: Icons.image_outlined,
                    child: _StoreImagesSection(ctrl: ctrl),
                  ),
                  const SizedBox(height: 14),

                  _SectionCard(
                    title: 'Ø§Ù„Ù…Ø¹Ù„ÙˆÙ…Ø§Øª Ø§Ù„Ø£Ø³Ø§Ø³ÙŠØ©',
                    icon: Icons.info_outline_rounded,
                    child: Column(children: [
                      AppField(
                        controller: ctrl.storeNameCtrl,
                        label: 'Ø§Ø³Ù… Ø§Ù„Ù…ØªØ¬Ø± *',
                        hint: 'Ù…Ø«Ø§Ù„: Ù…ØªØ¬Ø± Ø£Ø­Ù…Ø¯ Ù„Ù„Ø­Ø±Ù Ø§Ù„ÙŠØ¯ÙˆÙŠØ©',
                        validator: (v) => validInput(v ?? '', 2, 80, 'store_name'),
                      ),
                      const SizedBox(height: 14),
                      AppField(
                        controller: ctrl.descCtrl,
                        label: 'ÙˆØµÙ Ø§Ù„Ù…ØªØ¬Ø±',
                        hint: 'Ø§ÙƒØªØ¨ ÙˆØµÙØ§Ù‹ Ø¬Ø°Ø§Ø¨Ø§Ù‹ ÙŠØ¹Ø±Ù‘Ù Ø¨Ù…ØªØ¬Ø±Ùƒ...',
                        maxLines: 4,
                        validator: null,
                      ),
                      const SizedBox(height: 14),
                      AppField(
                        controller: ctrl.cityCtrl,
                        label: 'Ø§Ù„Ù…Ø¯ÙŠÙ†Ø©',
                        hint: 'Ù…Ø«Ø§Ù„: Ø¯Ù…Ø´Ù‚',
                        validator: null,
                      ),
                      const SizedBox(height: 14),
                      AppField(
                        controller: ctrl.phoneCtrl,
                        label: 'Ø±Ù‚Ù… Ø§Ù„ØªÙˆØ§ØµÙ„',
                        hint: '09XXXXXXXX',
                        keyboardType: TextInputType.phone,
                        validator: (v) => validInput(v ?? '', 10, 10, 'phone'),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  _SectionCard(
                    title: 'Ø³ÙŠØ§Ø³Ø© Ø§Ù„Ø¥Ø±Ø¬Ø§Ø¹',
                    icon: Icons.policy_outlined,
                    child: AppField(
                      controller: ctrl.returnPolicyCtrl,
                      label: 'Ø´Ø±ÙˆØ· Ø§Ù„Ø¥Ø±Ø¬Ø§Ø¹',
                      hint: 'Ù…Ø«Ø§Ù„: ÙŠÙÙ‚Ø¨Ù„ Ø§Ù„Ø¥Ø±Ø¬Ø§Ø¹ Ø®Ù„Ø§Ù„ 48 Ø³Ø§Ø¹Ø© ÙÙŠ Ø­Ø§Ù„ ÙˆØ¬ÙˆØ¯ Ø¹ÙŠØ¨...',
                      maxLines: 3,
                      validator: null,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _SectionCard(
                    title: 'Ø£ÙˆÙ‚Ø§Øª Ø§Ù„Ø¯ÙˆØ§Ù…',
                    icon: Icons.access_time_rounded,
                    child: _WorkingHoursSection(),
                  ),
                ]),
              ),
            ),
          ],
        ),

        bottomNavigationBar: _SaveBar(
          ctrl: ctrl,
          onSave: ctrl.saveProfile,
        ),
      ),
    );
  }
}

class _StoreImagesSection extends StatelessWidget {
  final SellerProfileController ctrl;
  const _StoreImagesSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      // Logo
      _ImagePicker(
        label: 'Ø´Ø¹Ø§Ø± Ø§Ù„Ù…ØªØ¬Ø±',
        icon: Icons.store,
        hasImage: ctrl.newLogo != null,
        onTap: ctrl.pickLogo,
        size: 90,
        isCircle: true,
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _ImagePicker(
          label: 'ØºÙ„Ø§Ù Ø§Ù„Ù…ØªØ¬Ø±',
          icon: Icons.panorama_outlined,
          hasImage: ctrl.newCover != null,
          onTap: ctrl.pickCover,
          height: 90,
          isCircle: false,
        ),
      ),
    ]);
  }
}

class _ImagePicker extends StatelessWidget {
  final String     label;
  final IconData   icon;
  final bool       hasImage;
  final VoidCallback onTap;
  final double?    size;
  final double?    height;
  final bool       isCircle;

  const _ImagePicker({
    required this.label, required this.icon,
    required this.hasImage, required this.onTap,
    this.size, this.height, required this.isCircle,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width:  size,
          height: size ?? height ?? 90,
          decoration: BoxDecoration(
            color: hasImage
                ? AppColor.primaryColor.withOpacity(0.1)
                : AppColor.secondBackground,
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle
                ? null : BorderRadius.circular(12),
            border: Border.all(
              color: hasImage
                  ? AppColor.primaryColor.withOpacity(0.4)
                  : AppColor.greyBorder,
              width: hasImage ? 1.5 : 1,
              style: hasImage
                  ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasImage ? Icons.check_circle_outline_rounded : icon,
                size: 26,
                color: hasImage
                    ? AppColor.primaryColor : AppColor.greyLight,
              ),
              if (!hasImage) ...[
                const SizedBox(height: 4),
                Text('Ø±ÙØ¹',
                    style: AppTextStyle.labelSmall.copyWith(
                        fontSize: 10,
                        color: AppColor.greyLight)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: AppTextStyle.labelSmall.copyWith(fontSize: 10)),
      ],
    ),
  );
}

class _WorkingHoursSection extends StatefulWidget {
  @override
  State<_WorkingHoursSection> createState() => _WorkingHoursSectionState();
}

class _WorkingHoursSectionState extends State<_WorkingHoursSection> {
  final days = [
    _DayHours(day: 'Ø§Ù„Ø³Ø¨Øª'),
    _DayHours(day: 'Ø§Ù„Ø£Ø­Ø¯'),
    _DayHours(day: 'Ø§Ù„Ø¥Ø«Ù†ÙŠÙ†'),
    _DayHours(day: 'Ø§Ù„Ø«Ù„Ø§Ø«Ø§Ø¡'),
    _DayHours(day: 'Ø§Ù„Ø£Ø±Ø¨Ø¹Ø§Ø¡'),
    _DayHours(day: 'Ø§Ù„Ø®Ù…ÙŠØ³'),
    _DayHours(day: 'Ø§Ù„Ø¬Ù…Ø¹Ø©', isOff: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: days.map((d) => _DayRow(
        dayHours: d,
        onToggle: () => setState(() => d.isOff = !d.isOff),
        onFromTap: () => _pickTime(context, true, d),
        onToTap:   () => _pickTime(context, false, d),
      )).toList(),
    );
  }

  Future<void> _pickTime(
      BuildContext context, bool isFrom, _DayHours day) async {
    final init = TimeOfDay(
      hour:   isFrom ? day.fromHour   : day.toHour,
      minute: isFrom ? day.fromMinute : day.toMinute,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: init,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
              primary: AppColor.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          day.fromHour = picked.hour; day.fromMinute = picked.minute;
        } else {
          day.toHour = picked.hour; day.toMinute = picked.minute;
        }
      });
    }
  }
}

class _DayHours {
  String day;
  bool   isOff;
  int fromHour = 9,  fromMinute = 0;
  int toHour   = 20, toMinute   = 0;
  _DayHours({required this.day, this.isOff = false});

  String get fromStr =>
      '${fromHour.toString().padLeft(2,'0')}:${fromMinute.toString().padLeft(2,'0')}';
  String get toStr =>
      '${toHour.toString().padLeft(2,'0')}:${toMinute.toString().padLeft(2,'0')}';
}

class _DayRow extends StatelessWidget {
  final _DayHours  dayHours;
  final VoidCallback onToggle, onFromTap, onToTap;
  const _DayRow({
    required this.dayHours, required this.onToggle,
    required this.onFromTap, required this.onToTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      SizedBox(
        width: 65,
        child: Text(dayHours.day,
            style: AppTextStyle.labelLarge.copyWith(fontSize: 12)),
      ),

      GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 44, height: 26,
          decoration: BoxDecoration(
            color: dayHours.isOff
                ? AppColor.greyLight : AppColor.primaryColor,
            borderRadius: BorderRadius.circular(13),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            alignment: dayHours.isOff
                ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: 20, height: 20,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),

      if (dayHours.isOff)
        Expanded(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: AppColor.secondBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.greyBorder),
            ),
            child: Text('Ø¥Ø¬Ø§Ø²Ø©',
                style: AppTextStyle.labelSmall
                    .copyWith(color: AppColor.greyLight)),
          ),
        )
      else ...[
        Expanded(
          child: GestureDetector(
            onTap: onFromTap,
            child: _TimeChip(label: 'Ù…Ù† ${dayHours.fromStr}'),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Text('â€“',
              style: TextStyle(color: AppColor.grey, fontSize: 14)),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onToTap,
            child: _TimeChip(label: 'Ø­ØªÙ‰ ${dayHours.toStr}'),
          ),
        ),
      ],
    ]),
  );
}

class _TimeChip extends StatelessWidget {
  final String label;
  const _TimeChip({required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 7),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColor.primarySurface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.25)),
    ),
    child: Text(label,
        style: AppTextStyle.labelSmall.copyWith(
            color: AppColor.primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 11)),
  );
}

class _SectionCard extends StatelessWidget {
  final String title; final IconData icon; final Widget child;
  const _SectionCard({
    required this.title, required this.icon, required this.child,
  });
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppColor.cardShadow,
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Row(children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: AppColor.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: AppColor.primaryColor),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: AppTextStyle.heading3.copyWith(fontSize: 14)),
        ]),
      ),
      Divider(height: 18, indent: 16, endIndent: 16,
          color: AppColor.greyBorder),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: child,
      ),
    ]),
  );
}

class AppField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final int    maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const AppField({
    required this.controller, required this.label, required this.hint,
    this.maxLines = 1, this.keyboardType, required this.validator,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyle.inputLabel),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        maxLines:   maxLines,
        keyboardType: keyboardType,
        validator:  validator,
        style: AppTextStyle.inputText,
        decoration: InputDecoration(
          hintText: hint, hintStyle: AppTextStyle.inputHint,
          filled: true, fillColor: AppColor.secondBackground,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.greyBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.greyBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: AppColor.primaryColor, width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.error)),
          errorStyle: AppTextStyle.inputError,
        ),
      ),
    ],
  );
}

class _SaveBar extends StatelessWidget {
  final SellerProfileController ctrl;
  final Future<void> Function() onSave;
  const _SaveBar({required this.ctrl, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final loading = ctrl.saveStatusRequest == StatusRequest.loading;
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: Colors.white, boxShadow: AppColor.bottomNavShadow),
      child: SizedBox(
        width: double.infinity, height: 50,
        child: ElevatedButton(
          onPressed: loading ? null : onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
            disabledBackgroundColor:
                AppColor.primaryColor.withOpacity(0.6),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: loading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Text('Ø­ÙØ¸ Ø§Ù„ØªØ¹Ø¯ÙŠÙ„Ø§Øª',
                  style: AppTextStyle.buttonLarge),
        ),
      ),
    );
  }
}
