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
    final tag  = 'chat_${conversation.id}';
    Get.put(ChatRoomController(conversation), tag: tag);

    return GetBuilder<ChatRoomController>(
      tag: tag,
      builder: (ctrl) => Scaffold(
        backgroundColor: const Color(0xffF0F2F5),
        appBar: _ChatRoomAppBar(conversation: conversation),
        body: Column(
          children: [
            Expanded(
              child: ctrl.messages.isEmpty
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
          ],
        ),
      ),
    );
  }
}

class _ChatRoomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ConversationModel conversation;
  const _ChatRoomAppBar({required this.conversation});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Get.back(),
      ),
      titleSpacing: 0,
      title: Row(children: [
        // Avatar
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
                color: Colors.white.withOpacity(0.4), width: 1.5),
          ),
          child: Center(
            child: Text(
              conversation.avatarInitials.toUpperCase(),
              style: AppTextStyle.labelLarge.copyWith(
                  color: Colors.white, fontSize: 13),
            ),
          ),
        ),
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
                    color: Color(0xff4ADE80),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'متصل الآن',
                  style: AppTextStyle.labelSmall.copyWith(
                      color: Colors.white70, fontSize: 10),
                ),
              ]),
            ],
          ),
        ),
      ]),
      actions: [
        if (conversation.orderId != null)
          Container(
            margin: const EdgeInsets.only(left: 8, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                conversation.orderId!,
                style: AppTextStyle.labelSmall.copyWith(
                    color: Colors.white,
                    fontFamily: 'PlayfairDisplay',
                    fontWeight: FontWeight.w700,
                    fontSize: 10),
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded,
              color: Colors.white, size: 22),
          onPressed: () => _showOptions(context),
        ),
      ],
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: AppColor.greyBorder,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          _OptionItem(
            icon: Icons.archive_outlined,
            label: 'أرشفة المحادثة',
            onTap: () => Get.back(),
          ),
          _OptionItem(
            icon: Icons.block_outlined,
            label: 'حظر المستخدم',
            color: AppColor.error,
            onTap: () => Get.back(),
          ),
        ]),
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color?   color;
  final VoidCallback onTap;
  const _OptionItem({
    required this.icon, required this.label,
    required this.onTap, this.color,
  });
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon,
        color: color ?? AppColor.grey, size: 22),
    title: Text(label,
        style: AppTextStyle.labelLarge.copyWith(
            color: color ?? AppColor.black, fontSize: 14)),
    onTap: onTap,
  );
}

class _MessagesList extends StatelessWidget {
  final ChatRoomController ctrl;
  const _MessagesList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final msgs   = ctrl.messages;
    final myId   = ctrl.myId;

    return ListView.builder(
      reverse: true,
      controller: ctrl.scrollCtrl,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: msgs.length,
      itemBuilder: (_, i) {
        final msg   = msgs[i];
        final isMine = msg['sender_id'] == myId;

        bool showTime = i == 0;
        if (!showTime && i < msgs.length - 1) {
          final curr = msg['created_at'] as DateTime?;
          final next = msgs[i + 1]['created_at'] as DateTime?;
          if (curr != null && next != null) {
            showTime = curr.difference(next).inMinutes.abs() > 5;
          }
        }

        return MessageBubble(
          message:  msg,
          isMine:   isMine,
          showTime: showTime,
        );
      },
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 70, height: 70,
        decoration: BoxDecoration(
          color: AppColor.primarySurface,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.chat_bubble_outline_rounded,
            size: 32, color: AppColor.primaryColor),
      ),
      const SizedBox(height: 14),
      Text('ابدأ المحادثة',
          style: AppTextStyle.heading3.copyWith(color: AppColor.grey)),
      const SizedBox(height: 6),
      Text('أرسل رسالة ترحيب للمشتري',
          style: AppTextStyle.bodyMedium),
    ]),
  );
}
