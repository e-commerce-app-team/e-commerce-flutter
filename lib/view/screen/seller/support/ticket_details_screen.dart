import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/ticket_details_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/support_models.dart';
import 'package:e_commerce/view/widget/seller/dashboard/shimmer_box.dart';

class TicketDetailsScreen extends StatelessWidget {
  const TicketDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ticket = Get.arguments as TicketModel;

    return GetBuilder<TicketDetailsControllerImp>(
      init: TicketDetailsControllerImp(ticket),
      builder: (ctrl) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        appBar: _TicketDetailsAppBar(ticket: ticket),
        body: Column(children: [
          Expanded(
            child: ctrl.statusRequest == StatusRequest.loading
                ? const _MessagesShimmer()
                : _MessagesList(ctrl: ctrl),
          ),
          if (!ticket.isClosed) _ReplyBar(ctrl: ctrl),
          if (ticket.isClosed)  _ClosedBanner(),
        ]),
      ),
    );
  }
}

class _TicketDetailsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final TicketModel ticket;
  const _TicketDetailsAppBar({required this.ticket});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);

  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: AppColor.primaryColor,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
      onPressed: () => Get.back(),
    ),
    title: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(ticket.ticketNumber,
            style: AppTextStyle.appBarTitle.copyWith(fontSize: 14)),
        const SizedBox(height: 2),
        Text(ticket.title,
            style: AppTextStyle.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.75), fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ],
    ),
    centerTitle: true,
    actions: [
      Padding(
        padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: ticket.statusLightColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: ticket.statusColor.withOpacity(0.4), width: 1),
          ),
          child: Text(
            ticket.statusLabel,
            style: AppTextStyle.badge.copyWith(
                color: ticket.statusColor,
                fontWeight: FontWeight.w700,
                fontSize: 10),
          ),
        ),
      ),
    ],
  );
}

class _MessagesList extends StatelessWidget {
  final TicketDetailsControllerImp ctrl;
  const _MessagesList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: ctrl.scrollCtrl,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      itemCount: ctrl.messages.length,
      itemBuilder: (_, i) {
        final msg     = ctrl.messages[i];
        final prevMsg = i > 0 ? ctrl.messages[i - 1] : null;
        final showDate = prevMsg == null ||
            !_isSameDay(prevMsg.createdAt, msg.createdAt);
        return Column(children: [
          if (showDate) _DateDivider(date: msg.createdAt),
          _ChatBubble(msg: msg, index: i),
        ]);
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider({required this.date});

  String _formatDate() {
    final now  = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'أمس';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(children: [
      Expanded(child: Divider(color: AppColor.greyBorder.withOpacity(0.6))),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          _formatDate(),
          style: AppTextStyle.timestamp.copyWith(fontSize: 10.5),
        ),
      ),
      Expanded(child: Divider(color: AppColor.greyBorder.withOpacity(0.6))),
    ]),
  );
}

class _ChatBubble extends StatefulWidget {
  final TicketMessageModel msg;
  final int index;
  const _ChatBubble({required this.msg, required this.index});

  @override
  State<_ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<_ChatBubble>
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

