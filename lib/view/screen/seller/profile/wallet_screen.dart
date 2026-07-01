import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_wallet_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/wallet_models.dart';
import 'package:e_commerce/view/widget/seller/dashboard/shimmer_box.dart';
import 'package:e_commerce/view/widget/shared/app_text_field.dart';

part 'wallet_screen_withdraw_sheet.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SellerWalletController());
    return GetBuilder<SellerWalletController>(
      builder: (ctrl) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        appBar: _WalletAppBar(ctrl: ctrl),
        body: ctrl.statusRequest == StatusRequest.loading
            ? const _WalletShimmer()
            : RefreshIndicator(
                onRefresh: ctrl.loadData,
                color: AppColor.primaryColor,
                backgroundColor: Colors.white,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _BalanceCard(ctrl: ctrl),
                          const SizedBox(height: 14),
                          _StatsRow(ctrl: ctrl),
                          const SizedBox(height: 20),
                          if (ctrl.pendingRequests.isNotEmpty) ...[
                            _SectionHeader(
                              icon: Icons.pending_actions_rounded,
                              title: 'wallet_pending_title'.tr,
                              iconBg: AppColor.warningLight,
                              iconColor: AppColor.warning,
                            ),
                            const SizedBox(height: 10),
                            ...ctrl.pendingRequests.map(
                              (r) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _PendingCard(request: r),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          _SectionHeader(
                            icon: Icons.history_rounded,
                            title: 'wallet_tx_history'.tr,
                            iconBg: AppColor.primarySurface,
                            iconColor: AppColor.primaryColor,
                          ),
                          const SizedBox(height: 10),
                          _TxFilterRow(ctrl: ctrl),
                          const SizedBox(height: 12),
                          if (ctrl.filteredTransactions.isEmpty)
                            _EmptyTransactions(
                                hasFilter: ctrl.txFilter != 'all')
                          else
                            ...ctrl.filteredTransactions
                                .asMap()
                                .entries
                                .map((e) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: _TxCard(
                                        tx: e.value,
                                        index: e.key,
                                      ),
                                    )),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
        floatingActionButton: ctrl.statusRequest == StatusRequest.loading
            ? null
            : _WithdrawFab(ctrl: ctrl),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class _WalletAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SellerWalletController ctrl;
  const _WalletAppBar({required this.ctrl});

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
        title: Text('wallet_title'.tr, style: AppTextStyle.appBarTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              ctrl.showBalance
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.white,
              size: 22,
            ),
            onPressed: ctrl.toggleBalanceVisibility,
          ),
        ],
      );
}

class _BalanceCard extends StatelessWidget {
  final SellerWalletController ctrl;
  const _BalanceCard({required this.ctrl});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xff0F3460), Color(0xff185FA5)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff185FA5).withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    color: Colors.white70, size: 12),
                const SizedBox(width: 5),
                Text('wallet_seller_wallet'.tr,
                    style: AppTextStyle.chip.copyWith(
                        color: Colors.white70, fontSize: 10)),
              ]),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: AppColor.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColor.success.withOpacity(0.4)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: AppColor.success, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text('wallet_active'.tr,
                    style: AppTextStyle.chip.copyWith(
                        color: AppColor.success, fontSize: 10)),
              ]),
            ),
          ]),
          const SizedBox(height: 20),
          Text('wallet_available_balance'.tr,
              style: AppTextStyle.labelSmall
                  .copyWith(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 6),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: ctrl.showBalance
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                ctrl.formattedAvailable,
                style: AppTextStyle.priceLarge
                    .copyWith(color: Colors.white, fontSize: 34),
              ),
            ),
            secondChild: Text(
              '••••••',
              style: AppTextStyle.priceLarge
                  .copyWith(color: Colors.white, fontSize: 28),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.15),
          ),
          const SizedBox(height: 16),
          Row(children: [
            _BalancePill(
              icon: Icons.lock_clock_outlined,
              label: 'wallet_reserved'.tr,
              value: ctrl.showBalance
                  ? ctrl.formattedReserved
                  : '•••',
            ),
            Container(
              width: 1,
              height: 32,
              color: Colors.white.withOpacity(0.15),
              margin: const EdgeInsets.symmetric(horizontal: 14),
            ),
            _BalancePill(
              icon: Icons.percent_rounded,
              label: 'wallet_commission_rate'.tr,
              value: '10%',
              valueColor: AppColor.warning,
            ),
          ]),
        ]),
      );
}

