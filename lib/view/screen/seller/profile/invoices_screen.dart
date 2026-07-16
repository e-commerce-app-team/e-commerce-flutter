import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_invoices_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/invoices_models.dart';
import 'package:e_commerce/view/widget/seller/dashboard/shimmer_box.dart';
import 'package:e_commerce/view/widget/shared/app_text_field.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SellerInvoicesController());
    return GetBuilder<SellerInvoicesController>(
      builder: (ctrl) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        appBar: const _InvoicesAppBar(),
        body: ctrl.statusRequest == StatusRequest.loading
            ? const _InvoicesShimmer()
            : RefreshIndicator(
                onRefresh: ctrl.loadData,
                color: AppColor.primaryColor,
                backgroundColor: Colors.white,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([

                          // ① بيانات الضريبة
                          _TaxSettingsCard(ctrl: ctrl),
                          const SizedBox(height: 18),

                          // ② التقارير الشهرية
                          const _SectionLabel(
                            icon: Icons.calendar_month_rounded,
                            title: 'التقارير الشهرية',
                          ),
                          const SizedBox(height: 10),
                          _MonthSelectorRow(ctrl: ctrl),
                          const SizedBox(height: 10),
                          if (ctrl.currentReport != null)
                            _VatSummaryCard(ctrl: ctrl),
                          const SizedBox(height: 18),

                          // ③ قائمة الفواتير
                          _InvoicesSectionHeader(ctrl: ctrl),
                          const SizedBox(height: 10),

                          if (ctrl.filteredInvoices.isEmpty)
                            _EmptyInvoices(hasFilter: ctrl.filterStatus != 'all')
                          else
                            ...ctrl.filteredInvoices.asMap().entries.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _InvoiceCard(
                                  invoice: e.value,
                                  index: e.key,
                                  ctrl: ctrl,
                                ),
                              ),
                            ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// App Bar
// ════════════════════════════════════════════════════════════

class _InvoicesAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _InvoicesAppBar();

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
    title: Text('الفواتير الضريبية', style: AppTextStyle.appBarTitle),
    centerTitle: true,
    actions: [
      Container(
        margin: const EdgeInsets.only(left: 12, top: 11, bottom: 11),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.35)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.business_center_outlined, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text('شركات', style: AppTextStyle.badge.copyWith(
              color: Colors.white, fontSize: 10)),
        ]),
      ),
    ],
  );
}

// ════════════════════════════════════════════════════════════
// Section Label
// ════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionLabel({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: AppColor.warningLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 14, color: AppColor.warning),
    ),
    const SizedBox(width: 8),
    Text(title, style: AppTextStyle.heading3.copyWith(fontSize: 14)),
  ]);
}

// ════════════════════════════════════════════════════════════
// Tax Settings Card
// ════════════════════════════════════════════════════════════

class _TaxSettingsCard extends StatelessWidget {
  final SellerInvoicesController ctrl;
  const _TaxSettingsCard({required this.ctrl});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppColor.cardShadow,
      border: Border.all(
        color: ctrl.taxSettings?.isComplete == true
            ? AppColor.info.withOpacity(0.2)
            : AppColor.warning.withOpacity(0.4),
      ),
    ),
    child: Column(children: [
      // Header
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AppColor.infoLight,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.receipt_long_outlined,
                size: 16, color: AppColor.info),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('البيانات الضريبية',
                  style: AppTextStyle.heading3.copyWith(fontSize: 14)),
              if (ctrl.taxSettings?.isComplete == false)
                Text('يرجى إكمال بياناتك الضريبية',
                    style: AppTextStyle.labelSmall.copyWith(
                        color: AppColor.warning, fontSize: 10)),
            ]),
          ),
          GestureDetector(
            onTap: ctrl.isEditingSettings ? ctrl.cancelEdit : ctrl.toggleEditSettings,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: ctrl.isEditingSettings
                    ? AppColor.errorLight : AppColor.primarySurface,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                ctrl.isEditingSettings ? 'إلغاء' : 'تعديل',
                style: AppTextStyle.chip.copyWith(
                  color: ctrl.isEditingSettings
                      ? AppColor.error : AppColor.primaryColor,
                  fontWeight: FontWeight.w700, fontSize: 11,
                ),
              ),
            ),
          ),
        ]),
      ),
      const Divider(height: 16, indent: 16, endIndent: 16, color: AppColor.greyBorder),

      ctrl.isEditingSettings
          ? _TaxEditForm(ctrl: ctrl)
          : _TaxDisplay(settings: ctrl.taxSettings),
    ]),
  );
}

