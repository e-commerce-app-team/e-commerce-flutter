import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_commerce/controller/seller/seller_ads_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/data/model/seller/ads_models.dart';
import 'package:e_commerce/view/widget/seller/dashboard/shimmer_box.dart';

// ═══════════════════════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════════════════════

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
            : ctrl.statusRequest == StatusRequest.failure
                ? _ErrorState(onRetry: ctrl.loadAds)
                : RefreshIndicator(
                    onRefresh: ctrl.loadAds,
                    color: AppColor.primaryColor,
                    backgroundColor: AppColor.backgroundcolor,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // ─── Wallet Banner ───────────────────────────────────
                        SliverToBoxAdapter(
                          child: _WalletBanner(ctrl: ctrl),
                        ),

                        // ─── Pending Notice ──────────────────────────────────
                        if (ctrl.pendingCount > 0)
                          SliverToBoxAdapter(
                            child: _PendingNotice(count: ctrl.pendingCount),
                          ),

                        // ─── Filter Tabs ─────────────────────────────────────
                        SliverToBoxAdapter(
                          child: _TabsRow(ctrl: ctrl),
                        ),

                        // ─── Content ─────────────────────────────────────────
                        ctrl.filteredAds.isEmpty
                            ? SliverFillRemaining(
                                hasScrollBody: false,
                                child: _EmptyAds(
                                    onNew: () =>
                                        _openCreateSheet(context, ctrl)),
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
        floatingActionButton: _CreateFAB(
            onTap: () => _openCreateSheet(context, ctrl)),
      ),
    );
  }

  void _openCreateSheet(BuildContext context, SellerAdsController ctrl) {
    ctrl.resetForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      builder: (_) => const _CreateAdSheet(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// APP BAR
// ═══════════════════════════════════════════════════════════════

class _AdsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SellerAdsController ctrl;
  const _AdsAppBar({required this.ctrl});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColor.headerGradient)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text('ads_title'.tr, style: AppTextStyle.appBarTitle),
        centerTitle: true,
        actions: [
          if (ctrl.activeCount > 0)
            Container(
              margin: const EdgeInsets.only(left: 12, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.35)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '${ctrl.activeCount} ${'ads_active_count'.tr}',
                  style: AppTextStyle.chip.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                ),
              ]),
            ),
        ],
      );
}

// ═══════════════════════════════════════════════════════════════
// WALLET BANNER
// ═══════════════════════════════════════════════════════════════

class _WalletBanner extends StatelessWidget {
  final SellerAdsController ctrl;
  const _WalletBanner({required this.ctrl});

  String _fmt(int v) => v >= 1000 ? 'SP ${(v / 1000).toStringAsFixed(0)}k' : 'SP $v';

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff1B5E20), Color(0xff2E7D32), Color(0xff27AE60)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColor.success.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Stack(children: [
          // Background pattern
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 10,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('ads_wallet_label'.tr,
                      style: AppTextStyle.labelSmall.copyWith(
                          color: Colors.white60, fontSize: 10, letterSpacing: 0.3)),
                  const SizedBox(height: 3),
                  Text(_fmt(ctrl.walletBalance),
                      style: AppTextStyle.price.copyWith(
                          color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                ]),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoute.sellerWallet);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.35)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.add_rounded, color: Colors.white, size: 15),
                    const SizedBox(width: 4),
                    Text('ads_add_balance'.tr,
                        style: AppTextStyle.chip.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                  ]),
                ),
              ),
            ]),
          ),
        ]),
      );
}

// ═══════════════════════════════════════════════════════════════
// PENDING NOTICE
// ═══════════════════════════════════════════════════════════════

class _PendingNotice extends StatelessWidget {
  final int count;
  const _PendingNotice({required this.count});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColor.warningLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.warning.withOpacity(0.35)),
        ),
        child: Row(children: [
          const Icon(Icons.hourglass_top_rounded, size: 16, color: AppColor.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              count == 1 ? 'ads_pending_notice'.tr : 'ads_pending_notice_pl'.tr,
              style: AppTextStyle.labelSmall
                  .copyWith(color: AppColor.warningDark, fontSize: 11.5),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColor.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: AppTextStyle.labelLarge.copyWith(
                  color: AppColor.warningDark, fontSize: 12),
            ),
          ),
        ]),
      );
}

// ═══════════════════════════════════════════════════════════════
// FILTER TABS
// ═══════════════════════════════════════════════════════════════

