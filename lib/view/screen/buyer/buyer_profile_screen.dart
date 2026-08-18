import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/controller/buyer/buyer_profile_controller.dart';
import 'package:e_commerce/core/utils/buyer_format_utils.dart';
import 'package:e_commerce/view/widget/buyer/shared/buyer_network_image.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  BUYER PROFILE SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class BuyerProfileScreen extends StatelessWidget {
  const BuyerProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(BuyerProfileController());
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColor.backgroundScaffold,
        body: GetBuilder<BuyerProfileController>(
          builder: (ctrl) => RefreshIndicator(
            color:     AppColor.primaryColor,
            onRefresh: ctrl.refresh,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // ─── Gradient header (avatar + stats)
                SliverToBoxAdapter(
                  child: _ProfileHeader(ctrl: ctrl),
                ),
                // ─── Content body
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Wallet + Spin side-by-side
                      _WalletAndSpinRow(ctrl: ctrl),
                      const SizedBox(height: 22),
                      // Menu card
                      _MenuCard(
                        title: 'profile_section_account'.tr,
                        items: [
                          _MenuItem(
                            icon:  Icons.location_on_outlined,
                            color: AppColor.primaryColor,
                            label: 'manage_addresses'.tr,
                            onTap: ctrl.goToAddresses,
                          ),
                          _MenuItem(
                            icon:  Icons.store_outlined,
                            color: AppColor.info,
                            label: 'followed_stores'.tr,
                            onTap: ctrl.goToFollowedStores,
                          ),
                          _MenuItem(
                            icon:  Icons.chat_bubble_outline_rounded,
                            color: AppColor.success,
                            label: 'my_chats'.tr,
                            badge: ctrl.unreadChats,
                            onTap: ctrl.goToChats,
                          ),
                          _MenuItem(
                            icon:  Icons.star_border_rounded,
                            color: AppColor.warning,
                            label: 'my_reviews_list'.tr,
                            onTap: ctrl.goToMyReviews,
                          ),
                          _MenuItem(
                            icon:  Icons.notifications_none_rounded,
                            color: AppColor.statOrders,
                            label: 'notification_settings'.tr,
                            onTap: ctrl.goToNotificationSettings,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Logout
                      _LogoutButton(onTap: ctrl.logout),
                      const SizedBox(height: 110),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  PROFILE HEADER  —  gradient card extending to the status bar
// ══════════════════════════════════════════════════════════════════════════════

class _ProfileHeader extends StatelessWidget {
  final BuyerProfileController ctrl;
  const _ProfileHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 0),
      decoration: const BoxDecoration(
        gradient: AppColor.mainGradient,
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        children: [
          // ── Screen label row
          Row(
            children: [
              Text(
                'buyer_profile_title'.tr,
                style: AppTextStyle.heading2.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // ── Avatar + name + badges
          _AvatarSection(ctrl: ctrl),
          const SizedBox(height: 24),
          // ── Stats bar
          _StatsBar(ctrl: ctrl),
        ],
      ),
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  final BuyerProfileController ctrl;
  const _AvatarSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ring + camera button overlay
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width:   94,
              height:  94,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.18),
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: ClipOval(child: _avatarContent()),
            ),
            Positioned.directional(
              textDirection: Directionality.of(context),
              bottom: -2,
              end:    -2,
              child: GestureDetector(
                onTap: ctrl.pickAvatar,
                child: Container(
                  width:  30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: AppColor.mainGradient,
                    shape:    BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: AppColor.cardShadow,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size:  14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Name
        Text(
          ctrl.userName,
          style:     AppTextStyle.displaySmall.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 3),
        // Email
        Text(
          ctrl.userEmail,
          style: AppTextStyle.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.72),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 3),
        // Phone
        Text(
          ctrl.userPhone,
          style: AppTextStyle.labelSmall.copyWith(
            color: Colors.white.withOpacity(0.55),
          ),
          textAlign: TextAlign.center,
        ),
        // VIP badge — shown only when eligible
        if (ctrl.isVip) ...[
          const SizedBox(height: 14),
          _VipBadge(),
        ],
      ],
    );
  }

  Widget _avatarContent() {
    if (ctrl.localAvatar != null) {
      return Image.file(ctrl.localAvatar!, fit: BoxFit.cover);
    }
    if (ctrl.serverAvatarUrl != null) {
      return BuyerNetworkImage(
        url:              ctrl.serverAvatarUrl!,
        backgroundColor:  AppColor.primarySurface,
        fallbackIcon:     Icons.person_rounded,
        fallbackIconSize: 40,
      );
    }
    // Default placeholder
    return Container(
      color: AppColor.primarySurface,
      child: Icon(
        Icons.person_rounded,
        size:  44,
        color: AppColor.primaryColor,
      ),
    );
  }
}

// ─── VIP Badge ────────────────────────────────────────────────────────────────

class _VipBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color:        AppColor.warningLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.warning.withOpacity(0.45)),
        boxShadow: [
          BoxShadow(
            color:      AppColor.warning.withOpacity(0.22),
            blurRadius: 8,
            offset:     const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            size:  16,
            color: AppColor.warningDark,
          ),
          const SizedBox(width: 6),
          Text(
            'vip_customer'.tr,
            style: AppTextStyle.labelSmall.copyWith(
              color:         AppColor.warningDark,
              fontWeight:    FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Bar ────────────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  final BuyerProfileController ctrl;
  const _StatsBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          _StatItem(
            count: ctrl.ordersCount,
            label: 'my_orders_count'.tr,
            onTap: ctrl.goToOrders,
          ),
          _VerticalDivider(),
          _StatItem(
            count: ctrl.wishlistCount,
            label: 'my_wishlist'.tr,
            onTap: ctrl.goToWishlist,
          ),
          _VerticalDivider(),
          _StatItem(
            count: ctrl.reviewsCount,
            label: 'my_reviews'.tr,
            onTap: ctrl.goToMyReviews,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;
  final VoidCallback? onTap;
  const _StatItem({required this.count, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap:        onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: AppTextStyle.statNumber.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyle.labelSmall.copyWith(
                color: Colors.white.withOpacity(0.72),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width:  1,
      height: 36,
      color:  Colors.white.withOpacity(0.22),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  WALLET + SPIN  —  horizontal row, wallet wider (flex 8) spin narrower (flex 5)
// ══════════════════════════════════════════════════════════════════════════════

class _WalletAndSpinRow extends StatelessWidget {
  final BuyerProfileController ctrl;
  const _WalletAndSpinRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 8, child: _WalletCard(ctrl: ctrl)),
          const SizedBox(width: 12),
          Expanded(flex: 5, child: _SpinCard(ctrl: ctrl)),
        ],
      ),
    );
  }
}

// ─── Wallet Card ──────────────────────────────────────────────────────────────

class _WalletCard extends StatelessWidget {
  final BuyerProfileController ctrl;
  const _WalletCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ctrl.goToWallet,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient:     AppColor.mainGradient,
          borderRadius: BorderRadius.circular(22),
          boxShadow:    AppColor.primaryShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: icon + visibility toggle
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    size:  18,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: ctrl.toggleBalanceVisibility,
                  child: Icon(
                    ctrl.isBalanceVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size:  18,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Label
            Text(
              'my_wallet'.tr,
              style: AppTextStyle.labelSmall.copyWith(
                color: Colors.white.withOpacity(0.72),
              ),
            ),
            const SizedBox(height: 5),
            // Balance with animated show/hide
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: ctrl.isBalanceVisible
                  ? Text(
                      '${formatBuyerPrice(ctrl.walletBalance)} ${'currency'.tr}',
                      key:   const ValueKey('shown'),
                      style: AppTextStyle.price.copyWith(
                        color:    Colors.white,
                        fontSize: 19,
                      ),
                    )
                  : Text(
                      '••••••',
                      key:   const ValueKey('hidden'),
                      style: AppTextStyle.heading1.copyWith(
                        color:         Colors.white.withOpacity(0.55),
                        letterSpacing: 6,
                      ),
                    ),
            ),
            const SizedBox(height: 14),
            // CTA chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:        Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.28)),
              ),
              child: Text(
                'wallet_goto'.tr,
                style: AppTextStyle.labelSmall.copyWith(
                  color:      Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Spin Card (StatefulWidget for rotation animation) ────────────────────────

class _SpinCard extends StatefulWidget {
  final BuyerProfileController ctrl;
  const _SpinCard({required this.ctrl});
  @override
  State<_SpinCard> createState() => _SpinCardState();
}

class _SpinCardState extends State<_SpinCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotateCtrl;

  @override
  void initState() {
    super.initState();
    _rotateCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.ctrl.goToSpin,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin:  Alignment.topLeft,
            end:    Alignment.bottomRight,
            colors: [AppColor.warningLight, AppColor.warning],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color:      AppColor.warning.withOpacity(0.25),
              blurRadius: 14,
              offset:     const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:  MainAxisAlignment.spaceBetween,
          children: [
            // Rotating wheel icon
            RotationTransition(
              turns: _rotateCtrl,
              child: Icon(
                Icons.autorenew_rounded,
                size:  42,
                color: AppColor.warningDark,
              ),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              'spin_and_win'.tr,
              style: AppTextStyle.labelLarge.copyWith(
                color: AppColor.warningDark,
              ),
            ),
            const SizedBox(height: 4),
            // Sub-label
            Text(
              'spin_try_today'.tr,
              style: AppTextStyle.labelSmall.copyWith(
                color:    AppColor.warningDark.withOpacity(0.68),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  MENU CARD  —  grouped tiles with rounded card + subtle shadow
// ══════════════════════════════════════════════════════════════════════════════

class _MenuItem {
  final IconData     icon;
  final Color        color;
  final String       label;
  final VoidCallback onTap;
  final int          badge;

  const _MenuItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.badge = 0,
  });
}

class _MenuCard extends StatelessWidget {
  final String         title;
  final List<_MenuItem> items;
  const _MenuCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label above card
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 10),
          child: Text(
            title,
            style: AppTextStyle.labelLarge.copyWith(color: AppColor.grey),
          ),
        ),
        // Card
        Container(
          decoration: BoxDecoration(
            color:        AppColor.cardBackground,
            borderRadius: BorderRadius.circular(22),
            boxShadow:    AppColor.cardShadow,
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              return _MenuTile(
                item:    items[i],
                isFirst: i == 0,
                isLast:  i == items.length - 1,
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  final bool      isFirst;
  final bool      isLast;
  const _MenuTile({
    required this.item,
    this.isFirst = false,
    this.isLast  = false,
  });

  @override
  Widget build(BuildContext context) {
    final topR    = isFirst ? const Radius.circular(22) : Radius.zero;
    final bottomR = isLast  ? const Radius.circular(22) : Radius.zero;

    return Column(
      children: [
        Material(
          color:        Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft:     topR,
            topRight:    topR,
            bottomLeft:  bottomR,
            bottomRight: bottomR,
          ),
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.only(
              topLeft:     topR,
              topRight:    topR,
              bottomLeft:  bottomR,
              bottomRight: bottomR,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Icon chip
                  Container(
                    width:  38,
                    height: 38,
                    decoration: BoxDecoration(
                      color:        item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(item.icon, size: 19, color: item.color),
                  ),
                  const SizedBox(width: 14),
                  // Label
                  Expanded(
                    child: Text(item.label, style: AppTextStyle.bodyLarge),
                  ),
                  // Unread badge (optional)
                  if (item.badge > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color:        AppColor.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.badge > 9 ? '9+' : '${item.badge}',
                        style: AppTextStyle.badge,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Chevron
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size:  13,
                    color: AppColor.greyLight,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Divider between items (not after last)
        if (!isLast)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 68),
            child: Divider(
              height: 1,
              color:  AppColor.greyBorder,
            ),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  LOGOUT BUTTON  —  red accent, full-width card
// ══════════════════════════════════════════════════════════════════════════════

class _LogoutButton extends StatelessWidget {
  final Future<void> Function() onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        AppColor.cardBackground,
        borderRadius: BorderRadius.circular(22),
        boxShadow:    AppColor.cardShadow,
      ),
      child: Material(
        color:        Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap:        onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 15),
            child: Row(
              children: [
                // Red icon chip
                Container(
                  width:  38,
                  height: 38,
                  decoration: BoxDecoration(
                    color:        AppColor.errorLight,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size:  19,
                    color: AppColor.error,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'logout'.tr,
                  style: AppTextStyle.bodyLarge.copyWith(
                    color:      AppColor.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size:  13,
                  color: AppColor.error.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