// ── Read-only display ──────────────────────────────────────

class _TaxDisplay extends StatelessWidget {
  final TaxSettingsModel? settings;
  const _TaxDisplay({required this.settings});

  @override
  Widget build(BuildContext context) {
    if (settings == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(children: [
        _TaxRow(
          icon: Icons.tag_outlined,
          label: 'الرقم الضريبي',
          value: settings!.vatNumber?.isNotEmpty == true
              ? settings!.vatNumber! : '—',
          valueMono: true,
        ),
        _TaxRow(
          icon: Icons.store_mall_directory_outlined,
          label: 'رقم السجل التجاري',
          value: settings!.crNumber?.isNotEmpty == true
              ? settings!.crNumber! : '—',
          valueMono: true,
        ),
        _TaxRow(
          icon: Icons.business_outlined,
          label: 'الاسم القانوني',
          value: settings!.legalName.isNotEmpty ? settings!.legalName : '—',
        ),
        _TaxRow(
          icon: Icons.location_on_outlined,
          label: 'العنوان',
          value: settings!.address.isNotEmpty ? settings!.address : '—',
          showDivider: false,
        ),
        const SizedBox(height: 12),
        Row(children: [
          _PillBadge(
            icon: Icons.percent_rounded,
            label: 'نسبة الضريبة: ${(settings!.vatRate * 100).toInt()}%',
            bg: AppColor.warningLight,
            fg: AppColor.warningDark,
          ),
          const SizedBox(width: 8),
          if (settings!.vatRegistered)
            _PillBadge(
              icon: Icons.verified_outlined,
              label: 'مسجل رسمياً',
              bg: AppColor.successLight,
              fg: AppColor.successDark,
            ),
        ]),
      ]),
    );
  }
}

class _TaxRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final bool     valueMono;
  final bool     showDivider;
  const _TaxRow({
    required this.icon, required this.label, required this.value,
    this.valueMono = false, this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) => Column(children: [
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 13, color: AppColor.greyLight),
        const SizedBox(width: 8),
        SizedBox(
          width: 96,
          child: Text(label,
              style: AppTextStyle.labelSmall.copyWith(fontSize: 11)),
        ),
        Expanded(
          child: Text(
            value,
            style: valueMono
                ? AppTextStyle.orderNumber.copyWith(fontSize: 12)
                : AppTextStyle.labelLarge.copyWith(fontSize: 12),
          ),
        ),
      ]),
    ),
    if (showDivider) const Divider(height: 1, color: AppColor.greyBorder),
  ]);
}

class _PillBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg, fg;
  const _PillBadge({required this.icon, required this.label,
      required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: fg.withOpacity(0.25)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: fg),
      const SizedBox(width: 4),
      Text(label, style: AppTextStyle.chip.copyWith(
          color: fg, fontWeight: FontWeight.w700, fontSize: 11)),
    ]),
  );
}

// ── Edit form ──────────────────────────────────────────────