class _TabsRow extends StatelessWidget {
  final SellerAdsController ctrl;
  const _TabsRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ('all', 'ads_tab_all', null, Icons.apps_rounded),
      ('active', 'ads_tab_active', AppColor.success, Icons.check_circle_outline_rounded),
      ('pending', 'ads_tab_pending', AppColor.warning, Icons.hourglass_top_rounded),
      ('expired', 'ads_tab_expired', AppColor.grey, Icons.schedule_rounded),
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
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? color : AppColor.backgroundcolor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isActive ? color : AppColor.greyBorder,
                    width: isActive ? 1.5 : 1,
                  ),
                  boxShadow: isActive ? AppColor.cardShadow : null,
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(t.$4, size: 13,
                      color: isActive ? Colors.white : AppColor.grey),
                  const SizedBox(width: 5),
                  Text(t.$2.tr,
                      style: AppTextStyle.chip.copyWith(
                        color: isActive ? Colors.white : AppColor.grey,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12,
                      )),
                ]),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// AD CARD
// ═══════════════════════════════════════════════════════════════

class _AdCard extends StatefulWidget {
  final AdModel ad;
  final int index;
  const _AdCard({required this.ad, required this.index});

  @override
  State<_AdCard> createState() => _AdCardState();
}

class _AdCardState extends State<_AdCard> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    Future.delayed(
        Duration(milliseconds: widget.index * 65),
        () => mounted ? _animCtrl.forward() : null);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.ad.status) {
      case AdStatus.active:   return AppColor.success;
      case AdStatus.pending:  return AppColor.warning;
      case AdStatus.rejected: return AppColor.error;
      case AdStatus.expired:  return AppColor.grey;
      case AdStatus.paused:   return AppColor.info;
    }
  }

  Color get _statusBg {
    switch (widget.ad.status) {
      case AdStatus.active:   return AppColor.successLight;
      case AdStatus.pending:  return AppColor.warningLight;
      case AdStatus.rejected: return AppColor.errorLight;
      case AdStatus.expired:  return AppColor.secondBackground;
      case AdStatus.paused:   return AppColor.infoLight;
    }
  }

  String get _statusLabel {
    switch (widget.ad.status) {
      case AdStatus.active:   return 'ads_status_active'.tr;
      case AdStatus.pending:  return 'ads_status_pending'.tr;
      case AdStatus.rejected: return 'ads_status_rejected'.tr;
      case AdStatus.expired:  return 'ads_status_expired'.tr;
      case AdStatus.paused:   return 'ads_status_paused'.tr;
    }
  }

  IconData get _typeIcon {
    switch (widget.ad.adType) {
      case 'banner':          return Icons.view_carousel_rounded;
      case 'promoted_product':return Icons.inventory_2_rounded;
      case 'featured_store':  return Icons.storefront_rounded;
      case 'paid_notification':return Icons.notifications_active_rounded;
      default:                return Icons.campaign_rounded;
    }
  }

  String get _typeName {
    switch (widget.ad.adType) {
      case 'banner':           return 'ads_type_banner'.tr;
      case 'promoted_product': return 'ads_type_product'.tr;
      case 'featured_store':   return 'ads_type_store'.tr;
      case 'paid_notification':return 'ads_type_notification'.tr;
      default:                 return widget.ad.adType;
    }
  }

  List<Color> get _typeGradient {
    switch (widget.ad.adType) {
      case 'banner':           return [const Color(0xffFF6300), AppColor.primaryColor];
      case 'promoted_product': return [const Color(0xff553C9A), const Color(0xff7E57C2)];
      case 'featured_store':   return [const Color(0xff185FA5), const Color(0xff1E88E5)];
      case 'paid_notification':return [const Color(0xff1B5E20), AppColor.success];
      default:                 return [AppColor.primaryLight, AppColor.primaryColor];
    }
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;
    final isActive = ad.status == AdStatus.active;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColor.backgroundcolor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? AppColor.success.withOpacity(0.1)
                    : AppColor.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isActive
                  ? AppColor.success.withOpacity(0.3)
                  : AppColor.greyBorder,
              width: isActive ? 1.2 : 0.8,
            ),
          ),
          child: Column(children: [
            // ─── Header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(children: [
                // Type Icon with gradient
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _typeGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: _typeGradient.first.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Icon(_typeIcon, size: 22, color: Colors.white),
                ),
                const SizedBox(width: 12),
                // Title + type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ad.title,
                          style: AppTextStyle.labelLarge.copyWith(fontSize: 13.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(children: [
                        Text(_typeName,
                            style: AppTextStyle.labelSmall.copyWith(
                                fontSize: 11, color: _typeGradient.first)),
                        Text(' · ',
                            style: AppTextStyle.labelSmall.copyWith(
                                color: AppColor.greyLight)),
                        Text(ad.duration.replaceAll('_', ' '),
                            style: AppTextStyle.labelSmall.copyWith(fontSize: 11)),
                      ]),
                    ],
                  ),
                ),
                // Status Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: _statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(_statusLabel,
                        style: AppTextStyle.chip.copyWith(
                            color: _statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 10.5)),
                  ]),
                ),
              ]),
            ),

            // ─── Image Preview (Banner only) ─────────────────────
            if (ad.adType == 'banner' && ad.imageUrl != null) ...[
              Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(ad.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],

            // ─── Rejection Reason ─────────────────────────────────
            if (ad.status == AdStatus.rejected && ad.adminNotes != null) ...[
              Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColor.errorLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColor.error.withOpacity(0.2)),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 14, color: AppColor.error),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('ads_rejected_reason'.tr,
                          style: AppTextStyle.labelSmall.copyWith(
                              color: AppColor.error,
                              fontWeight: FontWeight.w700,
                              fontSize: 10)),
                      const SizedBox(height: 2),
                      Text(ad.adminNotes!,
                          style: AppTextStyle.labelSmall.copyWith(
                              color: AppColor.errorDark, fontSize: 11)),
                    ]),
                  ),
                ]),
              ),
            ],

            // ─── Stats Row (Active/Expired) ───────────────────────
            if (ad.status == AdStatus.active || ad.status == AdStatus.expired) ...[
              Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColor.secondBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatChip(
                          icon: Icons.remove_red_eye_outlined,
                          value: _fmtNum(ad.impressions),
                          label: 'ads_stat_views'.tr,
                          color: AppColor.info),
                      Container(width: 1, height: 28, color: AppColor.greyBorder),
                      _StatChip(
                          icon: Icons.touch_app_outlined,
                          value: _fmtNum(ad.clicks),
                          label: 'ads_stat_clicks'.tr,
                          color: AppColor.primaryColor),
                      Container(width: 1, height: 28, color: AppColor.greyBorder),
                      _StatChip(
                          icon: Icons.percent_rounded,
                          value: '${ad.ctr.toStringAsFixed(1)}%',
                          label: 'ads_stat_ctr'.tr,
                          color: AppColor.success),
                    ]),
              ),
            ],

            // ─── Footer: cost + dates ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(Icons.monetization_on_outlined,
                          size: 13, color: AppColor.primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        '${'ads_cost_label'.tr}: SP ${(ad.totalCost / 1000).toStringAsFixed(0)}k',
                        style: AppTextStyle.price.copyWith(fontSize: 12.5),
                      ),
                    ]),
                    Text(
                      ad.startsAt != null && ad.startsAt!.isNotEmpty
                          ? '${ad.startsAt!.substring(0, 10)} → ${ad.expiresAt?.substring(0, 10) ?? ''}'
                          : ad.createdAt.length > 10
                              ? ad.createdAt.substring(0, 10)
                              : ad.createdAt,
                      style: AppTextStyle.timestamp.copyWith(fontSize: 10.5),
                    ),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }

  String _fmtNum(int v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : '$v';
}

