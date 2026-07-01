import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_ads_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/ads_models.dart';
import 'package:e_commerce/data/model/seller/inventory_models.dart';
import 'package:e_commerce/view/widget/seller/dashboard/shimmer_box.dart';


class AdsScreen extends StatelessWidget {
  const AdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SellerAdsController());
    return GetBuilder<SellerAdsController>(
      builder: (ctrl) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        appBar: _AdsAppBar(ctrl: ctrl),
        body: ctrl.statusRequest == StatusRequest.loading
            ? const _AdsShimmer()
            : RefreshIndicator(
                onRefresh: ctrl.loadAds,
                color: AppColor.primaryColor,
                backgroundColor: Colors.white,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _WalletBanner(ctrl: ctrl),
                    ),
                    if (ctrl.pendingCount > 0)
                      SliverToBoxAdapter(
                        child: _PendingNotice(count: ctrl.pendingCount),
                      ),
                    SliverToBoxAdapter(
                      child: _TabsRow(ctrl: ctrl),
                    ),
                    ctrl.filteredAds.isEmpty
                        ? SliverFillRemaining(
                            child: _EmptyAds(
                                onNew: () => _openCreateSheet(context, ctrl)),
                          )
                        : SliverPadding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (_, i) => _AdCard(
                                  ad: ctrl.filteredAds[i],
                                  index: i,
                                ),
                                childCount: ctrl.filteredAds.length,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openCreateSheet(context, ctrl),
          backgroundColor: AppColor.primaryColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text('إعلان جديد',
              style: AppTextStyle.buttonSmall),
        ),
      ),
    );
  }

  void _openCreateSheet(BuildContext context, SellerAdsController ctrl) {
    ctrl.resetForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateAdSheet(),
    );
  }
}


class _AdsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SellerAdsController ctrl;
  const _AdsAppBar({required this.ctrl});

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
        title:
            Text('الرعاية والإعلانات', style: AppTextStyle.appBarTitle),
        centerTitle: true,
        actions: [
          if (ctrl.activeCount > 0)
            Container(
              margin: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${ctrl.activeCount} نشط',
                style: AppTextStyle.chip.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11),
              ),
            ),
        ],
      );
}


class _WalletBanner extends StatelessWidget {
  final SellerAdsController ctrl;
  const _WalletBanner({required this.ctrl});

  String _fmt(int v) =>
      v >= 1000 ? 'SP ${(v / 1000).toStringAsFixed(0)}k' : 'SP $v';

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff1B5E20), Color(0xff27AE60)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColor.success.withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(children: [
          const Icon(Icons.account_balance_wallet_outlined,
              color: Colors.white70, size: 20),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('رصيد الإعلانات المتاح',
                style: AppTextStyle.labelSmall
                    .copyWith(color: Colors.white60, fontSize: 10)),
            Text(_fmt(ctrl.walletBalance),
                style: AppTextStyle.price
                    .copyWith(color: Colors.white, fontSize: 18)),
          ]),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text('إضافة رصيد',
                style: AppTextStyle.chip.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ]),
      );
}


class _PendingNotice extends StatelessWidget {
  final int count;
  const _PendingNotice({required this.count});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColor.warningLight,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColor.warning.withOpacity(0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.hourglass_top_rounded,
              size: 16, color: AppColor.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$count إعلان قيد المراجعة — سيُفعَّل خلال ساعات قليلة',
              style: AppTextStyle.labelSmall.copyWith(
                  color: AppColor.warningDark, fontSize: 11),
            ),
          ),
        ]),
      );
}


