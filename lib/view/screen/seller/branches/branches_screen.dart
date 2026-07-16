import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:e_commerce/controller/seller/seller_branches_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/data/model/seller/branch_model.dart';
import 'package:e_commerce/view/widget/seller/dashboard/shimmer_box.dart';

class BranchesScreen extends StatelessWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SellerBranchesController());
    return GetBuilder<SellerBranchesController>(
      builder: (ctrl) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            _BranchesSliverAppBar(ctrl: ctrl),
          ],
          body: ctrl.statusRequest == StatusRequest.loading
              ? const _BranchesShimmer()
              : RefreshIndicator(
                  onRefresh: ctrl.loadBranches,
                  color: AppColor.primaryColor,
                  backgroundColor: Colors.white,
                  child: ctrl.branches.isEmpty
                      ? const _EmptyBranches()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                          physics: const BouncingScrollPhysics(),
                          itemCount: ctrl.branches.length,
                          itemBuilder: (_, i) => _BranchCard(
                            branch: ctrl.branches[i],
                            index: i,
                            ctrl: ctrl,
                          ),
                        ),
                ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _AddFab(ctrl: ctrl),
      ),
    );
  }
}

// ─── Sliver App Bar ─────────────────────────────────────────────────────────

class _BranchesSliverAppBar extends StatelessWidget {
  final SellerBranchesController ctrl;
  const _BranchesSliverAppBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final active  = ctrl.branches.where((b) => b.isActive).length;
    final total   = ctrl.branches.length;
    final inactive = total - active;

    return SliverAppBar(
      expandedHeight: ctrl.branches.isEmpty ? kToolbarHeight : 160,
      pinned: true,
      floating: false,
      backgroundColor: AppColor.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
        onPressed: Get.back,
      ),
      title: Text('branch_screen_title'.tr, style: AppTextStyle.appBarTitle),
      centerTitle: true,
      flexibleSpace: ctrl.branches.isEmpty
          ? null
          : FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColor.headerGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 12, 16, 12),
                    child: Row(children: [
                      _HeaderStat(
                        value: '$total',
                        label: 'branch_total'.tr,
                        icon: Icons.store_rounded,
                      ),
                      const SizedBox(width: 6),
                      _HeaderStat(
                        value: '$active',
                        label: 'branch_active'.tr,
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF4ADE80),
                      ),
                      const SizedBox(width: 6),
                      _HeaderStat(
                        value: '$inactive',
                        label: 'branch_status_inactive'.tr,
                        icon: Icons.pause_circle_rounded,
                        color: const Color(0xFFFBBF24),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String   value, label;
  final IconData icon;
  final Color?   color;
  const _HeaderStat({
    required this.value,
    required this.label,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(children: [
        Icon(icon, size: 16, color: color ?? Colors.white),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500)),
            ),
          ]),
        ),
      ]),
    ),
  );
}

// ─── Branch Card ─────────────────────────────────────────────────────────────

class _BranchCard extends StatefulWidget {
  final BranchModel              branch;
  final int                      index;
  final SellerBranchesController ctrl;
  const _BranchCard({required this.branch, required this.index, required this.ctrl});

  @override
  State<_BranchCard> createState() => _BranchCardState();
}