// ═══════════════════════════════════════════════════════════════
// STAT CHIP
// ═══════════════════════════════════════════════════════════════

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
              style: AppTextStyle.statNumberSmall
                  .copyWith(fontSize: 15, color: AppColor.black)),
        ]),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyle.statLabel.copyWith(fontSize: 10)),
      ]);
}

// ═══════════════════════════════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════════════════════════════

class _EmptyAds extends StatelessWidget {
  final VoidCallback onNew;
  const _EmptyAds({required this.onNew});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                  gradient: AppColor.mainGradient, shape: BoxShape.circle),
              child: const Icon(Icons.campaign_rounded,
                  size: 42, color: Colors.white),
            ),
            const SizedBox(height: 18),
            Text('ads_empty_title'.tr,
                style: AppTextStyle.heading3.copyWith(color: AppColor.black),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('ads_empty_body'.tr,
                style: AppTextStyle.bodyMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onNew,
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                label: Text('ads_create_btn'.tr, style: AppTextStyle.buttonMedium),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
              ),
            ),
          ]),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════
// ERROR STATE
// ═══════════════════════════════════════════════════════════════

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.wifi_off_rounded, size: 52, color: AppColor.greyLight),
          const SizedBox(height: 12),
          Text('ads_error_connection'.tr,
              style: AppTextStyle.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, color: AppColor.primaryColor),
            label: Text('retry'.tr.isNotEmpty ? 'retry'.tr : 'إعادة المحاولة',
                style: AppTextStyle.bodyLarge.copyWith(color: AppColor.primaryColor)),
          ),
        ]),
      );
}

