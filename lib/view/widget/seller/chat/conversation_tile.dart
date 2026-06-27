import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/chat_models.dart';

class ConversationTile extends StatefulWidget {
  final ConversationModel conversation;
  final int               index;
  final VoidCallback      onTap;
  final VoidCallback      onArchive;
  final VoidCallback      onBlock;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.index,
    required this.onTap,
    required this.onArchive,
    required this.onBlock,
  });

  @override
  State<ConversationTile> createState() => _ConversationTileState();
}

class _ConversationTileState extends State<ConversationTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.06, 0), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.index * 55), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c         = widget.conversation;
    final hasUnread = c.unreadSeller > 0;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Dismissible(
          key: ValueKey(c.id),
          direction: DismissDirection.endToStart,
          background: _SwipeBackground(),
          confirmDismiss: (_) async {
            _showContextMenu(context);
            return false;
          },
          child: GestureDetector(
            onTap: widget.onTap,
            onLongPress: () => _showContextMenu(context),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: hasUnread ? AppColor.primarySurface : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppColor.cardShadow,
                border: Border.all(
                  color: hasUnread
                      ? AppColor.primaryColor.withOpacity(0.25)
                      : AppColor.greyBorder,
                  width: hasUnread ? 1.3 : 0.8,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    _Avatar(initials: c.avatarInitials, hasUnread: hasUnread),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // اسم + وقت
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  c.buyerName,
                                  style: AppTextStyle.labelLarge.copyWith(
                                    fontSize: 13.5,
                                    fontWeight: hasUnread
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                c.formattedTime,
                                style: AppTextStyle.timestamp.copyWith(
                                  color: hasUnread
                                      ? AppColor.primaryColor
                                      : AppColor.greyLight,
                                  fontWeight: hasUnread
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // رقم الطلب
                          if (c.orderId != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColor.infoLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                c.orderId!,
                                style: AppTextStyle.labelSmall.copyWith(
                                  color: AppColor.info,
                                  fontSize: 9.5,
                                  fontFamily: 'PlayfairDisplay',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                          ],

                          // آخر رسالة + badge
                          Row(children: [
                            Expanded(
                              child: Text(
                                c.lastMessage,
                                style: AppTextStyle.bodySmall.copyWith(
                                  fontSize: 12,
                                  color: hasUnread
                                      ? AppColor.black
                                      : AppColor.grey,
                                  fontWeight: hasUnread
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasUnread) ...[
                              const SizedBox(width: 8),
                              Container(
                                constraints: const BoxConstraints(
                                    minWidth: 20, minHeight: 20),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColor.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  c.unreadSeller > 99
                                      ? '99+'
                                      : '${c.unreadSeller}',
                                  style: AppTextStyle.badge.copyWith(fontSize: 9),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ContextMenuSheet(
        conversation: widget.conversation,
        onArchive: () { Get.back(); widget.onArchive(); },
        onBlock:   () { Get.back(); widget.onBlock();   },
        onReport:  () { Get.back(); _showReportDialog(context); },
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _ReportDialog(conversation: widget.conversation),
    );
  }
}

// ── Swipe Background ──────────────────────────────────────────────────────────
class _SwipeBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: AppColor.error.withOpacity(0.1),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColor.error.withOpacity(0.3)),
    ),
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.more_horiz_rounded, color: AppColor.error, size: 22),
        const SizedBox(height: 3),
        Text('خيارات', style: AppTextStyle.labelSmall.copyWith(
            color: AppColor.error, fontSize: 9)),
      ],
    ),
  );
}

// ── Context Menu Sheet ────────────────────────────────────────────────────────
class _ContextMenuSheet extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onArchive;
  final VoidCallback onBlock;
  final VoidCallback onReport;

  const _ContextMenuSheet({
    required this.conversation,
    required this.onArchive,
    required this.onBlock,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
              color: AppColor.greyBorder,
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 16),

        // اسم المستخدم
        Row(children: [
          _Avatar(initials: conversation.avatarInitials, hasUnread: false),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(conversation.buyerName,
                style: AppTextStyle.labelLarge.copyWith(fontSize: 14)),
            if (conversation.orderId != null)
              Text(conversation.orderId!,
                  style: AppTextStyle.labelSmall.copyWith(
                      color: AppColor.info, fontFamily: 'PlayfairDisplay')),
          ]),
        ]),
        const SizedBox(height: 16),
        const Divider(color: AppColor.greyBorder, height: 1),
        const SizedBox(height: 12),

        _MenuRow(
          icon: Icons.archive_outlined,
          label: 'archive_conversation'.tr,
          color: AppColor.grey,
          onTap: onArchive,
        ),
        _MenuRow(
          icon: Icons.flag_outlined,
          label: 'report_user'.tr,
          color: AppColor.warning,
          onTap: onReport,
        ),
        _MenuRow(
          icon: Icons.block_outlined,
          label: 'block_user'.tr,
          color: AppColor.error,
          onTap: onBlock,
          isLast: true,
        ),
      ]),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isLast;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Column(children: [
    ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 19),
      ),
      title: Text(label,
          style: AppTextStyle.labelLarge.copyWith(
              color: color, fontSize: 14)),
      onTap: onTap,
    ),
    if (!isLast) const Divider(color: AppColor.greyBorder, height: 1),
  ]);
}

