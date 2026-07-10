import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_chat_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/chat_models.dart';
import 'package:e_commerce/view/widget/seller/chat/message_bubble.dart';

class ChatRoomScreen extends StatelessWidget {
  final ConversationModel conversation;
  const ChatRoomScreen({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    final tag = 'chat_${conversation.id}';
    Get.put(ChatRoomController(conversation), tag: tag);

    return GetBuilder<ChatRoomController>(
      tag: tag,
      builder: (ctrl) => Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: false,
        appBar: _ChatRoomAppBar(
          conversation: conversation,
          ctrl: ctrl,
        ),
        body: Stack(
          children: [
            // ── خلفية هندسية ─────────────────────────────────────────────
            const _ChatBackground(),

            // ── المحتوى ───────────────────────────────────────────────────
            Column(children: [
              Expanded(
                child: ctrl.messagesList.isEmpty
                    ? const _EmptyChat()
                    : _MessagesList(ctrl: ctrl),
              ),

              if (ctrl.showQuickReplies)
                QuickRepliesSheet(
                  replies:  Get.find<SellerChatController>().quickReplies,
                  onSelect: ctrl.applyQuickReply,
                ),

              ChatInputBar(
                controller:   ctrl.messageCtrl,
                isTyping:     ctrl.isTyping,
                onSend:       ctrl.sendMessage,
                onImage:      ctrl.sendImage,
                onQuickReply: ctrl.toggleQuickReplies,
                onChanged:    ctrl.onMessageChanged,
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// خلفية هندسية (نمط Geometric خفيف)
// ─────────────────────────────────────────────────────────────────────────────
class _ChatBackground extends StatelessWidget {
  const _ChatBackground();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _GeometricPatternPainter(),
      ),
    );
  }
}

class _GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // خلفية أساسية
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppColor.secondBackground,
    );

    final paint = Paint()
      ..color = AppColor.primaryColor.withOpacity(0.035)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppColor.primaryColor.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const spacing = 44.0;
    const dotRadius = 1.5;

    // نقاط شبكية خفيفة
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }

    // مربعات دوّارة كبيرة ← تعطي إحساس WhatsApp
    final shapes = [
      Offset(size.width * 0.85, size.height * 0.1),
      Offset(size.width * 0.1, size.height * 0.3),
      Offset(size.width * 0.9, size.height * 0.55),
      Offset(size.width * 0.05, size.height * 0.75),
      Offset(size.width * 0.7, size.height * 0.88),
    ];

    for (int i = 0; i < shapes.length; i++) {
      final center = shapes[i];
      final size2  = 40.0 + i * 14.0;
      final angle  = 0.3 + i * 0.25;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: size2, height: size2),
          const Radius.circular(8),
        ),
        strokePaint,
      );
      canvas.restore();
    }