// ═══════════════════════════════════════════════════════════════
// FLOATING ACTION BUTTON
// ═══════════════════════════════════════════════════════════════

class _CreateFAB extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateFAB({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: AppColor.mainGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColor.primaryShadow,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('ads_new'.tr,
                style: AppTextStyle.buttonMedium.copyWith(fontSize: 13.5)),
          ]),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════
// CREATE AD BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════

class _CreateAdSheet extends StatelessWidget {
  const _CreateAdSheet();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SellerAdsController>(
      builder: (ctrl) => Container(
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: BoxDecoration(
          color: AppColor.backgroundScaffold,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppColor.greyBorder,
                borderRadius: BorderRadius.circular(2)),
          ),

          // Header
          _SheetHeader(ctrl: ctrl),

          // Progress Bar
          _StepProgress(currentStep: ctrl.currentStep),

          const Divider(height: 1, color: AppColor.greyBorder),

          // Body
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(ctrl.currentStep),
                  child: ctrl.currentStep == 0
                      ? _StepType(ctrl: ctrl)
                      : ctrl.currentStep == 1
                          ? _StepDetails(ctrl: ctrl)
                          : _StepReview(ctrl: ctrl),
                ),
              ),
            ),
          ),

          // Bottom CTA
          _SheetBottomCTA(ctrl: ctrl),
        ]),
      ),
    );
  }
}

// ─── Sheet Header ───────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  final SellerAdsController ctrl;
  const _SheetHeader({required this.ctrl});

  String get _stepTitle {
    switch (ctrl.currentStep) {
      case 0: return 'ads_step1_title'.tr;
      case 1: return 'ads_step2_title'.tr;
      default: return 'ads_step3_title'.tr;
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
        child: Row(children: [
          if (ctrl.currentStep > 0)
            GestureDetector(
              onTap: ctrl.prevStep,
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  color: AppColor.backgroundcolor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColor.greyBorder),
                ),
                child: const Icon(Icons.arrow_back_ios_rounded,
                    size: 15, color: AppColor.grey),
              ),
            ),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_stepTitle, style: AppTextStyle.heading3),
              Text(
                '${'ads_step_of'.tr} ${ctrl.currentStep + 1} ${'ads_step_of_3'.tr}',
                style: AppTextStyle.labelSmall,
              ),
            ]),
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColor.greyBorder.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, color: AppColor.grey, size: 18),
            ),
          ),
        ]),
      );
}

// ─── Step Progress ───────────────────────────────────────────────

class _StepProgress extends StatelessWidget {
  final int currentStep;
  const _StepProgress({required this.currentStep});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: List.generate(3, (i) {
            final done = i < currentStep;
            final current = i == currentStep;
            return Expanded(
              child: Row(children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 5,
                    decoration: BoxDecoration(
                      gradient: done || current
                          ? AppColor.mainGradient
                          : null,
                      color: done || current ? null : AppColor.greyBorder,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                if (i < 2) const SizedBox(width: 6),
              ]),
            );
          }),
        ),
      );
}

// ─── Sheet Bottom CTA ────────────────────────────────────────────

class _SheetBottomCTA extends StatelessWidget {
  final SellerAdsController ctrl;
  const _SheetBottomCTA({required this.ctrl});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.of(context).padding.bottom + 14),
        decoration: BoxDecoration(
            color: AppColor.backgroundcolor,
            boxShadow: AppColor.bottomNavShadow),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton(
              onPressed: ctrl.currentStep < 2
                  ? ctrl.nextStep
                  : (ctrl.submitStatus == StatusRequest.loading
                      ? null
                      : ctrl.submitAd),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                disabledBackgroundColor: AppColor.primaryColor.withOpacity(0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: ctrl.submitStatus == StatusRequest.loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        ctrl.currentStep < 2
                            ? 'ads_btn_next'.tr
                            : 'ads_btn_confirm'.tr,
                        style: AppTextStyle.buttonLarge,
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white, size: 14),
                    ]),
            ),
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════
// STEP 1: TYPE SELECTION
// ═══════════════════════════════════════════════════════════════

