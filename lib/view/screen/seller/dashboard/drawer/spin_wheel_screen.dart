import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/dashboard/spin_wheel_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/dashboard/spin_wheel_models.dart';
import 'package:e_commerce/view/widget/seller/dashboard/shimmer_box.dart';

class SpinWheelScreen extends StatelessWidget {
  const SpinWheelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SpinWheelController());
    return GetBuilder<SpinWheelController>(
      builder: (ctrl) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        appBar: _AppBar(ctrl: ctrl),
        body: ctrl.statusRequest == StatusRequest.loading
            ? const _Shimmer()
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([

                        _EnableCard(ctrl: ctrl),
                        const SizedBox(height: 14),

                        if (ctrl.config.enabled) ...[
                          _WheelPreviewCard(ctrl: ctrl),
                          const SizedBox(height: 14),

                          _SpinLimitCard(ctrl: ctrl),
                          const SizedBox(height: 14),

                          _ProbabilityBar(ctrl: ctrl),
                          const SizedBox(height: 14),

                          _SegmentsList(ctrl: ctrl),
                        ],
                      ]),
                    ),
                  ),
                ],
              ),
        bottomNavigationBar: ctrl.config.enabled
            ? _SaveBar(ctrl: ctrl)
            : null,
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final SpinWheelController ctrl;
  const _AppBar({required this.ctrl});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: AppColor.primaryColor,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_rounded,
          color: Colors.white, size: 20),
      onPressed: () => Get.back(),
    ),
    title: Text('spin_wheel'.tr, style: AppTextStyle.appBarTitle),
    centerTitle: true,
    actions: [
      if (ctrl.config.enabled)
        TextButton(
          onPressed: ctrl.autoDistributeProbability,
          child: Text(
            'spin_auto_dist'.tr,
            style: AppTextStyle.labelSmall.copyWith(
                color: Colors.white70, fontSize: 11),
          ),
        ),
    ],
  );
}

class _EnableCard extends StatelessWidget {
  final SpinWheelController ctrl;
  const _EnableCard({required this.ctrl});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppColor.cardShadow,
      border: Border.all(
        color: ctrl.config.enabled
            ? AppColor.primaryColor.withOpacity(0.2)
            : AppColor.greyBorder,
      ),
    ),
    child: Row(children: [
      Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          color: ctrl.config.enabled
              ? AppColor.primarySurface : AppColor.secondBackground,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(Icons.casino_outlined,
            size: 24,
            color: ctrl.config.enabled
                ? AppColor.primaryColor : AppColor.greyLight),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('spin_enable_title'.tr,
                style: AppTextStyle.heading3.copyWith(fontSize: 14)),
            Text('spin_enable_sub'.tr,
                style: AppTextStyle.bodySmall.copyWith(fontSize: 12)),
          ],
        ),
      ),
      Switch.adaptive(
        value: ctrl.config.enabled,
        onChanged: (_) => ctrl.toggleEnabled(),
        activeColor: AppColor.primaryColor,
      ),
    ]),
  );
}

class _WheelPreviewCard extends StatefulWidget {
  final SpinWheelController ctrl;
  const _WheelPreviewCard({required this.ctrl});
  @override
  State<_WheelPreviewCard> createState() => _WheelPreviewCardState();
}

class _WheelPreviewCardState extends State<_WheelPreviewCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinCtrl;
  late Animation<double>    _spinAnim;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3));
    _spinAnim = CurvedAnimation(
        parent: _spinCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() { _spinCtrl.dispose(); super.dispose(); }

  void _spin() {
    if (_isSpinning) return;
    setState(() => _isSpinning = true);
    _spinCtrl.forward(from: 0).then((_) {
      setState(() => _isSpinning = false);
    });
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xff1A1A2E), Color(0xff16213E)],
      ),
      borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 20, offset: const Offset(0, 8),
      )],
    ),
    child: Column(children: [
      Text('spin_preview'.tr,
          style: AppTextStyle.labelMedium.copyWith(
              color: Colors.white60, fontSize: 12)),
      const SizedBox(height: 16),

      Stack(alignment: Alignment.center, children: [
        Container(
          width: 224, height: 224,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(
              color: AppColor.primaryColor.withOpacity(0.3),
              blurRadius: 20, spreadRadius: 4,
            )],
          ),
        ),
        AnimatedBuilder(
          animation: _spinAnim,
          builder: (_, __) => Transform.rotate(
            angle: _spinAnim.value * 6 * math.pi,
            child: CustomPaint(
              size: const Size(220, 220),
              painter: _WheelPainter(
                  segments: widget.ctrl.segments),
            ),
          ),
        ),
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
            )],
          ),
          child: Icon(Icons.casino_rounded,
              size: 22, color: AppColor.primaryColor),
        ),
        Positioned(
          top: 0,
          child: Container(
            width: 0, height: 0,
            decoration: const BoxDecoration(),
            child: CustomPaint(
              size: const Size(20, 28),
              painter: _PointerPainter(),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 16),

      GestureDetector(
        onTap: _spin,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              _isSpinning
                  ? Icons.autorenew_rounded
                  : Icons.play_arrow_rounded,
              size: 16, color: Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              _isSpinning
                  ? 'spin_spinning'.tr
                  : 'spin_test'.tr,
              style: AppTextStyle.labelSmall.copyWith(
                  color: Colors.white70, fontSize: 12),
            ),
          ]),
        ),
      ),
    ]),
  );
}

