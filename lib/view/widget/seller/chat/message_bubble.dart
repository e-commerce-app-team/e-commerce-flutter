import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/chat_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MessageBubble
// ─────────────────────────────────────────────────────────────────────────────
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMine;
  final bool showTime;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.showTime,
  });

  @override
  Widget build(BuildContext context) {
    final type      = message.type;
    final content   = message.content;
    final localPath = message.imageUrl; // Treat imageUrl as localPath for now to avoid extensive changes
    final readAt    = message.readAt;
    final createdAt = message.createdAt;

    return Padding(
      padding: EdgeInsets.only(
        left:   isMine ? 56 : 0,
        right:  isMine ? 0 : 56,
        bottom: 5,
      ),
      child: GestureDetector(
        onLongPress: () => _showMessageOptions(context, content),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // ── Bubble ──────────────────────────────────────────────────────
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.74,
              ),
              decoration: BoxDecoration(
                color: isMine ? AppColor.primaryColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(18),
                  topRight:    const Radius.circular(18),
                  bottomLeft:  Radius.circular(isMine ? 18 : 4),
                  bottomRight: Radius.circular(isMine ? 4  : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isMine
                        ? AppColor.primaryColor.withOpacity(0.18)
                        : Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: type == 'image'
                  ? _ImageBubble(localPath: localPath, isMine: isMine)
                  : _TextBubble(content: content, isMine: isMine),
            ),

            // ── Timestamp + Read ─────────────────────────────────────────
            if (showTime && createdAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(createdAt),
                      style: AppTextStyle.timestamp.copyWith(fontSize: 10),
                    ),
                    if (isMine) ...[
                      const SizedBox(width: 4),
                      Icon(
                        readAt != null
                            ? Icons.done_all_rounded
                            : Icons.done_rounded,
                        size: 13,
                        color: readAt != null
                            ? AppColor.info
                            : AppColor.greyLight,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _showMessageOptions(BuildContext context, String content) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MessageOptionsSheet(content: content, isMine: isMine),
    );
  }
}

// ── Text Bubble ───────────────────────────────────────────────────────────────
class _TextBubble extends StatelessWidget {
  final String content;
  final bool   isMine;
  const _TextBubble({required this.content, required this.isMine});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Text(
      content,
      style: AppTextStyle.bodyMedium.copyWith(
        color: isMine ? Colors.white : AppColor.black,
        fontSize: 14,
        height: 1.5,
      ),
    ),
  );
}

// ── Image Bubble ──────────────────────────────────────────────────────────────
class _ImageBubble extends StatelessWidget {
  final String? localPath;
  final bool    isMine;
  const _ImageBubble({this.localPath, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft:     const Radius.circular(18),
        topRight:    const Radius.circular(18),
        bottomLeft:  Radius.circular(isMine ? 18 : 4),
        bottomRight: Radius.circular(isMine ? 4  : 18),
      ),
      child: localPath != null
          ? Image.file(
              File(localPath!),
              width: 220, height: 190,
              fit: BoxFit.cover,
            )
          : Container(
              width: 220, height: 190,
              color: AppColor.greyBorder,
              child: const Icon(Icons.broken_image_outlined,
                  color: AppColor.grey, size: 34),
            ),
    );
  }
}

// ── Message Options Sheet ─────────────────────────────────────────────────────
class _MessageOptionsSheet extends StatelessWidget {
  final String content;
  final bool   isMine;
  const _MessageOptionsSheet({required this.content, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
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

        _MsgOptionTile(
          icon: Icons.copy_rounded,
          label: 'copy_message'.tr,
          onTap: () {
            Clipboard.setData(ClipboardData(text: content));
            Get.back();
            Get.snackbar(
              'copied'.tr, 'message_copied'.tr,
              backgroundColor: AppColor.successLight,
              colorText: AppColor.successDark,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
              borderRadius: 12,
              duration: const Duration(seconds: 2),
            );
          },
        ),

        _MsgOptionTile(
          icon: Icons.reply_rounded,
          label: 'reply'.tr,
          onTap: () => Get.back(),
        ),

        if (!isMine)
          _MsgOptionTile(
            icon: Icons.flag_outlined,
            label: 'report_message'.tr,
            color: AppColor.warning,
            isLast: true,
            onTap: () {
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
          )
        else
          _MsgOptionTile(
            icon: Icons.delete_outline_rounded,
            label: 'delete_message'.tr,
            color: AppColor.error,
            isLast: true,
            onTap: () => Get.back(),
          ),
      ]),
    );
  }
}