class _StepType extends StatelessWidget {
  final SellerAdsController ctrl;
  const _StepType({required this.ctrl});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ads_what_to_promote'.tr,
              style: AppTextStyle.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('ads_choose_type_hint'.tr, style: AppTextStyle.bodySmall),
          const SizedBox(height: 16),
          ..._buildTypeCards(),
        ],
      );

  List<Widget> _buildTypeCards() {
    final types = [
      (
        'banner',
        'ads_type_banner',
        'ads_type_banner_desc',
        'ads_placement_home',
        Icons.view_carousel_rounded,
        [const Color(0xffFF6300), AppColor.primaryColor],
        {'1_day': 5000, '3_days': 12000, '1_week': 25000, '1_month': 80000},
      ),
      (
        'promoted_product',
        'ads_type_product',
        'ads_type_product_desc',
        'ads_placement_search',
        Icons.inventory_2_rounded,
        [const Color(0xff553C9A), const Color(0xff7E57C2)],
        {'1_day': 3000, '3_days': 8000, '1_week': 15000, '1_month': 50000},
      ),
      (
        'featured_store',
        'ads_type_store',
        'ads_type_store_desc',
        'ads_placement_stores',
        Icons.storefront_rounded,
        [const Color(0xff185FA5), const Color(0xff1E88E5)],
        {'1_day': 4000, '3_days': 10000, '1_week': 20000, '1_month': 65000},
      ),
      (
        'paid_notification',
        'ads_type_notification',
        'ads_type_notif_desc',
        'ads_placement_notif',
        Icons.notifications_active_rounded,
        [const Color(0xff1B5E20), AppColor.success],
        {'1_day': 15000, '3_days': 35000, '1_week': 60000, '1_month': 180000},
      ),
    ];

    return types.map((t) => _AdTypeCard(
          id: t.$1,
          titleKey: t.$2,
          descKey: t.$3,
          placementKey: t.$4,
          icon: t.$5,
          gradient: t.$6,
          pricing: t.$7,
          isSelected: ctrl.selectedAdType == t.$1,
          onTap: () => ctrl.selectAdType(t.$1),
        )).toList();
  }
}

class _AdTypeCard extends StatelessWidget {
  final String id, titleKey, descKey, placementKey;
  final IconData icon;
  final List<Color> gradient;
  final Map<String, int> pricing;
  final bool isSelected;
  final VoidCallback onTap;

  const _AdTypeCard({
    required this.id,
    required this.titleKey,
    required this.descKey,
    required this.placementKey,
    required this.icon,
    required this.gradient,
    required this.pricing,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? AppColor.primarySurface : AppColor.backgroundcolor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColor.primaryColor : AppColor.greyBorder,
              width: isSelected ? 1.8 : 1,
            ),
            boxShadow: isSelected ? AppColor.cardShadow : null,
          ),
          child: Row(children: [
            // Icon container with gradient
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight)
                    : null,
                color: isSelected ? null : AppColor.secondBackground,
                borderRadius: BorderRadius.circular(13),
                boxShadow: isSelected
                    ? [BoxShadow(
                        color: gradient.first.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3))]
                    : null,
              ),
              child: Icon(icon,
                  size: 24,
                  color: isSelected ? Colors.white : AppColor.grey),
            ),
            const SizedBox(width: 12),
            // Text info
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(titleKey.tr,
                    style: AppTextStyle.labelLarge.copyWith(
                        color: isSelected ? AppColor.primaryColor : AppColor.black,
                        fontSize: 13.5)),
                const SizedBox(height: 3),
                Text(descKey.tr,
                    style: AppTextStyle.bodySmall.copyWith(fontSize: 11.5)),
                const SizedBox(height: 5),
                Row(children: [
                  Icon(Icons.place_rounded, size: 11, color: AppColor.greyLight),
                  const SizedBox(width: 3),
                  Text(placementKey.tr,
                      style: AppTextStyle.labelSmall.copyWith(fontSize: 10.5)),
                ]),
              ]),
            ),
            // Price
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('ads_price_from'.tr,
                      style: AppTextStyle.labelSmall.copyWith(fontSize: 9)),
                  Text(
                    'SP ${((pricing['1_day'] ?? 0) ~/ 1000)}k',
                    style: AppTextStyle.price.copyWith(
                        fontSize: 13,
                        color: isSelected ? AppColor.primaryColor : AppColor.primaryColor),
                  ),
                  Text('ads_price_per_day'.tr,
                      style: AppTextStyle.labelSmall.copyWith(fontSize: 9)),
                ]),
          ]),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════