class _BranchCardState extends State<_BranchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _fade  = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 30 + widget.index * 60), () {
      if (mounted) _anim.forward();
    });
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final branch     = widget.branch;
    final ctrl       = widget.ctrl;
    final isDeleting = ctrl.deletingIds.contains(branch.id);
    final isToggling = ctrl.togglingIds.contains(branch.id);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isDeleting ? 0.4 : 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColor.cardShadow,
              ),
              child: Column(children: [
                // ── Header row ──
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: branch.isActive
                        ? AppColor.primarySurface.withOpacity(0.6)
                        : AppColor.secondBackground,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(children: [
                    // Map preview or icon
                    branch.hasLocation
                        ? _MiniMapPin(lat: branch.lat!, lng: branch.lng!)
                        : Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: branch.isActive
                                  ? AppColor.primaryColor.withOpacity(0.12)
                                  : AppColor.greyBorder,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(
                              Icons.store_rounded,
                              size: 24,
                              color: branch.isActive
                                  ? AppColor.primaryColor
                                  : AppColor.greyLight,
                            ),
                          ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(
                            child: Text(branch.name,
                                style: AppTextStyle.labelLarge.copyWith(fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(isActive: branch.isActive),
                        ]),
                        const SizedBox(height: 4),
                        if (branch.managerName.isNotEmpty)
                          _MetaChip(
                            icon: Icons.person_outline_rounded,
                            text: branch.managerName,
                          ),
                      ]),
                    ),
                  ]),
                ),

                // ── Details ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  child: Column(children: [
                    if (branch.address.isNotEmpty)
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        text: branch.address,
                        trailing: branch.hasLocation ? const _MapBadge() : null,
                      ),
                    if (branch.address.isNotEmpty && branch.phone.isNotEmpty)
                      const SizedBox(height: 6),
                    if (branch.phone.isNotEmpty)
                      _InfoRow(icon: Icons.phone_outlined, text: branch.phone),
                  ]),
                ),

                // ── Actions ──
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColor.greyBorder, width: 0.8)),
                  ),
                  child: Row(children: [
                    // Toggle switch
                    isToggling
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: AppColor.primaryColor))
                        : Transform.scale(
                            scale: 0.85,
                            child: Switch(
                              value: branch.isActive,
                              activeColor: AppColor.primaryColor,
                              onChanged: (_) => ctrl.toggleActive(branch.id!),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                    const SizedBox(width: 2),
                    Text(
                      branch.isActive
                          ? 'branch_status_active'.tr
                          : 'branch_status_inactive'.tr,
                      style: AppTextStyle.labelSmall.copyWith(
                        fontSize: 11,
                        color: branch.isActive ? AppColor.success : AppColor.greyLight,
                      ),
                    ),
                    const Spacer(),
                    _ActionBtn(
                      icon: Icons.edit_outlined,
                      color: AppColor.info,
                      bg: AppColor.infoLight,
                      onTap: () {
                        ctrl.initForm(branch);
                        Get.toNamed(AppRoute.branchForm);
                      },
                    ),
                    const SizedBox(width: 8),
                    _ActionBtn(
                      icon: isDeleting
                          ? Icons.hourglass_empty_rounded
                          : Icons.delete_outline_rounded,
                      color: AppColor.error,
                      bg: AppColor.errorLight,
                      onTap: isDeleting ? null : () => ctrl.deleteBranch(branch.id!),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Mini Map Pin (48×48 interactive map thumbnail) ─────────────────────────

class _MiniMapPin extends StatelessWidget {
  final double lat, lng;
  const _MiniMapPin({required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    final point = LatLng(lat, lng);
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: SizedBox(
        width: 48, height: 48,
        child: Stack(children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: point,
              initialZoom: 13,
              interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.e_commerce',
              ),
            ],
          ),
          Center(
            child: Container(
              width: 14, height: 14,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primaryColor.withOpacity(0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Supporting Widgets ──────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String   text;
  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: AppColor.greyLight),
      const SizedBox(width: 3),
      Flexible(
        child: Text(text,
            style: AppTextStyle.labelSmall.copyWith(fontSize: 11),
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    ],
  );
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: isActive ? AppColor.successLight : AppColor.secondBackground,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isActive
            ? AppColor.success.withOpacity(0.35)
            : AppColor.greyBorder,
      ),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 5, height: 5,
        decoration: BoxDecoration(
          color: isActive ? AppColor.success : AppColor.greyLight,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 4),
      Text(
        isActive ? 'branch_status_active'.tr : 'branch_status_inactive'.tr,
        style: AppTextStyle.chip.copyWith(
          color: isActive ? AppColor.successDark : AppColor.greyLight,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    ]),
  );
}

class _MapBadge extends StatelessWidget {
  const _MapBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: AppColor.infoLight,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.location_on_rounded, size: 10, color: AppColor.info),
      const SizedBox(width: 3),
      Text('branch_has_location'.tr,
          style: AppTextStyle.chip.copyWith(color: AppColor.info, fontSize: 9)),
    ]),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   text;
  final Widget?  trailing;
  const _InfoRow({required this.icon, required this.text, this.trailing});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 13, color: AppColor.greyLight),
    const SizedBox(width: 6),
    Expanded(
      child: Text(text,
          style: AppTextStyle.labelSmall.copyWith(fontSize: 11),
          maxLines: 1, overflow: TextOverflow.ellipsis),
    ),
    if (trailing != null) ...[ const SizedBox(width: 6), trailing! ],
  ]);
}

class _ActionBtn extends StatelessWidget {
  final IconData      icon;
  final Color         color, bg;
  final VoidCallback? onTap;
  const _ActionBtn({required this.icon, required this.color, required this.bg, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 34, height: 34,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 16, color: color),
    ),
  );
}

// ─── FAB ─────────────────────────────────────────────────────────────────────

class _AddFab extends StatelessWidget {
  final SellerBranchesController ctrl;
  const _AddFab({required this.ctrl});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          ctrl.initForm();
          Get.toNamed(AppRoute.branchForm);
        },
        icon: const Icon(Icons.add_rounded, size: 22, color: Colors.white),
        label: Text('branch_add_new'.tr, style: AppTextStyle.buttonMedium),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          elevation: 6,
          shadowColor: AppColor.primaryColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    ),
  );
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyBranches extends StatelessWidget {
  const _EmptyBranches();

  @override
  Widget build(BuildContext context) => ListView(
    children: [
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.55,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96, height: 96,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColor.primaryColor.withOpacity(0.12),
                        AppColor.primaryColor.withOpacity(0.06),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.store_outlined,
                      size: 46, color: AppColor.primaryColor),
                ),
                const SizedBox(height: 22),
                Text('branch_empty_title'.tr,
                    style: AppTextStyle.heading3,
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('branch_empty_body'.tr,
                    style: AppTextStyle.bodyMedium.copyWith(color: AppColor.grey),
                    textAlign: TextAlign.center),
                const SizedBox(height: 28),
                Text('branch_empty_cta'.tr,
                    style: AppTextStyle.labelSmall.copyWith(
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

// ─── Shimmer ─────────────────────────────────────────────────────────────────

class _BranchesShimmer extends StatelessWidget {
  const _BranchesShimmer();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      ...List.generate(3, (_) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: ShimmerBox(width: double.infinity, height: 180, radius: 16),
      )),
    ]),
  );
}