class _MsgOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  final bool isLast;

  const _MsgOptionTile({
    required this.icon, required this.label,
    required this.onTap, this.color, this.isLast = false,
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
        child: Icon(icon, color: color ?? AppColor.grey, size: 18),
      ),
      title: Text(label,
          style: AppTextStyle.labelLarge.copyWith(
              color: color ?? AppColor.black, fontSize: 14)),
      onTap: onTap,
    ),
    if (!isLast) const Divider(color: AppColor.greyBorder, height: 1),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// Date Separator
// ─────────────────────────────────────────────────────────────────────────────
class DateSeparator extends StatelessWidget {
  final String label;
  const DateSeparator({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(children: [
      const Expanded(child: Divider(color: AppColor.greyBorder)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.greyBorder),
            boxShadow: AppColor.cardShadow,
          ),
          child: Text(label,
              style: AppTextStyle.labelSmall.copyWith(fontSize: 10)),
        ),
      ),
      const Expanded(child: Divider(color: AppColor.greyBorder)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Replies Sheet
// ─────────────────────────────────────────────────────────────────────────────
class QuickRepliesSheet extends StatelessWidget {
  final List<QuickReplyModel> replies;
  final void Function(QuickReplyModel) onSelect;

  const QuickRepliesSheet({
    super.key,
    required this.replies,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.42,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: AppColor.bottomNavShadow,
        border: Border(
          top: BorderSide(color: AppColor.primaryColor.withOpacity(0.15)),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: AppColor.primarySurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt_rounded,
                  size: 15, color: AppColor.primaryColor),
            ),
            const SizedBox(width: 8),
            Text('quick_replies'.tr,
                style: AppTextStyle.heading3.copyWith(fontSize: 14)),
            const Spacer(),
            Text('type_slash_hint'.tr,
                style: AppTextStyle.labelSmall.copyWith(fontSize: 10)),
          ]),
        ),
        const Divider(height: 1, color: AppColor.greyBorder),

        Flexible(
          child: replies.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('no_quick_replies'.tr,
                        style: AppTextStyle.bodyMedium),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: replies.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 7),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => onSelect(replies[i]),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColor.secondBackground,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: AppColor.greyBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            replies[i].title,
                            style: AppTextStyle.labelLarge.copyWith(
                              color: AppColor.primaryColor, fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            replies[i].content,
                            style: AppTextStyle.bodySmall.copyWith(
                                fontSize: 11.5),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat Input Bar
// ─────────────────────────────────────────────────────────────────────────────
class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isTyping;
  final VoidCallback onSend;
  final VoidCallback onImage;
  final VoidCallback onQuickReply;
  final void Function(String) onChanged;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.isTyping,
    required this.onSend,
    required this.onImage,
    required this.onQuickReply,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppColor.bottomNavShadow,
        border: Border(
            top: BorderSide(color: AppColor.greyBorder, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // زر الردود السريعة
          _CircleBtn(
            icon: Icons.bolt_rounded,
            color: AppColor.primaryColor,
            bg:    AppColor.primarySurface,
            onTap: onQuickReply,
          ),
          const SizedBox(width: 7),

          // زر الصورة
          _CircleBtn(
            icon: Icons.image_outlined,
            color: AppColor.grey,
            bg:    AppColor.secondBackground,
            onTap: onImage,
          ),
          const SizedBox(width: 7),

          // حقل الإدخال
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 130),
              decoration: BoxDecoration(
                color: AppColor.secondBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isTyping
                      ? AppColor.primaryColor.withOpacity(0.45)
                      : AppColor.greyBorder,
                  width: isTyping ? 1.3 : 1,
                ),
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                maxLines: null,
                textAlignVertical: TextAlignVertical.center,
                style: AppTextStyle.inputText.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'type_message_hint'.tr,
                  hintStyle: AppTextStyle.inputHint.copyWith(fontSize: 12.5),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 7),

          // زر الإرسال
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: isTyping ? AppColor.mainGradient : null,
              color:    isTyping ? null : AppColor.greyBorder,
              shape:    BoxShape.circle,
              boxShadow: isTyping ? AppColor.primaryShadow : null,
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: isTyping ? onSend : null,
                child: Center(
                  child: Icon(
                    Icons.send_rounded,
                    size: 19,
                    color: isTyping ? Colors.white : AppColor.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final VoidCallback onTap;
  const _CircleBtn({
    required this.icon, required this.color,
    required this.bg,   required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: 19, color: color),
    ),
  );
}