class _TabsRow extends StatelessWidget {
  final SellerAdsController ctrl;
  const _TabsRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ('all', 'الكل', null),
      ('active', 'نشط', AppColor.success),
      ('pending', 'قيد المراجعة', AppColor.warning),
      ('expired', 'منتهي', AppColor.grey),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((t) {
            final isActive = ctrl.selectedTab == t.$1;
            final color = t.$3 ?? AppColor.primaryColor;
            return GestureDetector(
              onTap: () => ctrl.changeTab(t.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? color : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? color : AppColor.greyBorder,
                    width: isActive ? 1.5 : 1,
                  ),
                  boxShadow: isActive ? AppColor.cardShadow : null,
                ),
                child: Text(t.$2,
                    style: AppTextStyle.chip.copyWith(
                      color:
                          isActive ? Colors.white : AppColor.grey,
                      fontWeight: isActive
                          ? FontWeight.w700
                          : FontWeight.w500,
                    )),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


class _AdCard extends StatefulWidget {
  final AdModel ad;
  final int index;
  const _AdCard({required this.ad, required this.index});

  @override
  State<_AdCard> createState() => _AdCardState();
}

class _AdCardState extends State<_AdCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.index * 70),
        () => mounted ? _ctrl.forward() : null);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.ad.status) {
      case AdStatus.active:
        return AppColor.success;
      case AdStatus.pending:
        return AppColor.warning;
      case AdStatus.rejected:
        return AppColor.error;
      case AdStatus.expired:
        return AppColor.grey;
      case AdStatus.paused:
        return AppColor.info;
    }
  }

  Color get _statusBg {
    switch (widget.ad.status) {
      case AdStatus.active:
        return AppColor.successLight;
      case AdStatus.pending:
        return AppColor.warningLight;
      case AdStatus.rejected:
        return AppColor.errorLight;
      case AdStatus.expired:
        return AppColor.secondBackground;
      case AdStatus.paused:
        return AppColor.infoLight;
    }
  }

  IconData get _typeIcon {
    switch (widget.ad.adType) {
      case 'banner':
        return Icons.view_carousel_outlined;
      case 'product':
        return Icons.inventory_2_outlined;
      case 'store':
        return Icons.storefront_outlined;
      case 'notification':
        return Icons.notifications_outlined;
      default:
        return Icons.campaign_outlined;
    }
  }

  String get _typeName {
    switch (widget.ad.adType) {
      case 'banner':
        return 'بانر رئيسي';
      case 'product':
        return 'منتج معزَّز';
      case 'store':
        return 'متجر مميز';
      case 'notification':
        return 'إشعار مُدفوع';
      default:
        return 'إعلان';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColor.cardShadow,
            border: Border.all(
              color: ad.status == AdStatus.active
                  ? AppColor.success.withOpacity(0.2)
                  : AppColor.greyBorder,
              width: ad.status == AdStatus.active ? 1.2 : 0.8,
            ),
          ),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColor.primarySurface,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(_typeIcon,
                      size: 20, color: AppColor.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(ad.title,
                          style: AppTextStyle.labelLarge
                              .copyWith(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Row(children: [
                        Text(_typeName,
                            style: AppTextStyle.labelSmall
                                .copyWith(fontSize: 11)),
                        const Text(' · ',
                            style: TextStyle(
                                color: AppColor.greyLight,
                                fontSize: 11)),
                        Text('${ad.durationDays} يوم',
                            style: AppTextStyle.labelSmall
                                .copyWith(fontSize: 11)),
                      ]),
                    ])),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(ad.status.label,
                      style: AppTextStyle.chip.copyWith(
                          color: _statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 10)),
                ),
              ]),
            ),

            if (ad.status == AdStatus.rejected &&
                ad.rejectionReason != null)
              Container(
                margin:
                    const EdgeInsets.fromLTRB(14, 0, 14, 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColor.errorLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 14, color: AppColor.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(ad.rejectionReason!,
                        style: AppTextStyle.labelSmall.copyWith(
                            color: AppColor.errorDark,
                            fontSize: 11)),
                  ),
                ]),
              ),

            if (ad.status == AdStatus.active ||
                ad.status == AdStatus.expired)
              Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColor.secondBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatChip(
                          icon: Icons.remove_red_eye_outlined,
                          value:
                              '${_fmtNum(ad.impressions)}',
                          label: 'مشاهدة',
                          color: AppColor.info),
                      Container(
                          width: 1,
                          height: 28,
                          color: AppColor.greyBorder),
                      _StatChip(
                          icon: Icons.touch_app_outlined,
                          value: '${_fmtNum(ad.clicks)}',
                          label: 'نقرة',
                          color: AppColor.primaryColor),
                      Container(
                          width: 1,
                          height: 28,
                          color: AppColor.greyBorder),
                      _StatChip(
                          icon: Icons.percent_rounded,
                          value:
                              '${ad.ctr.toStringAsFixed(1)}%',
                          label: 'نسبة النقر',
                          color: AppColor.success),
                    ]),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التكلفة: SP ${(ad.totalCost / 1000).toStringAsFixed(0)}k',
                      style: AppTextStyle.price
                          .copyWith(fontSize: 13),
                    ),
                    if (ad.startDate.isNotEmpty)
                      Text(
                        '${ad.startDate} — ${ad.endDate}',
                        style: AppTextStyle.timestamp
                            .copyWith(fontSize: 10),
                      )
                    else
                      Text(
                        ad.createdAt,
                        style: AppTextStyle.timestamp
                            .copyWith(fontSize: 10),
                      ),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }

  String _fmtNum(int v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : '$v';
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _StatChip(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) => Column(children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 3),
          Text(value,
              style: AppTextStyle.statNumberSmall.copyWith(
                  fontSize: 14, color: AppColor.black)),
        ]),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyle.statLabel.copyWith(fontSize: 10)),
      ]);
}


