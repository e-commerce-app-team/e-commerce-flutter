import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        appBar: _BranchesAppBar(ctrl: ctrl),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: ctrl.statusRequest == StatusRequest.loading
            ? const _BranchesShimmer()
            : RefreshIndicator(
                onRefresh: ctrl.loadBranches,
                color: AppColor.primaryColor,
                backgroundColor: Colors.white,
                child: ctrl.branches.isEmpty
                    ? const _EmptyBranches()
                    : CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 16, 16, 100),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                _SummaryRow(ctrl: ctrl),
                                const SizedBox(height: 16),
                                ...ctrl.branches.asMap().entries.map(
                                      (e) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: _BranchCard(
                                          branch: e.value,
                                          index:  e.key,
                                          ctrl:   ctrl,
                                        ),
                                      ),
                                    ),
                              ]),
                            ),
                          ),
                        ],
                      ),
              ),
        floatingActionButton: _AddFab(ctrl: ctrl),
      ),
    );
  }
}

class _BranchesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SellerBranchesController ctrl;
  const _BranchesAppBar({required this.ctrl});

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
        title: Text('branch_screen_title'.tr, style: AppTextStyle.appBarTitle),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(left: 12, top: 11, bottom: 11),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.35)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.business_center_outlined,
                  size: 12, color: Colors.white),
              const SizedBox(width: 4),
              Text('branch_companies_badge'.tr,
                  style: AppTextStyle.badge
                      .copyWith(color: Colors.white, fontSize: 10)),
            ]),
          ),
        ],
      );
}

class _SummaryRow extends StatelessWidget {
  final SellerBranchesController ctrl;
  const _SummaryRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final active = ctrl.branches.where((b) => b.isActive).length;
    final total  = ctrl.branches.length;
    final products = ctrl.branches.fold<int>(
        0, (sum, b) => sum + b.productCount);

    return Row(children: [
      _SumBox(
        icon:  Icons.store_outlined,
        bg:    AppColor.primarySurface,
        color: AppColor.primaryColor,
        label: 'branch_total'.tr,
        value: '$total',
      ),
      const SizedBox(width: 10),
      _SumBox(
        icon:  Icons.check_circle_outline_rounded,
        bg:    AppColor.successLight,
        color: AppColor.success,
        label: 'branch_active'.tr,
        value: '$active',
      ),
      const SizedBox(width: 10),
      _SumBox(
        icon:  Icons.inventory_2_outlined,
        bg:    AppColor.warningLight,
        color: AppColor.warning,
        label: 'branch_products'.tr,
        value: '$products',
      ),
    ]);
  }
}

class _SumBox extends StatelessWidget {
  final IconData icon;
  final Color    bg, color;
  final String   label, value;
  const _SumBox({
    required this.icon, required this.bg, required this.color,
    required this.label, required this.value,
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
              width: 34, height: 34,
              decoration:
                  BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 7),
            Text(value,
                style: AppTextStyle.statNumberSmall.copyWith(fontSize: 18)),
            Text(label,
                style: AppTextStyle.labelSmall
                    .copyWith(fontSize: 10),
                textAlign: TextAlign.center),
          ]),
        ),
      );
}