class _WheelPainter extends CustomPainter {
  final List<SpinSegmentModel> segments;
  _WheelPainter({required this.segments});

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) { return AppColor.primaryColor; }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = cx - 2;
    final total = segments.fold(0, (sum, s) => sum + s.probability);
    if (total == 0) return;

    double startAngle = -math.pi / 2;
    for (int i = 0; i < segments.length; i++) {
      final seg       = segments[i];
      final sweep     = (seg.probability / total) * 2 * math.pi;
      final color     = _hexToColor(seg.color);
      final midAngle  = startAngle + sweep / 2;

      final paint = Paint()..color = color..style = PaintingStyle.fill;
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r),
          startAngle, sweep, true, paint);

      final border = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r),
          startAngle, sweep, true, border);

      if (sweep > 0.3) {
        final labelR = r * 0.65;
        final lx = cx + labelR * math.cos(midAngle);
        final ly = cy + labelR * math.sin(midAngle);
        final tp = TextPainter(
          text: TextSpan(
            text: seg.label,
            style: TextStyle(
              color: _textColor(color),
              fontSize: sweep > 0.8 ? 11 : 9,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            ),
          ),
          textDirection: TextDirection.rtl,
        )..layout(maxWidth: r * 0.5);
        canvas.save();
        canvas.translate(lx, ly);
        canvas.rotate(midAngle + math.pi / 2);
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        canvas.restore();
      }
      startAngle += sweep;
    }

    final ring = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(cx, cy), r, ring);
  }

  Color _textColor(Color bg) {
    final lum = bg.computeLuminance();
    return lum > 0.4 ? Colors.black87 : Colors.white;
  }

  @override
  bool shouldRepaint(_WheelPainter old) =>
      old.segments != segments;
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawShadow(path, Colors.black26, 4, false);
  }
  @override
  bool shouldRepaint(_) => false;
}

class _SpinLimitCard extends StatelessWidget {
  final SpinWheelController ctrl;
  const _SpinLimitCard({required this.ctrl});

  @override
  Widget build(BuildContext context) => _SectionCard(
    title: 'spin_limit_title'.tr,
    icon:  Icons.timer_outlined,
    child: Row(children: [
      _LimitChip(
        label:    'spin_limit_daily'.tr,
        value:    'daily',
        selected: ctrl.config.spinLimit,
        onTap:    () => ctrl.setSpinLimit('daily'),
      ),
      const SizedBox(width: 8),
      _LimitChip(
        label:    'spin_limit_weekly'.tr,
        value:    'weekly',
        selected: ctrl.config.spinLimit,
        onTap:    () => ctrl.setSpinLimit('weekly'),
      ),
      const SizedBox(width: 8),
      _LimitChip(
        label:    'spin_limit_once'.tr,
        value:    'once',
        selected: ctrl.config.spinLimit,
        onTap:    () => ctrl.setSpinLimit('once'),
      ),
    ]),
  );
}

class _LimitChip extends StatelessWidget {
  final String label, value, selected;
  final VoidCallback onTap;
  const _LimitChip({required this.label, required this.value,
      required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSel = value == selected;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? AppColor.primaryColor : AppColor.secondBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSel ? AppColor.primaryColor : AppColor.greyBorder,
          ),
        ),
        child: Text(label,
            style: AppTextStyle.chip.copyWith(
              color: isSel ? Colors.white : AppColor.grey,
              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
            )),
      ),
    );
  }
}

