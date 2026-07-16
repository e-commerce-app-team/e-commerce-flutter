import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_staff_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/staff_model.dart';
import 'package:e_commerce/view/screen/seller/staff/invite_staff_sheet.dart';
import 'package:e_commerce/view/widget/seller/dashboard/shimmer_box.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SellerStaffController());
    return GetBuilder<SellerStaffController>(
      builder: (ctrl) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        appBar: _StaffAppBar(ctrl: ctrl),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: ctrl.statusRequest == StatusRequest.loading
            ? const _StaffShimmer()
            : RefreshIndicator(
                color: AppColor.primaryColor,
                backgroundColor: Colors.white,
                onRefresh: ctrl.refreshStaff,
                child: ctrl.staff.isEmpty
                    ? const _EmptyStaff()
                    : CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: _StaffSummaryHeader(ctrl: ctrl),
                          ),
                          SliverPadding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 110),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (_, i) => _StaffCard(
                                  member: ctrl.staff[i],
                                  index:  i,
                                  ctrl:   ctrl,
                                ),
                                childCount: ctrl.staff.length,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
        floatingActionButton: _InviteFab(ctrl: ctrl),
      ),
    );
  }
}

class _StaffAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SellerStaffController ctrl;
  const _StaffAppBar({required this.ctrl});

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
        title: Text('staff_screen_title'.tr, style: AppTextStyle.appBarTitle),
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
              const Icon(Icons.business_center_outlined,
                  size: 12, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                'wholesale_companies'.tr,
                style: AppTextStyle.badge
                    .copyWith(color: Colors.white, fontSize: 10),
              ),
            ]),
          ),
        ],
      );
}


class _StaffSummaryHeader extends StatelessWidget {
  final SellerStaffController ctrl;
  const _StaffSummaryHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Row(children: [
        _StatBox(
          icon:  Icons.people_outline_rounded,
          bg:    AppColor.primarySurface,
          color: AppColor.primaryColor,
          label: 'staff_total'.tr,
          value: '${ctrl.totalCount}',
        ),
        const SizedBox(width: 10),
        _StatBox(
          icon:  Icons.check_circle_outline_rounded,
          bg:    AppColor.successLight,
          color: AppColor.success,
          label: 'staff_active'.tr,
          value: '${ctrl.activeCount}',
        ),
        const SizedBox(width: 10),
        _StatBox(
          icon:  Icons.hourglass_top_rounded,
          bg:    AppColor.warningLight,
          color: AppColor.warning,
          label: 'staff_pending'.tr,
          value: '${ctrl.pendingCount}',
        ),
      ]),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final Color    bg, color;
  final String   label, value;
  const _StatBox({
    required this.icon,  required this.bg,    required this.color,
    required this.label, required this.value,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColor.cardShadow,
          ),
          child: Column(children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 6),
            Text(value,
                style: AppTextStyle.statNumberSmall.copyWith(fontSize: 18)),
            Text(label,
                style: AppTextStyle.labelSmall.copyWith(fontSize: 9.5),
                textAlign: TextAlign.center),
          ]),
        ),
      );
}



class _StaffCard extends StatefulWidget {
  final StaffModel              member;
  final int                     index;
  final SellerStaffController   ctrl;
  const _StaffCard({
    required this.member, required this.index, required this.ctrl,
  });

  @override
  State<_StaffCard> createState() => _StaffCardState();
}