class _BranchCard extends StatefulWidget {
  final BranchModel              branch;
  final int                      index;
  final SellerBranchesController ctrl;
  const _BranchCard({
    required this.branch, required this.index, required this.ctrl,
  });

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
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fade  = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    Future.delayed(
        Duration(milliseconds: 40 + widget.index * 70),
        () { if (mounted) _anim.forward(); });
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final branch    = widget.branch;
    final ctrl      = widget.ctrl;
    final isDeleting = ctrl.deletingIds.contains(branch.id);
    final isToggling = ctrl.togglingIds.contains(branch.id);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isDeleting ? 0.4 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColor.cardShadow,
              border: Border.all(
                color: branch.isActive
                    ? AppColor.success.withOpacity(0.2)
                    : AppColor.greyBorder,
                width: 0.8,
              ),
            ),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                child: Row(children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: branch.isActive
                          ? AppColor.primarySurface
                          : AppColor.secondBackground,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.store_rounded,
                      size: 22,
                      color: branch.isActive
                          ? AppColor.primaryColor : AppColor.greyLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Row(children: [
                        Expanded(
                          child: Text(branch.name,
                              style: AppTextStyle.labelLarge
                                  .copyWith(fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        _ActiveBadge(isActive: branch.isActive),
                      ]),
                      const SizedBox(height: 3),
                      Row(children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 12, color: AppColor.greyLight),
                        const SizedBox(width: 3),
                        Text(branch.managerName,
                            style: AppTextStyle.labelSmall
                                .copyWith(fontSize: 11)),
                      ]),
                    ]),
                  ),
                ]),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Divider(height: 14, color: AppColor.greyBorder),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(children: [
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    text: branch.address,
                    trailing: branch.hasLocation
                        ? _MapBadge()
                        : null,
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    text: branch.phone,
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    icon: Icons.inventory_2_outlined,
                    text: '${'branch_products'.tr}: ${branch.productCount}',
                  ),
                ]),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Divider(height: 14, color: AppColor.greyBorder),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Row(children: [
                  isToggling
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColor.primaryColor))
                      : Switch(
                          value:       branch.isActive,
                          activeColor: AppColor.primaryColor,
                          onChanged: (_) => ctrl.toggleActive(branch.id!),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                  Text(
                    branch.isActive
                        ? 'branch_status_active'.tr
                        : 'branch_status_inactive'.tr,
                    style: AppTextStyle.labelSmall.copyWith(
                      fontSize: 11,
                      color: branch.isActive
                          ? AppColor.success : AppColor.greyLight,
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
                    onTap: isDeleting
                        ? null
                        : () => ctrl.deleteBranch(branch.id!),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  final bool isActive;
  const _ActiveBadge({required this.isActive});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isActive ? AppColor.successLight : AppColor.secondBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColor.success.withOpacity(0.4)
                : AppColor.greyBorder,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
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
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: AppColor.infoLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.location_on_rounded,
              size: 10, color: AppColor.info),
          const SizedBox(width: 3),
          Text('branch_has_location'.tr,
              style: AppTextStyle.chip.copyWith(
                  color: AppColor.info, fontSize: 9)),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 6),
          trailing!,
        ],
      ]);
}

class _ActionBtn extends StatelessWidget {
  final IconData     icon;
  final Color        color, bg;
  final VoidCallback? onTap;
  const _ActionBtn({
    required this.icon, required this.color,
    required this.bg,   this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
      );
}

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
            icon: const Icon(Icons.add_rounded,
                size: 22, color: Colors.white),
            label: Text('branch_add_new'.tr,
                style: AppTextStyle.buttonMedium),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              elevation: 6,
              shadowColor: AppColor.primaryColor.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      );
}

class _EmptyBranches extends StatelessWidget {
  const _EmptyBranches();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: AppColor.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.store_outlined,
                  size: 44, color: AppColor.primaryColor),
            ),
            const SizedBox(height: 20),
            Text('branch_empty_title'.tr,
                style: AppTextStyle.heading3),
            const SizedBox(height: 8),
            Text('branch_empty_body'.tr,
                style: AppTextStyle.bodyMedium,
                textAlign: TextAlign.center),
          ]),
        ),
      );
}

class _BranchesShimmer extends StatelessWidget {
  const _BranchesShimmer();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: const [
            Expanded(
                child: ShimmerBox(
                    width: double.infinity, height: 85, radius: 14)),
            SizedBox(width: 10),
            Expanded(
                child: ShimmerBox(
                    width: double.infinity, height: 85, radius: 14)),
            SizedBox(width: 10),
            Expanded(
                child: ShimmerBox(
                    width: double.infinity, height: 85, radius: 14)),
          ]),
          const SizedBox(height: 16),
          ...List.generate(
              3,
              (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: ShimmerBox(
                        width: double.infinity, height: 180, radius: 16),
                  )),
        ]),
      );
}