class _ProbabilityBar extends StatelessWidget {
  final SpinWheelController ctrl;
  const _ProbabilityBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isValid = ctrl.isProbabilityValid;
    final total   = ctrl.totalProbability;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isValid ? AppColor.successLight : AppColor.errorLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isValid
              ? AppColor.success.withOpacity(0.3)
              : AppColor.error.withOpacity(0.3),
        ),
      ),
      child: Row(children: [
        Icon(
          isValid
              ? Icons.check_circle_outline_rounded
              : Icons.warning_amber_rounded,
          size: 20,
          color: isValid ? AppColor.success : AppColor.error,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            isValid
                ? 'spin_prob_valid'.tr
                : 'spin_prob_invalid'.tr
                    .replaceAll('@total', total.toString()),
            style: AppTextStyle.labelLarge.copyWith(
              fontSize: 13,
              color: isValid ? AppColor.successDark : AppColor.errorDark,
            ),
          ),
        ),
        Text(
          '$total / 100',
          style: AppTextStyle.price.copyWith(
            fontSize: 15,
            color: isValid ? AppColor.success : AppColor.error,
          ),
        ),
      ]),
    );
  }
}

class _SegmentsList extends StatelessWidget {
  final SpinWheelController ctrl;
  const _SegmentsList({required this.ctrl});

  static const _segmentColors = [
    '#FF6300', '#27AE60', '#185FA5', '#8E44AD',
    '#E74C3C', '#F39C12', '#16A085', '#B0BEC5',
  ];

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'spin_segments'.tr,
      icon:  Icons.pie_chart_outline_rounded,
      trailing: ctrl.canAddSegment
          ? GestureDetector(
              onTap: ctrl.addSegment,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColor.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_rounded,
                    size: 18, color: AppColor.primaryColor),
              ),
            )
          : null,
      child: Column(
        children: ctrl.segments.map((seg) =>
            _SegmentRow(
              seg: seg,
              ctrl: ctrl,
              colorOptions: _segmentColors,
            )).toList(),
      ),
    );
  }
}

class _SegmentRow extends StatefulWidget {
  final SpinSegmentModel    seg;
  final SpinWheelController ctrl;
  final List<String>        colorOptions;
  const _SegmentRow({
    required this.seg, required this.ctrl, required this.colorOptions,
  });
  @override
  State<_SegmentRow> createState() => _SegmentRowState();
}