// STEP 2: DETAILS
// ═══════════════════════════════════════════════════════════════

class _StepDetails extends StatelessWidget {
  final SellerAdsController ctrl;
  const _StepDetails({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isNotif = ctrl.selectedAdType == 'paid_notification';
    final isBanner = ctrl.selectedAdType == 'banner';
    final isProduct = ctrl.selectedAdType == 'promoted_product';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // ─── Banner Image Upload ──────────────────────────────────
      if (isBanner) ...[
        _SectionLabel(icon: Icons.image_rounded, label: 'ads_image_label'.tr),
        const SizedBox(height: 8),
        _BannerImagePicker(ctrl: ctrl),
        const SizedBox(height: 18),
      ],

      // ─── Product Selector ─────────────────────────────────────
      if (isProduct) ...[
        _SectionLabel(icon: Icons.inventory_2_outlined, label: 'ads_product_label'.tr),
        const SizedBox(height: 8),
        _ProductDropdown(ctrl: ctrl),
        const SizedBox(height: 18),
      ],

      // ─── Title ────────────────────────────────────────────────
      _SectionLabel(
        icon: isNotif ? Icons.title_rounded : Icons.edit_rounded,
        label: 'ads_title_label'.tr,
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl.titleCtrl,
        style: AppTextStyle.inputText,
        textInputAction: TextInputAction.next,
        decoration: _inputDecoration(
          hintText: isNotif ? 'ads_notif_title_hint'.tr : 'ads_title_hint'.tr,
          prefixIcon: isNotif
              ? Icons.notifications_active_outlined
              : Icons.title_rounded,
        ),
      ),
      const SizedBox(height: 14),

      // ─── Description ──────────────────────────────────────────
      _SectionLabel(
        icon: Icons.notes_rounded,
        label: 'ads_desc_label'.tr,
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl.descCtrl,
        maxLines: isNotif ? 4 : 3,
        style: AppTextStyle.inputText,
        decoration: _inputDecoration(
          hintText: isNotif ? 'ads_notif_body_hint'.tr : 'ads_desc_hint'.tr,
          prefixIcon: Icons.notes_rounded,
        ),
      ),
      const SizedBox(height: 20),

      // ─── Duration ────────────────────────────────────────────
      _SectionLabel(icon: Icons.timer_outlined, label: 'ads_duration_label'.tr),
      const SizedBox(height: 10),
      ..._DurationOptions(ctrl: ctrl).build(),
    ]);
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) =>
      InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyle.inputHint,
        prefixIcon: Icon(prefixIcon, size: 18, color: AppColor.greyText),
        filled: true,
        fillColor: AppColor.backgroundcolor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColor.greyBorder)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColor.greyBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColor.primaryColor, width: 1.5)),
      );
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 15, color: AppColor.primaryColor),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyle.inputLabel.copyWith(
            color: AppColor.black, fontWeight: FontWeight.w600)),
      ]);
}

// ─── Banner Image Picker ─────────────────────────────────────────

class _BannerImagePicker extends StatelessWidget {
  final SellerAdsController ctrl;
  const _BannerImagePicker({required this.ctrl});

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920);
    if (picked != null) {
      ctrl.adImage = File(picked.path);
      ctrl.update();
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: _pickImage,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 130,
          decoration: BoxDecoration(
            color: ctrl.adImage != null
                ? Colors.transparent
                : AppColor.primarySurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ctrl.adImage != null
                  ? AppColor.primaryColor.withOpacity(0.3)
                  : AppColor.primaryColor.withOpacity(0.4),
              width: 1.5,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
            image: ctrl.adImage != null
                ? DecorationImage(
                    image: FileImage(ctrl.adImage!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.08), BlendMode.darken),
                  )
                : null,
          ),
          child: ctrl.adImage != null
              ? Stack(children: [
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.edit_rounded,
                            size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text('ads_image_change'.tr,
                            style: AppTextStyle.buttonSmall
                                .copyWith(fontSize: 10)),
                      ]),
                    ),
                  ),
                ])
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cloud_upload_rounded,
                          size: 24, color: AppColor.primaryColor),
                    ),
                    const SizedBox(height: 8),
                    Text('ads_image_tap'.tr,
                        style: AppTextStyle.labelLarge
                            .copyWith(color: AppColor.primaryColor, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('ads_image_hint'.tr,
                        style: AppTextStyle.labelSmall.copyWith(fontSize: 10)),
                  ],
                ),
        ),
      );
}