class _StaffCardState extends State<_StaffCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade  = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    Future.delayed(
        Duration(milliseconds: 50 + widget.index * 80),
        () { if (mounted) _anim.forward(); });
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final m           = widget.member;
    final ctrl        = widget.ctrl;
    final isDeleting  = ctrl.deletingIds.contains(m.id);
    final roleCfg     = _roleCfg(m.role);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: isDeleting ? 0.45 : 1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppColor.cardShadow,
              border: Border.all(
                color: m.isPending
                    ? AppColor.warning.withOpacity(0.3)
                    : AppColor.greyBorder,
                width: 0.8,
              ),
            ),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                child: Row(children: [
                  _AvatarCircle(name: m.name, role: m.role),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Row(children: [
                        Expanded(
                          child: Text(
                            m.name,
                            style: AppTextStyle.labelLarge
                                .copyWith(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _StatusBadge(isActive: m.isActive),
                      ]),
                      const SizedBox(height: 3),
                      Text(
                        m.email,
                        style: AppTextStyle.labelSmall
                            .copyWith(fontSize: 11,
                                fontFamily: 'PlayfairDisplay'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      _RoleBadge(role: m.role, cfg: roleCfg),
                    ]),
                  ),
                ]),
              ),

              if (m.permissions.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Divider(height: 14, color: AppColor.greyBorder),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: _PermissionsRow(permissions: m.permissions),
                ),
              ],

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Divider(height: 14, color: AppColor.greyBorder),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 12, color: AppColor.greyLight),
                  const SizedBox(width: 4),
                  Text(
                    m.joinedAt,
                    style: AppTextStyle.timestamp.copyWith(fontSize: 10),
                  ),
                  const Spacer(),
                  _CardAction(
                    icon:  Icons.edit_outlined,
                    color: AppColor.info,
                    bg:    AppColor.infoLight,
                    label: 'edit'.tr,
                    onTap: () {
                      ctrl.initEditForm(m);
                      showInviteStaffSheet(ctrl);
                    },
                  ),
                  const SizedBox(width: 8),
                  if (!m.isPending) ...[
                    _CardAction(
                      icon: m.isActive ? Icons.block_flipped : Icons.check_circle_outline,
                      color: m.isActive ? AppColor.warning : AppColor.success,
                      bg:    m.isActive ? AppColor.warningLight : AppColor.successLight,
                      label: m.isActive ? 'Deactivate' : 'Activate',
                      onTap: () => ctrl.toggleStaffStatus(m),
                    ),
                    const SizedBox(width: 8),
                  ],
                  _CardAction(
                    icon: isDeleting
                        ? Icons.hourglass_empty_rounded
                        : Icons.person_remove_outlined,
                    color: AppColor.error,
                    bg:    AppColor.errorLight,
                    label: 'delete'.tr,
                    onTap: isDeleting ? null : () => ctrl.deleteStaff(m),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  _RoleConfig _roleCfg(String role) {
    switch (role) {
      case StaffRole.manager:
        return _RoleConfig(
          labelKey: 'staff_role_manager',
          color:    AppColor.statOrders,
          bg:       AppColor.statOrdersLight,
          icon:     Icons.manage_accounts_rounded,
        );
      case StaffRole.warehouse:
        return _RoleConfig(
          labelKey: 'staff_role_warehouse',
          color:    AppColor.info,
          bg:       AppColor.infoLight,
          icon:     Icons.warehouse_outlined,
        );
      default:
        return _RoleConfig(
          labelKey: 'staff_role_support',
          color:    AppColor.success,
          bg:       AppColor.successLight,
          icon:     Icons.headset_mic_outlined,
        );
    }
  }
}


class _AvatarCircle extends StatelessWidget {
  final String name;
  final String role;
  const _AvatarCircle({required this.name, required this.role});

  Color get _roleColor {
    switch (role) {
      case StaffRole.manager:   return AppColor.statOrders;
      case StaffRole.warehouse: return AppColor.info;
      default:                  return AppColor.success;
    }
  }

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return parts[0].isNotEmpty ? parts[0][0] : '؟';
  }

  @override
  Widget build(BuildContext context) => Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight,
            colors: [
              _roleColor.withOpacity(0.7),
              _roleColor,
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:       _roleColor.withOpacity(0.3),
              blurRadius:  10,
              offset:      const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _initials,
            style: const TextStyle(
              color:       Colors.white,
              fontSize:    16,
              fontWeight:  FontWeight.w700,
              fontFamily:  'Cairo',
            ),
          ),
        ),
      );
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isActive ? AppColor.successLight : AppColor.warningLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColor.success.withOpacity(0.4)
                : AppColor.warning.withOpacity(0.4),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 5, height: 5,
            decoration: BoxDecoration(
              color: isActive ? AppColor.success : AppColor.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'staff_status_active'.tr : 'staff_status_pending'.tr,
            style: AppTextStyle.chip.copyWith(
              color: isActive ? AppColor.successDark : AppColor.warningDark,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ]),
      );
}