class _BalancePill extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color?   valueColor;
  const _BalancePill({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: Colors.white60),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyle.labelSmall
                        .copyWith(color: Colors.white70, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(value,
                    style: AppTextStyle.statNumberSmall.copyWith(
                        color: valueColor ?? Colors.white, fontSize: 15)),
              ],
            ),
          ),
        ]),
      );
}

class _StatsRow extends StatelessWidget {
  final SellerWalletController ctrl;
  const _StatsRow({required this.ctrl});

  @override
  Widget build(BuildContext context) => Row(children: [
        _StatBox(
          icon: Icons.arrow_downward_rounded,
          iconColor: AppColor.success,
          iconBg: AppColor.successLight,
          label: 'wallet_received_month'.tr,
          value: ctrl.showBalance
              ? 'SP ${(ctrl.stats?.receivedThisMonth ?? 0) ~/ 1000}k'
              : '•••',
        ),
        const SizedBox(width: 10),
        _StatBox(
          icon: Icons.storefront_outlined,
          iconColor: AppColor.warning,
          iconBg: AppColor.warningLight,
          label: 'wallet_commission_month'.tr,
          value: ctrl.showBalance
              ? 'SP ${(ctrl.stats?.commissionThisMonth ?? 0) ~/ 1000}k'
              : '•••',
        ),
        const SizedBox(width: 10),
        _StatBox(
          icon: Icons.arrow_upward_rounded,
          iconColor: AppColor.error,
          iconBg: AppColor.errorLight,
          label: 'wallet_withdrawn_month'.tr,
          value: ctrl.showBalance
              ? 'SP ${(ctrl.stats?.withdrawnThisMonth ?? 0) ~/ 1000}k'
              : '•••',
        ),
      ]);
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final Color    iconBg;
  final String   label;
  final String   value;
  const _StatBox({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColor.cardShadow,
          ),
          child: Column(children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: AppTextStyle.statNumberSmall
                      .copyWith(fontSize: 14)),
            ),
            const SizedBox(height: 3),
            Text(label,
                style: AppTextStyle.labelSmall.copyWith(fontSize: 9.5),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ]),
        ),
      );
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String   title;
  final Color    iconBg;
  final Color    iconColor;
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: AppTextStyle.heading3.copyWith(fontSize: 14)),
      ]);
}

class _PendingCard extends StatelessWidget {
  final PendingWithdrawalModel request;
  const _PendingCard({required this.request});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColor.cardShadow,
          border: Border.all(
              color: AppColor.warning.withOpacity(0.3), width: 0.8),
        ),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColor.warningLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.pending_outlined,
                size: 22, color: AppColor.warning),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(children: [
                Text(request.methodLabel,
                    style: AppTextStyle.labelLarge
                        .copyWith(fontSize: 13)),
                const SizedBox(width: 6),
                Text(request.methodInfo,
                    style: AppTextStyle.labelSmall
                        .copyWith(color: AppColor.greyLight, fontSize: 11)),
              ]),
              const SizedBox(height: 3),
              Text(request.requestedAt,
                  style: AppTextStyle.timestamp),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              'SP ${request.amount ~/ 1000}k',
              style: AppTextStyle.price
                  .copyWith(color: AppColor.primaryColor, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColor.warningLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('wallet_status_pending'.tr,
                  style: AppTextStyle.chip.copyWith(
                      color: AppColor.warningDark,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
        ]),
      );
}

class _TxFilterRow extends StatelessWidget {
  final SellerWalletController ctrl;
  const _TxFilterRow({required this.ctrl});

  @override
  Widget build(BuildContext context) => Row(children: [
        _FilterChip(
          label: 'wallet_filter_all'.tr,
          isActive: ctrl.txFilter == 'all',
          onTap: () => ctrl.setTxFilter('all'),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'wallet_filter_credit'.tr,
          isActive: ctrl.txFilter == 'credit',
          activeColor: AppColor.success,
          onTap: () => ctrl.setTxFilter('credit'),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'wallet_filter_debit'.tr,
          isActive: ctrl.txFilter == 'debit',
          activeColor: AppColor.error,
          onTap: () => ctrl.setTxFilter('debit'),
        ),
      ]);
}

class _FilterChip extends StatelessWidget {
  final String     label;
  final bool       isActive;
  final Color?     activeColor;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final ac = activeColor ?? AppColor.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? ac : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive ? ac : AppColor.greyBorder),
          boxShadow: isActive ? AppColor.cardShadow : null,
        ),
        child: Text(label,
            style: AppTextStyle.chip.copyWith(
              color: isActive ? Colors.white : AppColor.grey,
              fontWeight:
                  isActive ? FontWeight.w700 : FontWeight.w500,
            )),
      ),
    );
  }
}