// ─── Product Dropdown ────────────────────────────────────────────

class _ProductDropdown extends StatelessWidget {
  final SellerAdsController ctrl;
  const _ProductDropdown({required this.ctrl});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColor.backgroundcolor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.greyBorder),
        ),
        child: ctrl.products.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 16, color: AppColor.warning),
                  const SizedBox(width: 8),
                  Text('لا توجد منتجات متاحة',
                      style: AppTextStyle.bodyMedium),
                ]),
              )
            : DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<int>(
                    value: ctrl.selectedProductId,
                    isExpanded: true,
                    hint: Row(children: [
                      const Icon(Icons.inventory_2_outlined,
                          size: 16, color: AppColor.greyLight),
                      const SizedBox(width: 8),
                      Text('ads_product_hint'.tr,
                          style: AppTextStyle.inputHint),
                    ]),
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
                        final p = ctrl.products.firstWhere((p) => p.id == id);
                        ctrl.selectProduct(p);
                      }
                    },
                  ),
                ),
              ),
      );
}

// ─── Duration Options ────────────────────────────────────────────

class _DurationOptions {
  final SellerAdsController ctrl;
  const _DurationOptions({required this.ctrl});

  String _durationLabel(String key) {
    switch (key) {
      case '1_day':   return 'ads_dur_1day'.tr;
      case '3_days':  return 'ads_dur_3days'.tr;
      case '1_week':  return 'ads_dur_1week'.tr;
      case '1_month': return 'ads_dur_1month'.tr;
      default: return key;
    }
  }

  Map<String, int> get _pricing {
    switch (ctrl.selectedAdType) {
      case 'banner':           return {'1_day': 5000, '3_days': 12000, '1_week': 25000, '1_month': 80000};
      case 'promoted_product': return {'1_day': 3000, '3_days': 8000,  '1_week': 15000, '1_month': 50000};
      case 'featured_store':   return {'1_day': 4000, '3_days': 10000, '1_week': 20000, '1_month': 65000};
      case 'paid_notification':return {'1_day': 15000,'3_days': 35000, '1_week': 60000, '1_month': 180000};
      default:                 return {'1_day': 5000, '3_days': 12000, '1_week': 25000, '1_month': 80000};
    }
  }

  List<Widget> build() {
    final keys = ['1_day', '3_days', '1_week', '1_month'];
    final popularKey = '3_days';

    return keys.map((key) {
      final isSelected = ctrl.selectedDuration == key;
      final price = _pricing[key] ?? 0;

      return GestureDetector(
        onTap: () => ctrl.selectDuration(key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColor.primarySurface : AppColor.backgroundcolor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColor.primaryColor : AppColor.greyBorder,
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Row(children: [
            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColor.primaryColor : AppColor.greyLight,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Label + popular badge
            Expanded(
              child: Row(children: [
                Text(_durationLabel(key),
                    style: AppTextStyle.labelLarge.copyWith(
                        fontSize: 13,
                        color: isSelected ? AppColor.primaryColor : AppColor.black)),
                if (key == popularKey) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: AppColor.mainGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('ads_duration_popular'.tr,
                        style: AppTextStyle.badge.copyWith(fontSize: 8.5)),
                  ),
                ],
              ]),
            ),
            // Price
            Text(
              'SP ${(price ~/ 1000)}k',
              style: AppTextStyle.price.copyWith(fontSize: 14),
            ),
          ]),
        ),
      );
    }).toList();
  }
}

// ═══════════════════════════════════════════════════════════════
// STEP 3: REVIEW
// ═══════════════════════════════════════════════════════════════

