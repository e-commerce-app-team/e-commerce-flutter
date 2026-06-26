import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:e_commerce/controller/seller/seller_support_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/data/model/seller/support_models.dart';
import 'package:e_commerce/view/widget/seller/dashboard/shimmer_box.dart';

class SupportCenterScreen extends StatelessWidget {
  const SupportCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SellerSupportControllerImp>(
      init: SellerSupportControllerImp(),
      builder: (ctrl) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        body: ctrl.statusRequest == StatusRequest.loading
            ? const _SupportShimmer()
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverAppBar(ctrl),
                  SliverToBoxAdapter(child: _QuickContactSection()),
                  SliverToBoxAdapter(child: _FaqSection(ctrl: ctrl)),
                  SliverToBoxAdapter(child: _RecentTicketsSection(ctrl: ctrl)),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
        floatingActionButton: _NewTicketFab(ctrl: ctrl),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(SellerSupportControllerImp ctrl) {
    return SliverAppBar(
      expandedHeight: 170,
      pinned: true,
      stretch: true,
      backgroundColor: AppColor.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          decoration: const BoxDecoration(gradient: AppColor.headerGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.25)),
                        ),
                        child: const Icon(Icons.headset_mic_rounded,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('support_center'.tr,
                                style: AppTextStyle.heading2.copyWith(color: Colors.white)),
                            Text('support_welcome_sub'.tr,
                                style: AppTextStyle.bodySmall
                                    .copyWith(color: Colors.white.withOpacity(0.75), fontSize: 11)),
                          ],
                        ),
                      ),
                      if (ctrl.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xffFFD700),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${ctrl.unreadCount} ${'support_new_reply'.tr}',
                            style: AppTextStyle.badge.copyWith(
                                color: AppColor.black, fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    _StatPill(
                      icon: Icons.confirmation_number_outlined,
                      label: '${ctrl.openCount} ${'ticket_status_open'.tr}',
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    _StatPill(
                      icon: Icons.hourglass_top_rounded,
                      label: '${ctrl.pendingCount} ${'ticket_status_pending'.tr}',
                      color: const Color(0xffFFD700),
                    ),
                    const SizedBox(width: 8),
                    _StatPill(
                      icon: Icons.timer_outlined,
                      label: 'avg_response'.tr,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
        title: Text('support_center'.tr,
            style: AppTextStyle.appBarTitle.copyWith(fontSize: 16)),
        titlePadding: const EdgeInsetsDirectional.only(start: 56, bottom: 14),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.2)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11, color: color),
      const SizedBox(width: 4),
      Text(label, style: AppTextStyle.badge.copyWith(color: color, fontSize: 9.5)),
    ]),
  );
}

class _QuickContactSection extends StatelessWidget {
  const _QuickContactSection();

  static final List<Map<String, dynamic>> _contacts = [
    {
      'label':    'contact_whatsapp',
      'icon':     Icons.chat_rounded,
      'gradient': [const Color(0xff25D366), const Color(0xff128C7E)],
      'url':      'https://wa.me/+963947989738?text=مرحباً،%20أحتاج%20دعماً%20بخصوص%20متجري',
    },
    {
      'label':    'contact_email',
      'icon':     Icons.email_rounded,
      'gradient': [const Color(0xff185FA5), const Color(0xff0D47A1)],
      'url':      'mailto:alaaaldoos123@gmail.com',
    },
    {
      'label':    'contact_call',
      'icon':     Icons.phone_rounded,
      'gradient': [const Color(0xffFF6300), const Color(0xffCC4F00)],
      'url':      'tel:+963947989738',
    },
    {
      'label':    'contact_website',
      'icon':     Icons.language_rounded,
      'gradient': [const Color(0xff6d18d5), const Color(0xff4a0d9c)],
      'url':      'https://support.platform.com',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'contact_us_title'.tr,
            icon: Icons.support_agent_rounded,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _contacts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => _ContactCard(data: _contacts[i], index: i),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final int index;
  const _ContactCard({required this.data, required this.index});

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
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
    final colors = widget.data['gradient'] as List<Color>;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: () => _launch(widget.data['url'] as String),
          child: Container(
            width: 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.data['icon'] as IconData,
                    color: Colors.white, size: 26),
                const SizedBox(height: 7),
                Text(
                  (widget.data['label'] as String).tr,
                  style: AppTextStyle.badge.copyWith(fontSize: 9.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _FaqSection extends StatelessWidget {
  final SellerSupportControllerImp ctrl;
  const _FaqSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<FaqItemModel>>{};
    for (final faq in ctrl.faqs) {
      grouped.putIfAbsent(faq.category, () => []).add(faq);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'faq_title'.tr,
            icon: Icons.help_outline_rounded,
          ),
          const SizedBox(height: 4),
          Text('faq_subtitle'.tr,
              style: AppTextStyle.bodySmall.copyWith(fontSize: 12)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColor.cardShadow,
            ),
            child: Column(
              children: grouped.entries.map((entry) {
                final isLast = entry.key == grouped.keys.last;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                      child: Row(children: [
                        Container(
                          width: 4, height: 14,
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(entry.key,
                            style: AppTextStyle.labelLarge.copyWith(
                                fontSize: 12, color: AppColor.primaryColor)),
                      ]),
                    ),
                    ...entry.value.asMap().entries.map((e) => _FaqItem(
                          item: e.value,
                          isLast: e.key == entry.value.length - 1 && isLast,
                        )),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final FaqItemModel item;
  final bool isLast;
  const _FaqItem({required this.item, required this.isLast});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _iconAnim;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _iconAnim = Tween<double>(begin: 0, end: 0.5).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      InkWell(
        onTap: _toggle,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(children: [
            Expanded(
              child: Text(
                widget.item.question,
                style: AppTextStyle.labelLarge.copyWith(
                    fontSize: 13,
                    color: _expanded ? AppColor.primaryColor : AppColor.black),
              ),
            ),
            const SizedBox(width: 8),
            RotationTransition(
              turns: _iconAnim,
              child: Icon(
                Icons.expand_more_rounded,
                color: _expanded ? AppColor.primaryColor : AppColor.greyLight,
                size: 20,
              ),
            ),
          ]),
        ),
      ),
      AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: _expanded
            ? Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColor.primaryColor.withOpacity(0.15)),
                ),
                child: Text(widget.item.answer,
                    style: AppTextStyle.bodySmall
                        .copyWith(fontSize: 12.5, height: 1.7,
                            color: AppColor.black.withOpacity(0.75))),
              )
            : const SizedBox.shrink(),
      ),
      if (!widget.isLast)
        Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: AppColor.greyBorder.withOpacity(0.6)),
    ]);
  }
}