class _EmptyAds extends StatelessWidget {
  final VoidCallback onNew;
  const _EmptyAds({required this.onNew});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
                color: AppColor.primarySurface,
                shape: BoxShape.circle),
            child: const Icon(Icons.campaign_outlined,
                size: 34, color: AppColor.primaryColor),
          ),
          const SizedBox(height: 14),
          Text('لا توجد إعلانات بعد',
              style: AppTextStyle.heading3
                  .copyWith(color: AppColor.grey)),
          const SizedBox(height: 6),
          Text('ابدأ بإنشاء إعلانك الأول للوصول لأكثر المشترين',
              style: AppTextStyle.bodyMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onNew,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text('إنشاء إعلان',
                style: AppTextStyle.buttonMedium),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12)),
          ),
        ]),
      );
}


class _CreateAdSheet extends StatelessWidget {
  const _CreateAdSheet();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SellerAdsController>(
      builder: (ctrl) => Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppColor.greyBorder,
                borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(children: [
              if (ctrl.currentStep > 0)
                GestureDetector(
                  onTap: ctrl.prevStep,
                  child: Container(
                    width: 34,
                    height: 34,
                    margin: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: AppColor.secondBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_rounded,
                        size: 16, color: AppColor.grey),
                  ),
                ),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                    ctrl.currentStep == 0
                        ? 'اختر نوع الإعلان'
                        : ctrl.currentStep == 1
                            ? 'تفاصيل الإعلان'
                            : 'مراجعة وتأكيد',
                    style: AppTextStyle.heading3,
                  ),
                  Text(
                    'الخطوة ${ctrl.currentStep + 1} من 3',
                    style: AppTextStyle.labelSmall,
                  ),
                ]),
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.close_rounded,
                    color: AppColor.grey, size: 22),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 12, horizontal: 20),
            child: Row(children: List.generate(3, (i) {
              final done = i < ctrl.currentStep;
              final current = i == ctrl.currentStep;
              return Expanded(
                child: Row(children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 4,
                      decoration: BoxDecoration(
                        color: done || current
                            ? AppColor.primaryColor
                            : AppColor.greyBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (i < 2) const SizedBox(width: 6),
                ]),
              );
            })),
          ),
          const Divider(height: 1, color: AppColor.greyBorder),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: ctrl.currentStep == 0
                  ? _StepType(ctrl: ctrl)
                  : ctrl.currentStep == 1
                      ? _StepDetails(ctrl: ctrl)
                      : _StepReview(ctrl: ctrl),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
                20,
                10,
                20,
                MediaQuery.of(context).padding.bottom + 12),
            decoration: BoxDecoration(
                color: Colors.white, boxShadow: AppColor.bottomNavShadow),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: ctrl.currentStep < 2
                    ? ctrl.nextStep
                    : (ctrl.submitStatus == StatusRequest.loading
                        ? null
                        : ctrl.submitAd),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: ctrl.submitStatus == StatusRequest.loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Text(
                        ctrl.currentStep < 2
                            ? 'التالي'
                            : 'تأكيد ودفع',
                        style: AppTextStyle.buttonLarge),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _StepType extends StatelessWidget {
  final SellerAdsController ctrl;
  const _StepType({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final types = AdTypeModel.all();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ما الذي تريد الإعلان عنه؟',
            style: AppTextStyle.labelLarge.copyWith(fontSize: 14)),
        const SizedBox(height: 4),
        Text('اختر نوع الإعلان المناسب لهدفك',
            style: AppTextStyle.bodySmall),
        const SizedBox(height: 16),
        ...types.map((t) => _AdTypeCard(
            type: t,
            isSelected: ctrl.selectedAdType == t.id,
            onTap: () => ctrl.selectAdType(t.id))),
      ],
    );
  }
}