class _StepReview extends StatelessWidget {
  final SellerAdsController ctrl;
  const _StepReview({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final price = ctrl.computedPrice;
    final canAfford = ctrl.canAfford;

    String adTypeName = '';
    switch (ctrl.selectedAdType) {
      case 'banner':           adTypeName = 'ads_type_banner'.tr;        break;
      case 'promoted_product': adTypeName = 'ads_type_product'.tr;       break;
      case 'featured_store':   adTypeName = 'ads_type_store'.tr;         break;
      case 'paid_notification':adTypeName = 'ads_type_notification'.tr;  break;
    }

    String durationLabel = '';
    switch (ctrl.selectedDuration) {
      case '1_day':   durationLabel = 'ads_dur_1day'.tr;   break;
      case '3_days':  durationLabel = 'ads_dur_3days'.tr;  break;
      case '1_week':  durationLabel = 'ads_dur_1week'.tr;  break;
      case '1_month': durationLabel = 'ads_dur_1month'.tr; break;
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('ads_review_title'.tr,
          style: AppTextStyle.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 16),

      // ─── Summary Card ────────────────────────────────────────
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.backgroundcolor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.greyBorder),
          boxShadow: AppColor.cardShadow,
        ),
        child: Column(children: [
          _ReviewRow(label: 'ads_review_type'.tr, value: adTypeName,
              icon: Icons.campaign_rounded, color: AppColor.primaryColor),
          _ReviewRow(
              label: 'ads_review_ad_title'.tr,
              value: ctrl.titleCtrl.text.trim().isEmpty ? '—' : ctrl.titleCtrl.text.trim(),
              icon: Icons.title_rounded, color: AppColor.info),
          if (ctrl.selectedAdType == 'promoted_product' &&
              ctrl.selectedProductName != null)
            _ReviewRow(
                label: 'ads_review_product'.tr,
                value: ctrl.selectedProductName!,
                icon: Icons.inventory_2_outlined, color: AppColor.statOrders),
          _ReviewRow(label: 'ads_review_duration'.tr, value: durationLabel,
              icon: Icons.timer_outlined, color: AppColor.success),
        ]),
      ),
      const SizedBox(height: 14),

      // ─── Cost Card ───────────────────────────────────────────
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: canAfford
                ? [const Color(0xff1B5E20), const Color(0xff27AE60)]
                : [AppColor.errorDark, AppColor.error],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (canAfford ? AppColor.success : AppColor.error)
                  .withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('ads_total_cost'.tr,
                style: AppTextStyle.labelMedium.copyWith(color: Colors.white70)),
            Text(
              'SP ${(price / 1000).toStringAsFixed(0)}k',
              style: AppTextStyle.priceLarge.copyWith(
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
            ),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('ads_wallet_balance'.tr,
                style: AppTextStyle.labelSmall.copyWith(color: Colors.white60)),
            Text(
              'SP ${(ctrl.walletBalance / 1000).toStringAsFixed(0)}k',
              style: AppTextStyle.labelMedium.copyWith(color: Colors.white70),
            ),
          ]),
          if (!canAfford) ...[
            const Divider(color: Colors.white24, height: 16),
            Row(children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 15, color: Colors.white70),
              const SizedBox(width: 8),
              Expanded(
                child: Text('ads_insufficient'.tr,
                    style: AppTextStyle.labelSmall
                        .copyWith(color: Colors.white, fontSize: 11)),
              ),
            ]),
          ],
        ]),
      ),
      const SizedBox(height: 14),

      // ─── Notice ──────────────────────────────────────────────
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColor.infoLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.info.withOpacity(0.2)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.info_outline_rounded, size: 15, color: AppColor.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text('ads_review_notice'.tr,
                style: AppTextStyle.labelSmall
                    .copyWith(color: AppColor.infoDark, fontSize: 11.5)),
          ),
        ]),
      ),
    ]);
  }
}

class _ReviewRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _ReviewRow(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: AppTextStyle.bodySmall.copyWith(fontSize: 10.5)),
              Text(value,
                  style: AppTextStyle.labelLarge.copyWith(fontSize: 13)),
            ]),
          ),
        ]),
      );
}

// ═══════════════════════════════════════════════════════════════
// SHIMMER LOADING
// ═══════════════════════════════════════════════════════════════

class _AdsShimmer extends StatelessWidget {
  const _AdsShimmer();

  @override
  Widget build(BuildContext context) => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          height: 118,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColor.backgroundcolor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppColor.cardShadow,
          ),
          child: Row(children: [
            const ShimmerBox(width: 46, height: 46, radius: 13),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    ShimmerBox(width: 160, height: 13),
                    SizedBox(height: 8),
                    ShimmerBox(width: 110, height: 10),
                    SizedBox(height: 14),
                    ShimmerBox(width: double.infinity, height: 30, radius: 10),
                  ]),
            ),
          ]),
        ),
      );
}