class _RecentTicketsSection extends StatelessWidget {
  final SellerSupportControllerImp ctrl;
  const _RecentTicketsSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionTitle(
                title: 'recent_tickets'.tr,
                icon: Icons.confirmation_number_outlined,
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoute.sellerTickets),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('all_tickets'.tr,
                      style: AppTextStyle.labelMedium.copyWith(
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 11, color: AppColor.primaryColor),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (ctrl.recentTickets.isEmpty)
            _EmptyTickets()
          else
            ...ctrl.recentTickets.asMap().entries.map(
              (e) => _TicketPreviewCard(ticket: e.value, index: e.key),
            ),
        ],
      ),
    );
  }
}

class _EmptyTickets extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppColor.cardShadow,
    ),
    child: Column(children: [
      Container(
        width: 60, height: 60,
        decoration: const BoxDecoration(
            color: AppColor.primarySurface, shape: BoxShape.circle),
        child: const Icon(Icons.confirmation_number_outlined,
            color: AppColor.primaryColor, size: 28),
      ),
      const SizedBox(height: 12),
      Text('no_tickets'.tr,
          style: AppTextStyle.heading3.copyWith(
              color: AppColor.grey, fontSize: 14)),
      const SizedBox(height: 4),
      Text('no_tickets_sub'.tr,
          style: AppTextStyle.bodySmall,
          textAlign: TextAlign.center),
    ]),
  );
}

class _TicketPreviewCard extends StatefulWidget {
  final TicketModel ticket;
  final int index;
  const _TicketPreviewCard({required this.ticket, required this.index});

  @override
  State<_TicketPreviewCard> createState() => _TicketPreviewCardState();
}

class _TicketPreviewCardState extends State<_TicketPreviewCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
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
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppColor.cardShadow,
              border: Border(
                left: BorderSide(color: t.statusColor, width: 3.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(t.ticketNumber,
                        style: AppTextStyle.orderNumber.copyWith(fontSize: 11)),
                    const Spacer(),
                    if (t.hasNewReply)
                      Container(
                        width: 8, height: 8,
                        margin: const EdgeInsets.only(left: 6),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(
                            color: AppColor.primaryColor.withOpacity(0.4),
                            blurRadius: 4,
                          )],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
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
                  const SizedBox(height: 5),
                  Text(t.title,
                      style: AppTextStyle.labelLarge.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [
                    Expanded(
                      child: Text(t.lastMessage,
                          style: AppTextStyle.bodySmall
                              .copyWith(fontSize: 11.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Text(t.lastMessageAt,
                        style: AppTextStyle.timestamp.copyWith(fontSize: 10)),
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

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: AppColor.primarySurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: AppColor.primaryColor),
      ),
      const SizedBox(width: 8),
      Text(title, style: AppTextStyle.heading3.copyWith(fontSize: 15)),
    ],
  );
}

class _NewTicketFab extends StatelessWidget {
  final SellerSupportControllerImp ctrl;
  const _NewTicketFab({required this.ctrl});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xff8d0ea8), Color(0xff6d18d5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppColor.primaryShadow,
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ctrl.prepareNewTicketForm();
          _showNewTicketSheet(context, ctrl);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('open_new_ticket'.tr, style: AppTextStyle.buttonMedium),
          ]),
        ),
      ),
    ),
  );
}

void _showNewTicketSheet(
    BuildContext context, SellerSupportControllerImp ctrl) {
  Get.bottomSheet(
    _NewTicketSheet(ctrl: ctrl),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
  );
}