class _TaxEditForm extends StatelessWidget {
  final SellerInvoicesController ctrl;
  const _TaxEditForm({required this.ctrl});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: Form(
      key: ctrl.formKey,
      child: Column(children: [
        AppField(
          controller: ctrl.vatCtrl,
          label: 'الرقم الضريبي *',
          hint: 'مثال: 300123456789012',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'الرقم الضريبي مطلوب';
            if (v.length < 11) return 'يجب أن يكون 11 رقماً على الأقل';
            return null;
          },
        ),
        const SizedBox(height: 12),
        AppField(
          controller: ctrl.crCtrl,
          label: 'رقم السجل التجاري *',
          hint: 'مثال: 1234567890',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'رقم السجل التجاري مطلوب';
            if (v.length < 5) return 'يجب أن يكون 5 أرقام على الأقل';
            return null;
          },
        ),
        const SizedBox(height: 12),
        AppField(
          controller: ctrl.legalNameCtrl,
          label: 'الاسم القانوني للمنشأة *',
          hint: 'مثال: شركة أحمد للحرف اليدوية',
          validator: (v) {
            if (v == null || v.trim().length < 3) return 'الاسم القانوني مطلوب (3 أحرف على الأقل)';
            return null;
          },
        ),
        const SizedBox(height: 12),
        AppField(
          controller: ctrl.addressCtrl,
          label: 'عنوان المنشأة',
          hint: 'دمشق، المزة، شارع...',
          validator: null,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity, height: 46,
          child: ElevatedButton(
            onPressed: ctrl.saveStatusRequest == StatusRequest.loading
                ? null : ctrl.saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              disabledBackgroundColor: AppColor.primaryColor.withOpacity(0.6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: ctrl.saveStatusRequest == StatusRequest.loading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Text('حفظ البيانات', style: AppTextStyle.buttonMedium),
          ),
        ),
      ]),
    ),
  );
}

// ════════════════════════════════════════════════════════════
// Month Selector
// ════════════════════════════════════════════════════════════

class _MonthSelectorRow extends StatelessWidget {
  final SellerInvoicesController ctrl;
  const _MonthSelectorRow({required this.ctrl});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 36,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: ctrl.vatReports.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final isSelected = ctrl.selectedMonthIndex == i;
        final report     = ctrl.vatReports[i];
        return GestureDetector(
          onTap: () => ctrl.selectMonth(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected ? AppColor.warning : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColor.warning : AppColor.greyBorder,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(
                      color: AppColor.warning.withOpacity(0.3),
                      blurRadius: 8, offset: const Offset(0, 3))]
                  : null,
            ),
            child: Text(
              report.monthLabel,
              style: AppTextStyle.chip.copyWith(
                color: isSelected ? Colors.white : AppColor.grey,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    ),
  );
}

// ════════════════════════════════════════════════════════════
// VAT Summary Card
// ════════════════════════════════════════════════════════════

class _VatSummaryCard extends StatelessWidget {
  final SellerInvoicesController ctrl;
  const _VatSummaryCard({required this.ctrl});

  String _fmt(int v) {
    if (v >= 1000000) return 'SP ${(v / 1000000).toStringAsFixed(1)}م';
    if (v >= 1000)    return 'SP ${v ~/ 1000}k';
    return 'SP $v';
  }

  @override
  Widget build(BuildContext context) {
    final report = ctrl.currentReport!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff7D4900), Color(0xffF39C12)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(
          color: AppColor.warning.withOpacity(0.35),
          blurRadius: 18, offset: const Offset(0, 7),
        )],
      ),
      child: Column(children: [
        // Top row
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(report.monthLabel,
                  style: AppTextStyle.labelMedium.copyWith(
                      color: Colors.white70, fontSize: 11)),
              const SizedBox(height: 3),
              Text('إجمالي المبيعات الخاضعة للضريبة',
                  style: AppTextStyle.labelSmall.copyWith(
                      color: Colors.white60, fontSize: 10)),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(_fmt(report.totalSales),
                    style: AppTextStyle.priceLarge.copyWith(
                        color: Colors.white, fontSize: 26)),
              ),
            ]),
          ),
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: Colors.white70, size: 26),
          ),
        ]),

        Container(margin: const EdgeInsets.symmetric(vertical: 14),
            height: 1, color: Colors.white.withOpacity(0.2)),

        // Stats row
        Row(children: [
          _VatStat(
            label: 'ضريبة القيمة المضافة',
            value: _fmt(report.totalVat),
            icon: Icons.percent_rounded,
          ),
          Container(width: 1, height: 40,
              color: Colors.white.withOpacity(0.2),
              margin: const EdgeInsets.symmetric(horizontal: 4)),
          _VatStat(
            label: 'فواتير صادرة',
            value: '${report.invoiceCount}',
            icon: Icons.description_outlined,
          ),
          if (report.cancelledCount > 0) ...[
            Container(width: 1, height: 40,
                color: Colors.white.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(horizontal: 4)),
            _VatStat(
              label: 'ملغاة',
              value: '${report.cancelledCount}',
              icon: Icons.cancel_outlined,
              accent: Colors.redAccent.shade100,
            ),
          ],
        ]),

        const SizedBox(height: 14),

        // Download button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: ctrl.isDownloadingReport ? null : ctrl.downloadMonthlyReport,
            icon: ctrl.isDownloadingReport
                ? const SizedBox(width: 15, height: 15,
                    child: CircularProgressIndicator(
                        color: AppColor.warning, strokeWidth: 2))
                : const Icon(Icons.download_rounded,
                    size: 16, color: AppColor.warning),
            label: Text(
              ctrl.isDownloadingReport
                  ? 'جاري التحضير...'
                  : 'تحميل التقرير الشهري (PDF)',
              style: AppTextStyle.buttonMedium.copyWith(
                  color: AppColor.warning, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              disabledBackgroundColor: Colors.white.withOpacity(0.7),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ]),
    );
  }
}