class _AdTypeCard extends StatelessWidget {
  final AdTypeModel type;
  final bool isSelected;
  final VoidCallback onTap;
  const _AdTypeCard(
      {required this.type,
      required this.isSelected,
      required this.onTap});

  IconData get _icon {
    switch (type.id) {
      case 'banner':
        return Icons.view_carousel_outlined;
      case 'product':
        return Icons.inventory_2_outlined;
      case 'store':
        return Icons.storefront_outlined;
      case 'notification':
        return Icons.notifications_outlined;
      default:
        return Icons.campaign_outlined;
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColor.primarySurface
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColor.primaryColor
                  : AppColor.greyBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColor.primaryColor
                    : AppColor.secondBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon,
                  size: 22,
                  color: isSelected
                      ? Colors.white
                      : AppColor.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(type.title,
                      style: AppTextStyle.labelLarge.copyWith(
                          color: isSelected
                              ? AppColor.primaryColor
                              : AppColor.black,
                          fontSize: 14)),
                  const SizedBox(height: 3),
                  Text(type.description,
                      style: AppTextStyle.bodySmall
                          .copyWith(fontSize: 11.5)),
                  const SizedBox(height: 5),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 11, color: AppColor.grey),
                    const SizedBox(width: 3),
                    Text(type.placement,
                        style: AppTextStyle.labelSmall
                            .copyWith(fontSize: 10)),
                  ]),
                ])),
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('من',
                      style: AppTextStyle.labelSmall
                          .copyWith(fontSize: 9)),
                  Text(
                    'SP ${(type.pricing['1']! ~/ 1000)}k',
                    style: AppTextStyle.price.copyWith(fontSize: 13),
                  ),
                  Text('/ يوم',
                      style: AppTextStyle.labelSmall
                          .copyWith(fontSize: 9)),
                ]),
          ]),
        ),
      );
}

class _StepDetails extends StatelessWidget {
  final SellerAdsController ctrl;
  const _StepDetails({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final durations = AdDurationOption.all();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (ctrl.selectedAdType == 'product') ...[
        Text('المنتج المُعلَن عنه',
            style: AppTextStyle.inputLabel),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColor.secondBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.greyBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<int>(
                value: ctrl.selectedProductId,
                isExpanded: true,
                hint: Text('اختر المنتج', style: AppTextStyle.inputHint),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColor.grey),
                borderRadius: BorderRadius.circular(12),
                items: ctrl.products
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name,
                              style: AppTextStyle.inputText),
                        ))
                    .toList(),
                onChanged: (id) {
                  if (id != null) {
                    final p = ctrl.products
                        .firstWhere((p) => p.id == id);
                    ctrl.selectProduct(p);
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],

      Text('عنوان الإعلان *', style: AppTextStyle.inputLabel),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl.titleCtrl,
        style: AppTextStyle.inputText,
        decoration: InputDecoration(
          hintText: 'مثال: تخفيض 30% على المنتجات اليدوية',
          hintStyle: AppTextStyle.inputHint,
          filled: true,
          fillColor: AppColor.secondBackground,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.greyBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.greyBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColor.primaryColor, width: 1.5)),
        ),
      ),
      const SizedBox(height: 14),

      Text('نص الإعلان (اختياري)', style: AppTextStyle.inputLabel),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl.descCtrl,
        maxLines: 3,
        style: AppTextStyle.inputText,
        decoration: InputDecoration(
          hintText:
              'وصف مختصر يظهر تحت العنوان...',
          hintStyle: AppTextStyle.inputHint,
          filled: true,
          fillColor: AppColor.secondBackground,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.greyBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.greyBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColor.primaryColor, width: 1.5)),
        ),
      ),
      const SizedBox(height: 18),

      Text('مدة الإعلان', style: AppTextStyle.inputLabel),
      const SizedBox(height: 8),
      ...durations.map((d) {
        final price =
            ctrl.currentAdType.pricing[d.key] ?? 0;
        final isSelected = ctrl.selectedDuration == d.key;
        return GestureDetector(
          onTap: () => ctrl.selectDuration(d.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColor.primarySurface
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColor.primaryColor
                    : AppColor.greyBorder,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColor.primaryColor
                        : AppColor.greyLight,
                    width: isSelected ? 5 : 2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Row(children: [
                Text(d.label,
                    style: AppTextStyle.labelLarge.copyWith(
                        fontSize: 13,
                        color: isSelected
                            ? AppColor.primaryColor
                            : AppColor.black)),
                if (d.popular) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('الأشهر',
                        style: AppTextStyle.badge
                            .copyWith(fontSize: 8)),
                  ),
                ],
              ])),
              Text(
                'SP ${(price ~/ 1000)}k',
                style: AppTextStyle.price.copyWith(fontSize: 14),
              ),
            ]),
          ),
        );
      }),
    ]);
  }
}