// ── Report Dialog ─────────────────────────────────────────────────────────────
class _ReportDialog extends StatefulWidget {
  final ConversationModel conversation;
  const _ReportDialog({required this.conversation});

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  String? _selected;

  final _reasons = [
    'spam_messages',
    'abusive_language',
    'inappropriate_content',
    'fake_buyer',
    'other_reason',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
                color: AppColor.warningLight, shape: BoxShape.circle),
            child: const Icon(Icons.flag_outlined,
                color: AppColor.warning, size: 26),
          ),
          const SizedBox(height: 12),
          Text('report_user'.tr, style: AppTextStyle.heading3),
          const SizedBox(height: 4),
          Text(widget.conversation.buyerName,
              style: AppTextStyle.labelMedium.copyWith(
                  color: AppColor.primaryColor)),
          const SizedBox(height: 16),

          ..._reasons.map((r) => GestureDetector(
            onTap: () => setState(() => _selected = r),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: _selected == r
                    ? AppColor.warningLight
                    : AppColor.secondBackground,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: _selected == r
                      ? AppColor.warning
                      : AppColor.greyBorder,
                ),
              ),
              child: Text(r.tr,
                  style: AppTextStyle.labelLarge.copyWith(
                    color: _selected == r
                        ? AppColor.warningDark
                        : AppColor.black,
                    fontSize: 13,
                  )),
            ),
          )),
          const SizedBox(height: 8),

          Row(children: [
            Expanded(
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text('cancel'.tr,
                    style: AppTextStyle.buttonSmall.copyWith(
                        color: AppColor.grey)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _selected == null ? null : () {
                  Get.back();
                  Get.snackbar(
                    'report_submitted'.tr, 'report_submitted_msg'.tr,
                    backgroundColor: AppColor.warningLight,
                    colorText: AppColor.warningDark,
                    icon: const Icon(Icons.flag_outlined,
                        color: AppColor.warning),
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.warning,
                  disabledBackgroundColor: AppColor.greyLight,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('submit_report'.tr,
                    style: AppTextStyle.buttonMedium),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String initials;
  final bool   hasUnread;
  const _Avatar({required this.initials, required this.hasUnread});

  static const _colors = [
    Color(0xffFF8C42), Color(0xff185FA5), Color(0xff27AE60),
    Color(0xff8E44AD), Color(0xffE74C3C), Color(0xff16A085),
  ];

  @override
  Widget build(BuildContext context) {
    final color = initials.isNotEmpty
        ? _colors[initials.codeUnitAt(0) % _colors.length]
        : AppColor.primaryColor;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: hasUnread
                  ? AppColor.primaryColor.withOpacity(0.5)
                  : color.withOpacity(0.25),
              width: hasUnread ? 2.2 : 1.5,
            ),
          ),
          child: Center(
            child: Text(
              initials.toUpperCase(),
              style: AppTextStyle.labelLarge.copyWith(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 1, right: 1,
          child: Container(
            width: 12, height: 12,
            decoration: BoxDecoration(
              color: AppColor.success,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