class _VatStat extends StatelessWidget {
  final String   label;
  final String   value;
  final IconData icon;
  final Color?   accent;
  const _VatStat({
    required this.label, required this.value,
    required this.icon,  this.accent,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 11, color: Colors.white60),
        const SizedBox(width: 3),
        Flexible(
          child: Text(label,
              style: AppTextStyle.labelSmall.copyWith(
                  color: Colors.white60, fontSize: 9.5),
              textAlign: TextAlign.center,
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ]),
      const SizedBox(height: 4),
      Text(value,
          style: AppTextStyle.statNumberSmall.copyWith(
              color: accent ?? Colors.white, fontSize: 17)),
    ]),
  );
}

// ════════════════════════════════════════════════════════════
// Invoices Section Header + Filter
// ════════════════════════════════════════════════════════════

class _InvoicesSectionHeader extends StatelessWidget {
  final SellerInvoicesController ctrl;
  const _InvoicesSectionHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: AppColor.primarySurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.receipt_outlined,
              size: 14, color: AppColor.primaryColor),
        ),
        const SizedBox(width: 8),
        Text('الفواتير', style: AppTextStyle.heading3.copyWith(fontSize: 14)),
        const Spacer(),
        Text(
          '${ctrl.filteredInvoices.length} فاتورة',
          style: AppTextStyle.labelSmall.copyWith(
              color: AppColor.primaryColor, fontWeight: FontWeight.w700),
        ),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _StatusChip(
          label: 'الكل',
          isSelected: ctrl.filterStatus == 'all',
          onTap: () => ctrl.setFilterStatus('all'),
        ),
        const SizedBox(width: 8),
        _StatusChip(
          label: 'صادرة',
          isSelected: ctrl.filterStatus == 'issued',
          activeColor: AppColor.success,
          onTap: () => ctrl.setFilterStatus('issued'),
        ),
        const SizedBox(width: 8),
        _StatusChip(
          label: 'ملغاة',
          isSelected: ctrl.filterStatus == 'cancelled',
          activeColor: AppColor.error,
          onTap: () => ctrl.setFilterStatus('cancelled'),
        ),
      ]),
    ],
  );
}

class _StatusChip extends StatelessWidget {
  final String     label;
  final bool       isSelected;
  final Color?     activeColor;
  final VoidCallback onTap;
  const _StatusChip({
    required this.label, required this.isSelected,
    required this.onTap, this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final ac = activeColor ?? AppColor.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? ac : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? ac : AppColor.greyBorder),
          boxShadow: isSelected ? AppColor.cardShadow : null,
        ),
        child: Text(label,
            style: AppTextStyle.chip.copyWith(
              color: isSelected ? Colors.white : AppColor.grey,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            )),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Invoice Card
// ════════════════════════════════════════════════════════════

class _InvoiceCard extends StatefulWidget {
  final InvoiceModel invoice;
  final int index;
  final SellerInvoicesController ctrl;
  const _InvoiceCard({
    required this.invoice, required this.index, required this.ctrl,
  });