class _StepReview extends StatelessWidget {
  final SellerAdsController ctrl;
  const _StepReview({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final price = ctrl.computedPrice;
    final canAfford = ctrl.canAfford;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('مراجعة تفاصيل الإعلان',
          style: AppTextStyle.labelLarge.copyWith(fontSize: 14)),
      const SizedBox(height: 14),

      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.secondBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColor.greyBorder),
        ),
        child: Column(children: [
          _ReviewRow(
              label: 'نوع الإعلان',
              value: ctrl.currentAdType.title),
          _ReviewRow(
              label: 'العنوان',
              value: ctrl.titleCtrl.text.trim().isEmpty
                  ? '—'
                  : ctrl.titleCtrl.text.trim()),
          if (ctrl.selectedAdType == 'product' &&
              ctrl.selectedProductName != null)
            _ReviewRow(
                label: 'المنتج',
                value: ctrl.selectedProductName!),
          _ReviewRow(
              label: 'المدة',
              value:
                  '${ctrl.selectedDuration} يوم'),
          _ReviewRow(
              label: 'مكان الظهور',
              value: ctrl.currentAdType.placement),
        ]),
      ),
      const SizedBox(height: 14),

      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: canAfford
                ? [
                    const Color(0xff1B5E20),
                    const Color(0xff27AE60)
                  ]
                : [AppColor.errorDark, AppColor.error],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('إجمالي التكلفة',
                    style: AppTextStyle.labelMedium
                        .copyWith(color: Colors.white70)),
                Text(
                  'SP ${(price / 1000).toStringAsFixed(0)}k',
                  style: AppTextStyle.priceLarge
                      .copyWith(color: Colors.white, fontSize: 22),
                ),
              ]),
          const SizedBox(height: 8),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('رصيد المحفظة',
                    style: AppTextStyle.labelSmall
                        .copyWith(color: Colors.white60)),
                Text(
                  'SP ${(ctrl.walletBalance / 1000).toStringAsFixed(0)}k',
                  style: AppTextStyle.labelMedium
                      .copyWith(color: Colors.white70),
                ),
              ]),
          if (!canAfford) ...[
            const Divider(color: Colors.white24, height: 14),
            Row(children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 14, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                'رصيدك غير كافٍ — يرجى إضافة رصيد للمتابعة',
                style: AppTextStyle.labelSmall
                    .copyWith(color: Colors.white70, fontSize: 10),
              ),
            ]),
          ],
        ]),
      ),
      const SizedBox(height: 14),

      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColor.infoLight,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColor.info.withOpacity(0.2)),
        ),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 15, color: AppColor.info),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'إعلانك سيخضع للمراجعة من قِبل الإدارة قبل النشر. '
                  'يُفعَّل عادةً خلال 2-6 ساعات.',
                  style: AppTextStyle.labelSmall.copyWith(
                      color: AppColor.infoDark, fontSize: 11),
                ),
              ),
            ]),
      ),
    ]);
  }
}

class _ReviewRow extends StatelessWidget {
  final String label, value;
  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: AppTextStyle.bodySmall
                      .copyWith(fontSize: 12)),
              Text(value,
                  style: AppTextStyle.labelLarge
                      .copyWith(fontSize: 13)),
            ]),
      );
}


class _AdsShimmer extends StatelessWidget {
  const _AdsShimmer();

  @override
  Widget build(BuildContext context) => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          height: 110,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColor.cardShadow,
          ),
          child: Row(children: [
            const ShimmerBox(width: 42, height: 42, radius: 11),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    ShimmerBox(width: 150, height: 13),
                    SizedBox(height: 7),
                    ShimmerBox(width: 100, height: 10),
                    SizedBox(height: 12),
                    ShimmerBox(width: double.infinity, height: 28, radius: 10),
                  ]),
            ),
          ]),
        ),
      );
}