    // خطوط قطرية خفيفة
    final linePaint = Paint()
      ..color = AppColor.primaryColor.withOpacity(0.025)
      ..strokeWidth = 1.0;
    for (double d = -size.height; d < size.width + size.height; d += 80) {
      canvas.drawLine(Offset(d, 0), Offset(d + size.height, size.height), linePaint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBar المحادثة
// ─────────────────────────────────────────────────────────────────────────────
class _ChatRoomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ConversationModel conversation;
  final ChatRoomController ctrl;
  const _ChatRoomAppBar({required this.conversation, required this.ctrl});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: AppColor.white, size: 20),
        onPressed: () => Get.back(),
      ),
      titleSpacing: 0,
      title: GestureDetector(
        onTap: () => _showBuyerInfo(context),
        child: Row(children: [
          _HeaderAvatar(initials: conversation.avatarInitials),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.buyerName,
                  style: AppTextStyle.appBarTitle.copyWith(fontSize: 15),
                ),
                Row(children: [
                  Container(
                    width: 7, height: 7,
                    decoration: const BoxDecoration(
                        color: AppColor.success, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'online_now'.tr,
                    style: AppTextStyle.labelSmall.copyWith(
                        color: AppColor.white.withOpacity(0.7), fontSize: 10),
                  ),
                ]),
              ],
            ),
          ),
        ]),
      ),
      actions: [
        if (conversation.orderId != null)
          Container(
            margin: const EdgeInsets.only(left: 4, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColor.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                conversation.orderId!,
                style: AppTextStyle.labelSmall.copyWith(
                    color: AppColor.white,
                    fontFamily: 'PlayfairDisplay',
                    fontWeight: FontWeight.w700,
                    fontSize: 10),
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded,
              color: AppColor.white, size: 22),
          onPressed: () => _showOptions(context),
        ),
      ],
    );
  }

  void _showBuyerInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BuyerInfoSheet(conversation: conversation),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: const BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: AppColor.greyBorder,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          _OptionTile(
            icon: Icons.info_outline_rounded,
            label: 'buyer_info'.tr,
            onTap: () { Get.back(); _showBuyerInfo(context); },
          ),
          _OptionTile(
            icon: Icons.archive_outlined,
            label: 'archive_conversation'.tr,
            onTap: () {
              Get.back();
              final chatCtrl = Get.find<SellerChatController>();
              chatCtrl.archiveConversation(conversation.id);
              Get.back();
            },
          ),
          _OptionTile(
            icon: Icons.flag_outlined,
            label: 'report_user'.tr,
            color: AppColor.warning,
            onTap: () {
              Get.back();
              _showReportDialog(context);
            },
          ),
          _OptionTile(
            icon: Icons.block_outlined,
            label: 'block_user'.tr,
            color: AppColor.error,
            isLast: true,
            onTap: () {
              Get.back();
              _confirmBlock(context);
            },
          ),
        ]),
      ),
    );
  }

  void _confirmBlock(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('block_user'.tr,
            style: AppTextStyle.heading3.copyWith(color: AppColor.error)),
        content: Text(
          '${'block_confirm_msg'.tr} ${conversation.buyerName}؟',
          style: AppTextStyle.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr,
                style: TextStyle(color: AppColor.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.error, elevation: 0),
            onPressed: () {
              final chatCtrl = Get.find<SellerChatController>();
              chatCtrl.blockUser(conversation.buyerId, conversation.id);
              Get.back();
              Get.back();
            },
            child: Text('block'.tr,
                style: AppTextStyle.buttonSmall),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    // نستخدم نفس _ReportDialog من conversation_tile
    Get.dialog(_ReportDialogSimple(buyerName: conversation.buyerName));
  }
}

class _HeaderAvatar extends StatelessWidget {
  final String initials;
  const _HeaderAvatar({required this.initials});

  static const _colors = [
    AppColor.primaryLight, AppColor.info, AppColor.success,
    AppColor.statOrders, AppColor.error, AppColor.warning,
  ];

  @override
  Widget build(BuildContext context) {
    final color = initials.isNotEmpty
        ? _colors[initials.codeUnitAt(0) % _colors.length]
        : AppColor.primaryColor;
    return Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: color.withOpacity(0.25),
        shape: BoxShape.circle,
        border: Border.all(color: AppColor.white.withOpacity(0.5), width: 1.5),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: AppTextStyle.labelLarge.copyWith(
              color: AppColor.white, fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

// ── Option Tile ───────────────────────────────────────────────────────────────
class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  final bool isLast;
  const _OptionTile({
    required this.icon, required this.label, required this.onTap,
    this.color, this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Column(children: [
    ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: (color ?? AppColor.grey).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? AppColor.grey, size: 19),
      ),
      title: Text(label,
          style: AppTextStyle.labelLarge.copyWith(
              color: color ?? AppColor.black, fontSize: 14)),
      onTap: onTap,
    ),
    if (!isLast) const Divider(color: AppColor.greyBorder, height: 1),
  ]);
}

// ── Buyer Info Sheet ──────────────────────────────────────────────────────────
class _BuyerInfoSheet extends StatelessWidget {
  final ConversationModel conversation;
  const _BuyerInfoSheet({required this.conversation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
              color: AppColor.greyBorder,
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 20),

        // Avatar كبير
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(
            color: AppColor.primaryColor.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColor.primaryColor.withOpacity(0.3), width: 2),
          ),
          child: Center(
            child: Text(
              conversation.avatarInitials.toUpperCase(),
              style: AppTextStyle.displaySmall.copyWith(
                  color: AppColor.primaryColor, fontSize: 28),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(conversation.buyerName, style: AppTextStyle.heading2),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(
                color: AppColor.success, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text('online_now'.tr,
              style: AppTextStyle.bodySmall.copyWith(color: AppColor.success)),
        ]),
        const SizedBox(height: 20),
        const Divider(color: AppColor.greyBorder),
        const SizedBox(height: 10),

        if (conversation.orderId != null)
          _InfoRow(
            icon: Icons.receipt_long_outlined,
            label: 'linked_order'.tr,
            value: conversation.orderId!,
            valueColor: AppColor.info,
          ),
        _InfoRow(
          icon: Icons.person_outline,
          label: 'buyer_id'.tr,
          value: '#${conversation.buyerId}',
        ),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({
    required this.icon, required this.label,
    required this.value, this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      Icon(icon, size: 18, color: AppColor.greyLight),
      const SizedBox(width: 10),
      Text(label,
          style: AppTextStyle.labelSmall.copyWith(fontSize: 12)),
      const Spacer(),
      Text(value,
          style: AppTextStyle.labelLarge.copyWith(
              fontSize: 13,
              color: valueColor ?? AppColor.black,
              fontFamily: valueColor != null ? 'PlayfairDisplay' : null)),
    ]),
  );
}

// ── Report Dialog Simple ──────────────────────────────────────────────────────
class _ReportDialogSimple extends StatefulWidget {
  final String buyerName;
  const _ReportDialogSimple({required this.buyerName});