class _NewTicketSheet extends StatelessWidget {
  final SellerSupportControllerImp ctrl;
  const _NewTicketSheet({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return GetBuilder<SellerSupportControllerImp>(
      builder: (c) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFFF9FAFB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          _SheetDragHandle(),
          _SheetHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 8, 16, bottom + 16),
              child: Form(
                key: c.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FormLabel('ticket_subject_label'.tr),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SupportSubjectType.all.map((s) {
                        final active = c.formSubjectKey == s.key;
                        return GestureDetector(
                          onTap: () => c.setFormSubject(s.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColor.primaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active
                                    ? AppColor.primaryColor
                                    : AppColor.greyBorder,
                                width: active ? 1.5 : 1,
                              ),
                              boxShadow:
                                  active ? AppColor.primaryShadow : null,
                            ),
                            child: Text(s.label,
                                style: AppTextStyle.chip.copyWith(
                                  color: active
                                      ? Colors.white
                                      : AppColor.grey,
                                  fontWeight: active
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 11.5,
                                )),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    _FormLabel('ticket_title_label'.tr),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: c.titleCtrl,
                      style: AppTextStyle.inputText,
                      decoration: _inputDeco(
                          'ticket_title_hint'.tr,
                          Icons.title_rounded),
                      validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'ticket_field_required'.tr
                              : null,
                    ),
                    const SizedBox(height: 14),
                    _FormLabel('ticket_message_label'.tr),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: c.messageCtrl,
                      maxLines: 5,
                      style: AppTextStyle.inputText,
                      decoration: _inputDeco(
                          'ticket_message_hint'.tr,
                          Icons.message_outlined),
                      validator: (v) =>
                          v == null || v.trim().length < 10
                              ? 'ticket_field_required'.tr
                              : null,
                    ),
                    const SizedBox(height: 16),
                    _FormLabel('ticket_images_label'.tr),
                    const SizedBox(height: 8),
                    Row(children: [
                      ...c.attachments.asMap().entries.map((e) => Stack(
                        children: [
                          Container(
                            width: 64, height: 64,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                  image: FileImage(e.value),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: 2, right: 2,
                            child: GestureDetector(
                              onTap: () => c.removeAttachment(e.key),
                              child: Container(
                                width: 18, height: 18,
                                decoration: const BoxDecoration(
                                    color: AppColor.error,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.close,
                                    size: 12, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )),
                      if (c.attachments.length < 3)
                        GestureDetector(
                          onTap: c.pickAttachment,
                          child: Container(
                            width: 64, height: 64,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: AppColor.secondBackground,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColor.greyBorder,
                                  style: BorderStyle.solid),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 22, color: AppColor.greyLight),
                              ],
                            ),
                          ),
                        ),
                    ]),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: c.formStatusRequest == StatusRequest.loading
                            ? null
                            : c.submitTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: c.formStatusRequest == StatusRequest.loading
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : Text('submit_ticket'.tr,
                                style: AppTextStyle.buttonLarge),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _SheetDragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 4),
    child: Center(
      child: Container(
        width: 40, height: 4,
        decoration: BoxDecoration(
          color: AppColor.greyBorder,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ),
  );
}

class _SheetHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [BoxShadow(
        color: AppColor.shadow,
        blurRadius: 4,
        offset: const Offset(0, 2),
      )],
    ),
    child: Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff8d0ea8), Color(0xff6d18d5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.confirmation_number_outlined,
            color: Colors.white, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('new_ticket_title'.tr,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColor.textPrimary)),
          Text('new_ticket_sub'.tr,
              style: const TextStyle(fontSize: 11, color: AppColor.greyText)),
        ],
      )),
      IconButton(
        onPressed: Get.back,
        icon: const Icon(Icons.close_rounded, color: AppColor.greyText),
      ),
    ]),
  );
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTextStyle.labelLarge.copyWith(
        fontSize: 13, color: AppColor.primaryColor),
  );
}

InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
  hintText: hint,
  hintStyle: AppTextStyle.inputHint,
  prefixIcon: Icon(icon, size: 18, color: AppColor.greyText),
  filled: true,
  fillColor: Colors.white,
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
  border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColor.greyBorder)),
  enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColor.greyBorder)),
  focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColor.primaryColor, width: 1.5)),
  errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColor.error)),
  focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColor.error, width: 1.5)),
);

class _SupportShimmer extends StatelessWidget {
  const _SupportShimmer();

  @override
  Widget build(BuildContext context) => CustomScrollView(
    physics: const NeverScrollableScrollPhysics(),
    slivers: [
      SliverToBoxAdapter(
        child: Container(
          height: 200,
          decoration: const BoxDecoration(gradient: AppColor.headerGradient),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            const ShimmerBox(width: double.infinity, height: 96, radius: 14),
            const SizedBox(height: 16),
            const ShimmerBox(width: double.infinity, height: 220, radius: 14),
            const SizedBox(height: 16),
            ...List.generate(3, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ShimmerBox(
                  width: double.infinity, height: 80, radius: 14),
            )),
          ]),
        ),
      ),
    ],
  );
}