class _SegmentRowState extends State<_SegmentRow> {
  late TextEditingController _labelCtrl;
  late TextEditingController _valueCtrl;
  late TextEditingController _probCtrl;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.seg.label);
    _valueCtrl = TextEditingController(
        text: widget.seg.value > 0 ? widget.seg.value.toString() : '');
    _probCtrl  = TextEditingController(
        text: widget.seg.probability.toString());
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _valueCtrl.dispose();
    _probCtrl.dispose();
    super.dispose();
  }

  Color _hexToColor(String hex) {
    try { return Color(int.parse(hex.replaceFirst('#', '0xFF'))); }
    catch (_) { return AppColor.primaryColor; }
  }

  @override
  Widget build(BuildContext context) {
    final seg = widget.seg;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColor.secondBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.greyBorder),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Row(children: [
            GestureDetector(
              onTap: () => _showColorPicker(context, seg),
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: _hexToColor(seg.color),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white, width: 2),
                  boxShadow: AppColor.cardShadow,
                ),
              ),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: TextField(
                controller: _labelCtrl,
                onChanged: (v) =>
                    widget.ctrl.updateSegmentLabel(seg.id, v),
                style: AppTextStyle.inputText
                    .copyWith(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'spin_label_hint'.tr,
                  hintStyle: AppTextStyle.inputHint
                      .copyWith(fontSize: 12),
                  border: InputBorder.none,
                ),
              ),
            ),

            GestureDetector(
              onTap: () => widget.ctrl.removeSegment(seg.id),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColor.errorLight,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.close_rounded,
                    size: 14, color: AppColor.error),
              ),
            ),
          ]),
        ),
        const Divider(height: 14,
            indent: 12, endIndent: 12, color: AppColor.greyBorder),

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Row(children: [
            Expanded(
              flex: 3,
              child: _DropdownField(
                value: seg.type,
                items: const [
                  'percent', 'fixed', 'free_shipping', 'none',
                ],
                labelKey: (v) {
                  switch (v) {
                    case 'percent':       return 'seg_type_percent'.tr;
                    case 'fixed':         return 'seg_type_fixed'.tr;
                    case 'free_shipping': return 'seg_type_free_shipping'.tr;
                    default:              return 'seg_type_none'.tr;
                  }
                },
                onChanged: (v) =>
                    widget.ctrl.updateSegmentType(seg.id, v!),
              ),
            ),
            const SizedBox(width: 8),

            if (seg.type != 'none' && seg.type != 'free_shipping')
              Expanded(
                flex: 2,
                child: _SmallField(
                  controller: _valueCtrl,
                  hint: seg.type == 'percent' ? '%' : 'sp_short'.tr,
                  onChanged: (v) => widget.ctrl.updateSegmentValue(
                      seg.id, int.tryParse(v) ?? 0),
                ),
              ),
            if (seg.type != 'none' && seg.type != 'free_shipping')
              const SizedBox(width: 8),

            Expanded(
              flex: 2,
              child: _SmallField(
                controller: _probCtrl,
                hint: 'prob_%'.tr,
                suffix: '%',
                onChanged: (v) =>
                    widget.ctrl.updateSegmentProbability(
                        seg.id, int.tryParse(v) ?? 0),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  void _showColorPicker(BuildContext ctx, SpinSegmentModel seg) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('spin_choose_color'.tr,
              style: AppTextStyle.heading3.copyWith(fontSize: 14)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12, runSpacing: 12,
            children: widget.colorOptions.map((hex) {
              final color = _hexToColor(hex);
              final isSelected = hex == seg.color;
              return GestureDetector(
                onTap: () {
                  widget.ctrl.updateSegmentColor(seg.id, hex);
                  Get.back();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColor.black : Colors.white,
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: [BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8, offset: const Offset(0, 3),
                    )],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 20)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final String Function(String) labelKey;
  final void Function(String?) onChanged;
  const _DropdownField({
    required this.value, required this.items,
    required this.labelKey, required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: AppColor.secondBackground,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColor.greyBorder),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value, isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            size: 16, color: AppColor.grey),
        style: AppTextStyle.inputText.copyWith(fontSize: 12),
        borderRadius: BorderRadius.circular(10),
        items: items.map((v) => DropdownMenuItem(
          value: v,
          child: Text(labelKey(v),
              style: AppTextStyle.inputText.copyWith(fontSize: 12)),
        )).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

class _SmallField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? suffix;
  final void Function(String) onChanged;
  const _SmallField({
    required this.controller, required this.hint,
    required this.onChanged, this.suffix,
  });
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    textAlign: TextAlign.center,
    style: AppTextStyle.inputText.copyWith(
        fontSize: 13, fontFamily: 'PlayfairDisplay'),
    decoration: InputDecoration(
      hintText: hint, hintStyle: AppTextStyle.inputHint.copyWith(fontSize: 11),
      suffixText: suffix,
      suffixStyle: AppTextStyle.labelSmall.copyWith(fontSize: 10),
      filled: true, fillColor: AppColor.secondBackground,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColor.greyBorder)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColor.greyBorder)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: AppColor.primaryColor, width: 1.5)),
    ),
  );
}

class _SaveBar extends StatelessWidget {
  final SpinWheelController ctrl;
  const _SaveBar({required this.ctrl});
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
          onPressed: loading ? null : ctrl.saveConfig,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: loading
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Text('spin_save'.tr, style: AppTextStyle.buttonLarge),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String    title;
  final IconData  icon;
  final Widget    child;
  final Widget?   trailing;
  const _SectionCard({
    required this.title, required this.icon,
    required this.child, this.trailing,
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
          Expanded(
            child: Text(title,
                style: AppTextStyle.heading3.copyWith(fontSize: 14)),
          ),
          if (trailing != null) trailing!,
        ]),
      ),
      const Divider(height: 16, indent: 16, endIndent: 16,
          color: AppColor.greyBorder),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: child,
      ),
    ]),
  );
}

class _Shimmer extends StatelessWidget {
  const _Shimmer();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      Container(height: 80,
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(16))),
      const SizedBox(height: 14),
      Container(height: 320,
          decoration: BoxDecoration(
              color: const Color(0xff1A1A2E),
              borderRadius: BorderRadius.circular(18))),
      const SizedBox(height: 14),
      ...List.generate(3, (_) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(height: 80,
            decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(14))),
      )),
    ]),
  );
}