class _TxCard extends StatefulWidget {
  final WalletTransaction tx;
  final int index;
  const _TxCard({required this.tx, required this.index});

  @override
  State<_TxCard> createState() => _TxCardState();
}

class _TxCardState extends State<_TxCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 380));
    _fade  = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    Future.delayed(
        Duration(milliseconds: 40 + widget.index * 55),
        () { if (mounted) _anim.forward(); });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tx       = widget.tx;
    final isCredit = tx.type == 'credit';
    final isPending = tx.status == 'pending';

    final amountColor = isCredit ? AppColor.successDark : AppColor.error;
    final amountStr   = isCredit
        ? '+SP ${tx.amount ~/ 1000}k'
        : '-SP ${tx.amount ~/ 1000}k';
    final iconColor = isCredit ? AppColor.success : AppColor.error;
    final iconBg    = isCredit ? AppColor.successLight : AppColor.errorLight;
    final txIcon    = isCredit
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColor.cardShadow,
            border: Border.all(color: AppColor.greyBorder, width: 0.5),
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(txIcon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(tx.description,
                    style:
                        AppTextStyle.labelLarge.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  Text(tx.reference,
                      style: AppTextStyle.orderNumber
                          .copyWith(fontSize: 10)),
                  const SizedBox(width: 6),
                  Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                          color: AppColor.greyLight,
                          shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(tx.date,
                      style: AppTextStyle.timestamp),
                ]),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(amountStr,
                  style: AppTextStyle.price.copyWith(
                      color: amountColor, fontSize: 15)),
              const SizedBox(height: 5),
              if (isPending)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColor.warningLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('wallet_status_pending'.tr,
                      style: AppTextStyle.chip.copyWith(
                          color: AppColor.warningDark, fontSize: 9)),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColor.successLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('wallet_status_done'.tr,
                      style: AppTextStyle.chip.copyWith(
                          color: AppColor.successDark, fontSize: 9)),
                ),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  final bool hasFilter;
  const _EmptyTransactions({required this.hasFilter});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(children: [
          Icon(
            hasFilter
                ? Icons.filter_list_off_rounded
                : Icons.receipt_long_outlined,
            size: 58,
            color: AppColor.greyLight,
          ),
          const SizedBox(height: 12),
          Text(
            hasFilter
                ? 'wallet_no_tx_filter'.tr
                : 'wallet_no_tx'.tr,
            style: AppTextStyle.heading3
                .copyWith(color: AppColor.grey),
          ),
          const SizedBox(height: 6),
          Text(
            hasFilter
                ? 'wallet_try_filter'.tr
                : 'wallet_no_tx_body'.tr,
            style: AppTextStyle.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ]),
      );
}

class _WithdrawFab extends StatelessWidget {
  final SellerWalletController ctrl;
  const _WithdrawFab({required this.ctrl});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: ctrl.canWithdraw
                ? () => _showWithdrawSheet(context, ctrl)
                : null,
            icon: const Icon(Icons.download_rounded,
                size: 20, color: Colors.white),
            label: Text(
              ctrl.canWithdraw
                  ? 'wallet_withdraw_btn'.tr
                  : 'wallet_min_not_met'.tr,
              style: AppTextStyle.buttonMedium,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              disabledBackgroundColor: AppColor.greyBorder,
              disabledForegroundColor: AppColor.grey,
              elevation: 6,
              shadowColor: AppColor.primaryColor.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      );
}

class _WalletShimmer extends StatelessWidget {
  const _WalletShimmer();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const ShimmerBox(
              width: double.infinity, height: 230, radius: 22),
          const SizedBox(height: 14),
          Row(children: const [
            Expanded(
                child: ShimmerBox(
                    width: double.infinity, height: 90, radius: 14)),
            SizedBox(width: 10),
            Expanded(
                child: ShimmerBox(
                    width: double.infinity, height: 90, radius: 14)),
            SizedBox(width: 10),
            Expanded(
                child: ShimmerBox(
                    width: double.infinity, height: 90, radius: 14)),
          ]),
          const SizedBox(height: 20),
          ...List.generate(
              5,
              (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: ShimmerBox(
                        width: double.infinity,
                        height: 72,
                        radius: 14),
                  )),
        ]),
      );
}
