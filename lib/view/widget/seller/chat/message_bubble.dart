import 'dart:io';
import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/chat_models.dart';


class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
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
    final type      = message['type'] as String? ?? 'text';
    final content   = message['content'] as String? ?? '';
    final localPath = message['local_path'] as String?;
    final readAt    = message['read_at'];
    final createdAt = message['created_at'] as DateTime?;

    return Padding(
      padding: EdgeInsets.only(
        left:   isMine ? 60 : 0,
        right:  isMine ? 0  : 60,
        bottom: 6,
      ),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            decoration: BoxDecoration(
              color: isMine
                  ? AppColor.primaryColor
                  : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft:     const Radius.circular(16),
                topRight:    const Radius.circular(16),
                bottomLeft:  Radius.circular(isMine ? 16 : 4),
                bottomRight: Radius.circular(isMine ? 4  : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: type == 'image'
                ? _ImageBubble(
                    localPath: localPath, isMine: isMine)
                : _TextBubble(content: content, isMine: isMine),
          ),

          if (showTime && createdAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 3),
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
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _TextBubble extends StatelessWidget {
  final String content;
  final bool   isMine;
  const _TextBubble({required this.content, required this.isMine});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
    child: Text(
      content,
      style: AppTextStyle.bodyMedium.copyWith(
        color: isMine ? Colors.white : AppColor.black,
        fontSize: 13.5,
        height: 1.5,
      ),
    ),
  );
}

class _ImageBubble extends StatelessWidget {
  final String? localPath;
  final bool    isMine;
  const _ImageBubble({this.localPath, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft:     const Radius.circular(16),
        topRight:    const Radius.circular(16),
        bottomLeft:  Radius.circular(isMine ? 16 : 4),
        bottomRight: Radius.circular(isMine ? 4  : 16),
      ),
      child: localPath != null
          ? Image.file(
              File(localPath!),
              width: 200, height: 180,
              fit: BoxFit.cover,
            )
          : Container(
              width: 200, height: 180,
              color: AppColor.greyBorder,
              child: const Icon(Icons.broken_image_outlined,
                  color: AppColor.grey, size: 32),
            ),
    );
  }
}


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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColor.secondBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColor.greyBorder),
          ),
          child: Text(label,
              style: AppTextStyle.labelSmall.copyWith(fontSize: 10)),
        ),
      ),
      const Expanded(child: Divider(color: AppColor.greyBorder)),
    ]),
  );
}


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
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: AppColor.bottomNavShadow,
        border: Border(
          top: BorderSide(
              color: AppColor.primaryColor.withOpacity(0.15)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(children: [
              const Icon(Icons.bolt_rounded,
                  size: 18, color: AppColor.primaryColor),
              const SizedBox(width: 6),
              Text('ردود سريعة',
                  style: AppTextStyle.heading3
                      .copyWith(fontSize: 14)),
              const Spacer(),
              Text('اكتب / للاستدعاء',
                  style: AppTextStyle.labelSmall),
            ]),
          ),
          const Divider(height: 1, color: AppColor.greyBorder),

          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: replies.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => onSelect(replies[i]),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColor.secondBackground,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColor.greyBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        replies[i].title,
                        style: AppTextStyle.labelLarge.copyWith(
                          color: AppColor.primaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 3),
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
        ],
      ),
    );
  }
}


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
          _CircleBtn(
            icon: Icons.bolt_rounded,
            color: AppColor.primaryColor,
            bg:    AppColor.primarySurface,
            onTap: onQuickReply,
          ),
          const SizedBox(width: 8),

          _CircleBtn(
            icon: Icons.image_outlined,
            color: AppColor.grey,
            bg:    AppColor.secondBackground,
            onTap: onImage,
          ),
          const SizedBox(width: 8),

          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppColor.secondBackground,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isTyping
                      ? AppColor.primaryColor.withOpacity(0.4)
                      : AppColor.greyBorder,
                  width: isTyping ? 1.2 : 1,
                ),
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                maxLines: null,
                textAlignVertical: TextAlignVertical.center,
                style: AppTextStyle.inputText.copyWith(fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'اكتب رسالة... أو / للردود السريعة',
                  hintStyle: AppTextStyle.inputHint.copyWith(fontSize: 12),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: isTyping
                  ? AppColor.primaryColor
                  : AppColor.greyBorder,
              shape: BoxShape.circle,
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
                    size: 18,
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
      width: 38, height: 38,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: 18, color: color),
    ),
  );
}
