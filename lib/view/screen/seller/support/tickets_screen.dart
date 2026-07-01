import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_support_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/data/model/seller/support_models.dart';
import 'package:e_commerce/view/widget/seller/dashboard/shimmer_box.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<SellerSupportControllerImp>(
      builder: (c) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        appBar: _TicketsAppBar(ctrl: c),
        body: c.statusRequest == StatusRequest.loading
            ? const _TicketsShimmer()
            : Column(children: [
                _FilterTabs(ctrl: c),
                Expanded(
                  child: c.filteredTickets.isEmpty
                      ? _EmptyState()
                      : RefreshIndicator(
                          onRefresh: () async => c.loadTickets(),
                          color: AppColor.primaryColor,
                          backgroundColor: Colors.white,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                            itemCount: c.filteredTickets.length,
                            itemBuilder: (_, i) => _TicketCard(
                              ticket: c.filteredTickets[i],
                              index: i,
                            ),
                          ),
                        ),
                ),
              ]),
        floatingActionButton: _OpenTicketFab(ctrl: c),
      ),
    );
  }
}

class _TicketsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SellerSupportControllerImp ctrl;
  const _TicketsAppBar({required this.ctrl});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: AppColor.primaryColor,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
      onPressed: () => Get.back(),
    ),
    title: Text('all_tickets'.tr, style: AppTextStyle.appBarTitle),
    centerTitle: true,
    actions: [
      if (ctrl.unreadCount > 0)
        Container(
          margin: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xffFFD700),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${ctrl.unreadCount} ${'support_new_reply'.tr}',
            style: AppTextStyle.badge.copyWith(color: AppColor.black, fontSize: 10),
          ),
        ),
    ],
  );
}

class _FilterTabs extends StatelessWidget {
  final SellerSupportControllerImp ctrl;
  const _FilterTabs({required this.ctrl});

  static const _tabs = [
    ('all',     'filter_all',     null),
    ('open',    'filter_open',    AppColor.primaryColor),
    ('pending', 'filter_pending', AppColor.warning),
    ('closed',  'filter_closed',  AppColor.success),
  ];

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
    child: Row(children: [
      ..._tabs.map((tab) {
        final isActive = ctrl.selectedFilter == tab.$1;
        final color    = tab.$3 ?? AppColor.primaryColor;
        final count    = _count(ctrl, tab.$1);
        return Expanded(
          child: GestureDetector(
            onTap: () => ctrl.changeFilter(tab.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tab.$2.tr,
                    style: AppTextStyle.labelSmall.copyWith(
                      fontSize: 10.5,
                      color:  isActive ? Colors.white : AppColor.grey,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$count',
                      style: AppTextStyle.badge.copyWith(
                        fontSize: 10,
                        color: isActive ? Colors.white.withOpacity(0.85) : color,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    ]),
  );

  int _count(SellerSupportControllerImp c, String filter) {
    switch (filter) {
      case 'open':    return c.openCount;
      case 'pending': return c.pendingCount;
      case 'closed':  return c.closedCount;
      default:        return 0;
    }
  }
}

class _TicketCard extends StatefulWidget {
  final TicketModel ticket;
  final int index;
  const _TicketCard({required this.ticket, required this.index});

  @override
  State<_TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<_TicketCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.ticket;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: () => Get.toNamed(AppRoute.ticketDetails, arguments: t),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColor.cardShadow,
              border: Border(
                left: BorderSide(color: t.statusColor, width: 4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColor.secondBackground,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColor.greyBorder),
                      ),
                      child: Text(t.ticketNumber,
                          style: AppTextStyle.orderNumber.copyWith(
                              fontSize: 10.5, color: AppColor.grey)),
                    ),
                    const Spacer(),
                    if (t.hasNewReply)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColor.primarySurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColor.primaryColor.withOpacity(0.3)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            width: 6, height: 6,
                            decoration: const BoxDecoration(
                                color: AppColor.primaryColor,
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text('support_new_reply'.tr,
                              style: AppTextStyle.badge.copyWith(
                                  color: AppColor.primaryColor, fontSize: 9)),
                        ]),
                      ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: t.statusLightColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(t.statusLabel,
                          style: AppTextStyle.chip.copyWith(
                              color: t.statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 9.5)),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Text(t.title,
                      style: AppTextStyle.heading3.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text(t.lastMessage,
                      style: AppTextStyle.bodySmall.copyWith(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  Row(children: [
                    Icon(Icons.chat_bubble_outline_rounded,
                        size: 13, color: AppColor.greyLight),
                    const SizedBox(width: 4),
                    Text(
                      '${t.messagesCount} ${'ticket_messages_count'.tr}',
                      style: AppTextStyle.labelSmall.copyWith(fontSize: 10.5),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time_rounded,
                        size: 12, color: AppColor.greyLight),
                    const SizedBox(width: 4),
                    Text(t.lastMessageAt,
                        style: AppTextStyle.timestamp.copyWith(fontSize: 10.5)),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 11, color: AppColor.greyLight),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 80, height: 80,
        decoration: const BoxDecoration(
            color: AppColor.primarySurface, shape: BoxShape.circle),
        child: const Icon(Icons.confirmation_number_outlined,
            size: 36, color: AppColor.primaryColor),
      ),
      const SizedBox(height: 16),
      Text('no_tickets'.tr,
          style: AppTextStyle.heading3.copyWith(color: AppColor.grey)),
      const SizedBox(height: 6),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Text('no_tickets_sub'.tr,
            style: AppTextStyle.bodyMedium,
            textAlign: TextAlign.center),
      ),
    ]),
  );
}

class _OpenTicketFab extends StatelessWidget {
  final SellerSupportControllerImp ctrl;
  const _OpenTicketFab({required this.ctrl});

  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
    onPressed: () {
      ctrl.prepareNewTicketForm();
      Get.back();
    },
    backgroundColor: AppColor.primaryColor,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    icon: const Icon(Icons.add_rounded, color: Colors.white),
    label: Text('open_new_ticket'.tr, style: AppTextStyle.buttonSmall),
  );
}

class _TicketsShimmer extends StatelessWidget {
  const _TicketsShimmer();

  @override
  Widget build(BuildContext context) => ListView.builder(
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    itemCount: 5,
    itemBuilder: (_, __) => Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColor.cardShadow,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(children: [
            ShimmerBox(width: 80, height: 20, radius: 6),
            Spacer(),
            ShimmerBox(width: 60, height: 20, radius: 20),
          ]),
          SizedBox(height: 10),
          ShimmerBox(width: 200, height: 14),
          SizedBox(height: 8),
          ShimmerBox(width: double.infinity, height: 12),
          SizedBox(height: 6),
          ShimmerBox(width: 150, height: 12),
        ],
      ),
    ),
  );
}