class _RoleConfig {
  final String  labelKey;
  final Color   color, bg;
  final IconData icon;
  const _RoleConfig({
    required this.labelKey, required this.color,
    required this.bg,       required this.icon,
  });
}

class _RoleBadge extends StatelessWidget {
  final String      role;
  final _RoleConfig cfg;
  const _RoleBadge({required this.role, required this.cfg});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color:        cfg.bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(cfg.icon, size: 12, color: cfg.color),
          const SizedBox(width: 5),
          Text(
            cfg.labelKey.tr,
            style: AppTextStyle.chip.copyWith(
              color:      cfg.color,
              fontSize:   10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ]),
      );
}

class _PermissionsRow extends StatelessWidget {
  final List<String> permissions;
  const _PermissionsRow({required this.permissions});

  String _label(String perm) {
    switch (perm) {
      case StaffPermission.viewOrders:      return 'perm_view_orders'.tr;
      case StaffPermission.manageInventory: return 'perm_manage_inv'.tr;
      case StaffPermission.viewReports:     return 'perm_view_reports'.tr;
      case StaffPermission.chatWithBuyers:  return 'perm_chat_buyers'.tr;
      default: return perm;
    }
  }

  IconData _icon(String perm) {
    switch (perm) {
      case StaffPermission.viewOrders:      return Icons.receipt_long_outlined;
      case StaffPermission.manageInventory: return Icons.inventory_2_outlined;
      case StaffPermission.viewReports:     return Icons.bar_chart_rounded;
      case StaffPermission.chatWithBuyers:  return Icons.chat_bubble_outline_rounded;
      default: return Icons.check_rounded;
    }
  }

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 6,
        runSpacing: 6,
        children: permissions
            .map((p) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor.secondBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColor.greyBorder),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_icon(p), size: 11, color: AppColor.grey),
                    const SizedBox(width: 4),
                    Text(
                      _label(p),
                      style: AppTextStyle.labelSmall
                          .copyWith(fontSize: 10, color: AppColor.grey),
                    ),
                  ]),
                ))
            .toList(),
      );
}

class _CardAction extends StatelessWidget {
  final IconData     icon;
  final Color        color, bg;
  final String       label;
  final VoidCallback? onTap;
  const _CardAction({
    required this.icon, required this.color,
    required this.bg,   required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color:        bg,
            borderRadius: BorderRadius.circular(10),
            border:       Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTextStyle.chip
                  .copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ]),
        ),
      );
}


class _InviteFab extends StatelessWidget {
  final SellerStaffController ctrl;
  const _InviteFab({required this.ctrl});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              ctrl.initInviteForm();
              showInviteStaffSheet(ctrl);
            },
            icon: const Icon(Icons.person_add_rounded,
                size: 20, color: Colors.white),
            label: Text('staff_invite_btn'.tr,
                style: AppTextStyle.buttonMedium),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              elevation:       6,
              shadowColor:     AppColor.primaryColor.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      );
}


class _EmptyStaff extends StatelessWidget {
  const _EmptyStaff();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 90, height: 90,
              decoration: const BoxDecoration(
                  color: AppColor.primarySurface, shape: BoxShape.circle),
              child: const Icon(Icons.people_outline_rounded,
                  size: 44, color: AppColor.primaryColor),
            ),
            const SizedBox(height: 20),
            Text('staff_empty_title'.tr, style: AppTextStyle.heading3),
            const SizedBox(height: 8),
            Text('staff_empty_body'.tr,
                style: AppTextStyle.bodyMedium,
                textAlign: TextAlign.center),
          ]),
        ),
      );
}



class _StaffShimmer extends StatelessWidget {
  const _StaffShimmer();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: const [
            Expanded(
                child: ShimmerBox(
                    width: double.infinity, height: 80, radius: 14)),
            SizedBox(width: 10),
            Expanded(
                child: ShimmerBox(
                    width: double.infinity, height: 80, radius: 14)),
            SizedBox(width: 10),
            Expanded(
                child: ShimmerBox(
                    width: double.infinity, height: 80, radius: 14)),
          ]),
          const SizedBox(height: 16),
          ...List.generate(
            3,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: ShimmerBox(
                  width: double.infinity, height: 150, radius: 18),
            ),
          ),
        ]),
      );
}