  @override
  State<_InvoiceCard> createState() => _InvoiceCardState();
}

class _InvoiceCardState extends State<_InvoiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fade  = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 50 + widget.index * 60), () {
      if (mounted) _anim.forward();
    });
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  String _fmt(int v) => v >= 1000 ? 'SP ${v ~/ 1000}k' : 'SP $v';

  @override
  Widget build(BuildContext context) {
    final inv          = widget.invoice;
    final isDownloading = widget.ctrl.downloadingIds.contains(inv.id);

    final statusBg   = inv.isCancelled ? AppColor.errorLight   : AppColor.successLight;
    final statusText = inv.isCancelled ? AppColor.errorDark    : AppColor.successDark;
    final statusLabel= inv.isCancelled ? 'ملغاة'              : 'صادرة';

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColor.cardShadow,
            border: Border.all(
              color: inv.isCancelled
                  ? AppColor.error.withOpacity(0.15) : AppColor.greyBorder,
              width: 0.8,
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Header ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColor.warningLight,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.receipt_long_rounded,
                      size: 20, color: AppColor.warning),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(inv.invoiceNumber,
                          style: AppTextStyle.orderNumber.copyWith(fontSize: 13)),
                      Text(inv.issuedAt,
                          style: AppTextStyle.timestamp.copyWith(fontSize: 10)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(statusLabel,
                      style: AppTextStyle.chip.copyWith(
                          color: statusText, fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
              ]),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Divider(height: 14, color: AppColor.greyBorder),
            ),

            // ── Order + Buyer ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColor.primarySurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(inv.orderId?.toString() ?? inv.invoiceNumber,
                      style: AppTextStyle.orderNumber.copyWith(
                          color: AppColor.primaryColor, fontSize: 10)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.person_outline, size: 12, color: AppColor.greyLight),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(inv.buyerName,
                      style: AppTextStyle.labelMedium.copyWith(fontSize: 12),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ]),
            ),
            const SizedBox(height: 10),

            // ── Price Breakdown ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColor.secondBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColor.greyBorder, width: 0.5),
                ),
                child: Row(children: [
                   _PriceCol(label: 'قبل الضريبة', value: _fmt(inv.subtotal.round())),
                  Container(width: 1, height: 30,
                      color: AppColor.greyBorder,
                      margin: const EdgeInsets.symmetric(horizontal: 8)),
                  _PriceCol(
                    label: 'الضريبة (${inv.vatAmount > 0 ? ((inv.vatAmount / (inv.subtotal > 0 ? inv.subtotal : 1)) * 100).round().toString() : "0"}%)',
                    value: '+${_fmt(inv.vatAmount.round())}',
                    valueColor: AppColor.warning,
                  ),
                  Container(width: 1, height: 30,
                      color: AppColor.greyBorder,
                      margin: const EdgeInsets.symmetric(horizontal: 8)),
                  _PriceCol(
                    label: 'الإجمالي',
                    value: _fmt(inv.total.round()),
                    valueColor: AppColor.primaryColor,
                    bold: true,
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 8),

            // ── Commission Note ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded,
                    size: 11, color: AppColor.greyLight),
                const SizedBox(width: 4),
                Text(
                  'عمولة المنصة (${inv.commissionAmount > 0 ? ((inv.commissionAmount / (inv.subtotal > 0 ? inv.subtotal : 1)) * 100).round() : 10}%): ${_fmt(inv.commissionAmount.round())} — تُخصم تلقائياً من المحفظة',
                  style: AppTextStyle.labelSmall.copyWith(
                      color: AppColor.greyLight, fontSize: 10),
                ),
              ]),
            ),
            const SizedBox(height: 10),

            // ── Download Button ────────────────────────────
            if (!inv.isCancelled)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: SizedBox(
                  width: double.infinity, height: 38,
                  child: OutlinedButton.icon(
                    onPressed: isDownloading
                        ? null : () => widget.ctrl.downloadInvoicePdf(inv),
                    icon: isDownloading
                        ? const SizedBox(width: 14, height: 14,
                            child: CircularProgressIndicator(
                                color: AppColor.primaryColor, strokeWidth: 2))
                        : const Icon(Icons.download_rounded,
                            size: 16, color: AppColor.primaryColor),
                    label: Text(
                      isDownloading ? 'جاري التحضير...' : 'تحميل الفاتورة PDF',
                      style: AppTextStyle.chip.copyWith(
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColor.primaryColor, width: 1.2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 12),
          ]),
        ),
      ),
    );
  }
}