  @override
  State<_ReportDialogSimple> createState() => _ReportDialogSimpleState();
}

class _ReportDialogSimpleState extends State<_ReportDialogSimple> {
  String? _selected;
  final _reasons = [
    'spam_messages', 'abusive_language',
    'inappropriate_content', 'fake_buyer', 'other_reason',
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
          Text(widget.buyerName,
              style: AppTextStyle.labelMedium.copyWith(
                  color: AppColor.primaryColor)),
          const SizedBox(height: 14),
          ..._reasons.map((r) => GestureDetector(
            onTap: () => setState(() => _selected = r),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 7),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _selected == r ? AppColor.warningLight : AppColor.secondBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _selected == r ? AppColor.warning : AppColor.greyBorder,
                ),
              ),
              child: Text(r.tr,
                  style: AppTextStyle.labelLarge.copyWith(
                    color: _selected == r ? AppColor.warningDark : AppColor.black,
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
                    style: TextStyle(color: AppColor.grey)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _selected == null ? null : () {
                  Get.back();
                  Get.snackbar(
                    'report_submitted'.tr, 'report_submitted_msg'.tr,
                    backgroundColor: AppColor.warningLight,
                    colorText: AppColor.warningDark,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.warning,
                  disabledBackgroundColor: AppColor.greyLight,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('submit_report'.tr, style: AppTextStyle.buttonMedium),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// قائمة الرسائل
// ─────────────────────────────────────────────────────────────────────────────
class _MessagesList extends StatelessWidget {
  final ChatRoomController ctrl;
  const _MessagesList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final msgs = ctrl.messagesList;
    final myId = ctrl.myId;

    return ListView.builder(
      reverse: true,
      controller: ctrl.scrollCtrl,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: msgs.length,
      itemBuilder: (_, i) {
        final msg    = msgs[i];
        final isMine = msg.senderId == myId;

        bool showTime = i == 0;
        if (!showTime && i < msgs.length - 1) {
          final curr = msg.createdAt;
          final next = msgs[i + 1].createdAt;
          if (curr != null && next != null) {
            showTime = curr.difference(next).inMinutes.abs() > 5;
          }
        }

        return MessageBubble(
          message:  msg, // Note: We need to make sure MessageBubble expects MessageModel
          isMine:   isMine,
          showTime: showTime,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty Chat
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
          color: AppColor.white,
          shape: BoxShape.circle,
          boxShadow: AppColor.cardShadow,
        ),
        child: const Icon(Icons.chat_bubble_outline_rounded,
            size: 34, color: AppColor.primaryColor),
      ),
      const SizedBox(height: 14),
      Text('start_conversation'.tr,
          style: AppTextStyle.heading3.copyWith(color: AppColor.grey)),
      const SizedBox(height: 6),
      Text('send_welcome_message'.tr,
          style: AppTextStyle.bodyMedium),
    ]),
  );
}
