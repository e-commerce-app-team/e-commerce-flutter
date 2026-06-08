import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/chat_models.dart';

class ConversationTile extends StatefulWidget {
  final ConversationModel conversation;
  final int               index;
  final VoidCallback      onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.index,
    required this.onTap,
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
    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = widget.conversation;
    final hasUnread = c.unreadSeller > 0;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: hasUnread
                  ? AppColor.primarySurface
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColor.cardShadow,
              border: Border.all(
                color: hasUnread
                    ? AppColor.primaryColor.withOpacity(0.2)
                    : AppColor.greyBorder,
                width: hasUnread ? 1.2 : 0.8,
              ),
            ),
            child: Row(
              children: [
                _Avatar(
                  initials: c.avatarInitials,
                  hasUnread: hasUnread,
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            c.buyerName,
                            style: AppTextStyle.labelLarge.copyWith(
                              fontSize: 13,
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
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
                      const SizedBox(height: 3),

                      if (c.orderId != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
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
                        const SizedBox(height: 4),
                      ],

                      Row(
                        children: [
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
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              child: Text(
                                c.unreadSeller > 99
                                    ? '99+'
                                    : '${c.unreadSeller}',
                                style: AppTextStyle.badge.copyWith(
                                    fontSize: 9),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
    final color = _colors[initials.codeUnitAt(0) % _colors.length];
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: hasUnread
                  ? AppColor.primaryColor.withOpacity(0.4)
                  : color.withOpacity(0.25),
              width: hasUnread ? 2 : 1.5,
            ),
          ),
          child: Center(
            child: Text(
              initials.toUpperCase(),
              style: AppTextStyle.labelLarge.copyWith(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 1, right: 1,
          child: Container(
            width: 11, height: 11,
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