class _PriceCol extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool   bold;
  const _PriceCol({
    required this.label, required this.value,
    this.valueColor, this.bold = false,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(label,
          style: AppTextStyle.labelSmall.copyWith(fontSize: 9),
          textAlign: TextAlign.center),
      const SizedBox(height: 3),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(value,
            style: AppTextStyle.price.copyWith(
              color: valueColor ?? AppColor.black,
              fontSize: bold ? 13 : 11,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            )),
      ),
    ]),
  );
}

// ════════════════════════════════════════════════════════════
// Empty State
// ════════════════════════════════════════════════════════════

class _EmptyInvoices extends StatelessWidget {
  final bool hasFilter;
  const _EmptyInvoices({required this.hasFilter});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(children: [
      Icon(
        hasFilter ? Icons.filter_list_off_rounded : Icons.receipt_long_outlined,
        size: 58, color: AppColor.greyLight,
      ),
      const SizedBox(height: 12),
      Text(
        hasFilter ? 'لا توجد فواتير بهذه الحالة' : 'لا توجد فواتير بعد',
        style: AppTextStyle.heading3.copyWith(color: AppColor.grey),
      ),
      const SizedBox(height: 6),
      Text(
        hasFilter
            ? 'جرّب تغيير الفلتر'
            : 'تُنشأ الفواتير تلقائياً عند اكتمال الطلبات',
        style: AppTextStyle.bodyMedium,
        textAlign: TextAlign.center,
      ),
    ]),
  );
}

// ════════════════════════════════════════════════════════════
// Shimmer Loading
// ════════════════════════════════════════════════════════════

class _InvoicesShimmer extends StatelessWidget {
  const _InvoicesShimmer();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Tax settings shimmer
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColor.cardShadow,
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              ShimmerBox(width: 32, height: 32, radius: 9),
              SizedBox(width: 10),
              ShimmerBox(width: 130, height: 14),
              Spacer(),
              ShimmerBox(width: 55, height: 28, radius: 9),
            ]),
            Divider(height: 16, color: AppColor.greyBorder),
            ShimmerBox(width: double.infinity, height: 10),
            SizedBox(height: 8),
            ShimmerBox(width: 200, height: 10),
            SizedBox(height: 8),
            ShimmerBox(width: 170, height: 10),
          ],
        ),
      ),
      const SizedBox(height: 18),

      // Month selector shimmer
      Row(children: List.generate(4, (_) => const Padding(
        padding: EdgeInsets.only(right: 8),
        child: ShimmerBox(width: 70, height: 34, radius: 20),
      ))),
      const SizedBox(height: 10),

      // VAT summary shimmer
      ShimmerBox(
        width: double.infinity, height: 195,
        radius: 18,
      ),
      const SizedBox(height: 18),

      // Invoice cards shimmer
      ...List.generate(3, (_) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          height: 155,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColor.cardShadow,
          ),
          padding: const EdgeInsets.all(14),
          child: const Column(children: [
            Row(children: [
              ShimmerBox(width: 40, height: 40, radius: 11),
              SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ShimmerBox(width: 130, height: 13),
                SizedBox(height: 5),
                ShimmerBox(width: 90, height: 10),
              ])),
              ShimmerBox(width: 48, height: 24, radius: 12),
            ]),
            Divider(height: 14, color: AppColor.greyBorder),
            ShimmerBox(width: double.infinity, height: 50, radius: 10),
          ]),
        ),
      )),
    ]),
  );
}