    final fromSeller = widget.msg.isFromSeller;
    _slide = Tween<Offset>(
      begin: Offset(fromSeller ? 0.15 : -0.15, 0),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 30 * widget.index.clamp(0, 8)), () {
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
    final msg        = widget.msg;
    final isSeller   = msg.isFromSeller;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Align(
          alignment:
              isSeller ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: isSeller
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isSeller)
                    Padding(
                      padding: const EdgeInsets.only(right: 10, bottom: 4),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          width: 20, height: 20,
                          decoration: const BoxDecoration(
                            gradient: AppColor.headerGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.support_agent_rounded,
                              size: 12, color: Colors.white),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          msg.senderName,
                          style: AppTextStyle.labelSmall.copyWith(
                              fontSize: 10,
                              color: AppColor.primaryColor,
                              fontWeight: FontWeight.w700),
                        ),
                      ]),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSeller
                          ? AppColor.primaryColor
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft:     const Radius.circular(16),
                        topRight:    const Radius.circular(16),
                        bottomLeft:  Radius.circular(isSeller ? 16 : 4),
                        bottomRight: Radius.circular(isSeller ? 4 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isSeller
                                  ? AppColor.primaryColor
                                  : AppColor.black)
                              .withOpacity(isSeller ? 0.2 : 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                      border: isSeller
                          ? null
                          : Border.all(
                              color: AppColor.greyBorder, width: 0.8),
                    ),
                    child: Text(
                      msg.message,
                      style: AppTextStyle.bodySmall.copyWith(
                        color:    isSeller ? Colors.white : AppColor.black,
                        fontSize: 13,
                        height:   1.55,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(msg.formattedTime,
                          style: AppTextStyle.timestamp
                              .copyWith(fontSize: 9.5)),
                      if (isSeller) ...[
                        const SizedBox(width: 4),
                        Icon(
                          msg.isRead
                              ? Icons.done_all_rounded
                              : Icons.done_rounded,
                          size: 13,
                          color: msg.isRead
                              ? AppColor.primaryColor
                              : AppColor.greyLight,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReplyBar extends StatelessWidget {
  final TicketDetailsControllerImp ctrl;
  const _ReplyBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppColor.bottomNavShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ctrl.attachedImage != null)
            _AttachedImagePreview(ctrl: ctrl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: ctrl.pickImage,
                child: Container(
                  width: 40, height: 40,
                  margin: const EdgeInsets.only(left: 8, bottom: 2),
                  decoration: BoxDecoration(
                    color: AppColor.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColor.primaryColor.withOpacity(0.25)),
                  ),
                  child: const Icon(Icons.image_outlined,
                      color: AppColor.primaryColor, size: 20),
                ),
              ),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: AppColor.secondBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColor.greyBorder),
                  ),
                  child: TextField(
                    controller: ctrl.replyCtrl,
                    onChanged: ctrl.onReplyChanged,
                    maxLines: null,
                    style: AppTextStyle.inputText.copyWith(fontSize: 13),
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'reply_hint'.tr,
                      hintStyle: AppTextStyle.inputHint.copyWith(fontSize: 12),
                      border:        InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: (ctrl.isTyping || ctrl.attachedImage != null) &&
                        ctrl.replyStatusRequest != StatusRequest.loading
                    ? ctrl.sendReply
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    gradient: (ctrl.isTyping || ctrl.attachedImage != null)
                        ? const LinearGradient(
                            colors: [Color(0xff8d0ea8), Color(0xff6d18d5)],
                            begin: Alignment.topLeft,
                            end:   Alignment.bottomRight,
                          )
                        : null,
                    color: (ctrl.isTyping || ctrl.attachedImage != null)
                        ? null
                        : AppColor.greyBorder,
                    shape: BoxShape.circle,
                    boxShadow: (ctrl.isTyping || ctrl.attachedImage != null)
                        ? AppColor.primaryShadow
                        : null,
                  ),
                  child: ctrl.replyStatusRequest == StatusRequest.loading
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttachedImagePreview extends StatelessWidget {
  final TicketDetailsControllerImp ctrl;
  const _AttachedImagePreview({required this.ctrl});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Stack(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
                image: FileImage(ctrl.attachedImage!), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: -4, right: -4,
          child: GestureDetector(
            onTap: ctrl.removeImage,
            child: Container(
              width: 18, height: 18,
              decoration: const BoxDecoration(
                  color: AppColor.error, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ]),
      const SizedBox(width: 10),
      Expanded(
        child: Text('ticket_image_attached'.tr,
            style: AppTextStyle.labelSmall.copyWith(
                fontSize: 11, color: AppColor.grey)),
      ),
    ]),
  );
}

class _ClosedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(
        16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
    decoration: BoxDecoration(
      color: AppColor.successLight,
      border: Border(top: BorderSide(
          color: AppColor.success.withOpacity(0.25), width: 1)),
    ),
    child: Row(children: [
      const Icon(Icons.check_circle_outline_rounded,
          color: AppColor.success, size: 18),
      const SizedBox(width: 10),
      Expanded(
        child: Text('ticket_closed_note'.tr,
            style: AppTextStyle.labelMedium.copyWith(
                color: AppColor.successDark, fontSize: 12)),
      ),
    ]),
  );
}

class _MessagesShimmer extends StatelessWidget {
  const _MessagesShimmer();

  @override
  Widget build(BuildContext context) => ListView(
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.all(16),
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: const ShimmerBox(width: 220, height: 60, radius: 16),
      ),
      const SizedBox(height: 10),
      Align(
        alignment: Alignment.centerRight,
        child: const ShimmerBox(width: 180, height: 50, radius: 16),
      ),
      const SizedBox(height: 10),
      Align(
        alignment: Alignment.centerLeft,
        child: const ShimmerBox(width: 250, height: 80, radius: 16),
      ),
      const SizedBox(height: 10),
      Align(
        alignment: Alignment.centerRight,
        child: const ShimmerBox(width: 200, height: 55, radius: 16),
      ),
    ],
  );
}
