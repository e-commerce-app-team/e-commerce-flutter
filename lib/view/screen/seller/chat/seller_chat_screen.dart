import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_chat_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/chat_models.dart';
import 'package:e_commerce/view/screen/seller/chat/chat_room_screen.dart';
import 'package:e_commerce/view/screen/seller/chat/chat_settings_screen.dart';
import 'package:e_commerce/view/widget/seller/chat/conversation_tile.dart';
import 'package:e_commerce/view/widget/seller/dashboard/shimmer_box.dart';

class SellerChatScreen extends StatelessWidget {
  const SellerChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SellerChatController());
    return GetBuilder<SellerChatController>(
      builder: (ctrl) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        appBar: _ChatAppBar(ctrl: ctrl),
        body: ctrl.statusRequest == StatusRequest.loading
            ? const _ConversationsShimmer()
            : RefreshIndicator(
                onRefresh: ctrl.loadConversations,
                color: AppColor.primaryColor,
                backgroundColor: Colors.white,
                child: ctrl.filteredConversations.isEmpty
                    ? _EmptyConversations(hasSearch: ctrl.searchQuery.isNotEmpty)
                    : _ConversationsList(ctrl: ctrl),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBar  (قابل للطي — SliverAppBar style داخل PreferredSize)
// ─────────────────────────────────────────────────────────────────────────────
class _ChatAppBar extends StatefulWidget implements PreferredSizeWidget {
  final SellerChatController ctrl;
  const _ChatAppBar({required this.ctrl});

  @override
  Size get preferredSize => const Size.fromHeight(126);

  @override
  State<_ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<_ChatAppBar>
    with SingleTickerProviderStateMixin {
  bool _collapsed = false;
  late AnimationController _anim;
  late Animation<double>   _height;

  @override
  void initState() {
    super.initState();
    _anim   = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _height = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  void _toggle() {
    setState(() => _collapsed = !_collapsed);
    _collapsed ? _anim.forward() : _anim.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;
    return Container(
      decoration: const BoxDecoration(gradient: AppColor.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Row الرئيسي ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
              child: Row(
                children: [
                  // أيقونة + عنوان
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chat_bubble_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('chat_title'.tr,
                          style: AppTextStyle.appBarTitle.copyWith(fontSize: 17)),
                      if (ctrl.totalUnread > 0)
                        Text(
                          '${ctrl.totalUnread} ${'unread_messages'.tr}',
                          style: AppTextStyle.labelSmall.copyWith(
                              color: Colors.white70, fontSize: 10),
                        ),
                    ],
                  ),
                  const Spacer(),

                  // زر فلتر غير المقروءة
                  _AppBarIconBtn(
                    icon: ctrl.filterUnread
                        ? Icons.mark_chat_unread_rounded
                        : Icons.mark_chat_read_outlined,
                    badge: ctrl.filterUnread ? null : null,
                    onTap: ctrl.toggleFilterUnread,
                    active: ctrl.filterUnread,
                  ),

                  // زر إعدادات الدردشة
                  _AppBarIconBtn(
                    icon: Icons.tune_rounded,
                    onTap: () => Get.to(
                      () => ChatSettingsScreen(ctrl: ctrl),
                      transition: Transition.rightToLeft,
                    ),
                  ),

                  // زر طي/بسط
                  _AppBarIconBtn(
                    icon: _collapsed
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    onTap: _toggle,
                  ),
                ],
              ),
            ),

            // ── شريط البحث القابل للطي ────────────────────────────────────
            SizeTransition(
              sizeFactor: _height,
              axisAlignment: -1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
                child: _SearchBar(ctrl: ctrl),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int?  badge;
  final bool  active;
  const _AppBarIconBtn({
    required this.icon, required this.onTap,
    this.badge, this.active = false,
  });

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      IconButton(
        icon: Icon(icon,
            color: active ? const Color(0xffFFD700) : Colors.white, size: 22),
        onPressed: onTap,
        splashRadius: 20,
      ),
      if (badge != null && badge! > 0)
        Positioned(
          top: 6, right: 6,
          child: Container(
            width: 16, height: 16,
            decoration: const BoxDecoration(
                color: AppColor.error, shape: BoxShape.circle),
            child: Center(
              child: Text('$badge',
                  style: AppTextStyle.badge.copyWith(fontSize: 8)),
            ),
          ),
        ),
    ],
  );
}

class _SearchBar extends StatelessWidget {
  final SellerChatController ctrl;
  const _SearchBar({required this.ctrl});

  @override
  Widget build(BuildContext context) => Container(
    height: 42,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.95),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8, offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TextField(
      onChanged: ctrl.onSearch,
      textAlignVertical: TextAlignVertical.center,
      style: AppTextStyle.inputText.copyWith(fontSize: 13),
      decoration: InputDecoration(
        hintText: 'search_conversations'.tr,
        hintStyle: AppTextStyle.inputHint.copyWith(fontSize: 12),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColor.grey, size: 18),
        suffixIcon: ctrl.searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 16, color: AppColor.grey),
                onPressed: ctrl.clearSearch,
              )
            : null,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// قائمة المحادثات
// ─────────────────────────────────────────────────────────────────────────────
class _ConversationsList extends StatelessWidget {
  final SellerChatController ctrl;
  const _ConversationsList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final convs = ctrl.filteredConversations;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      itemCount: convs.length,
      itemBuilder: (_, i) => ConversationTile(
        conversation: convs[i],
        index: i,
        onTap: () {
          ctrl.markAsRead(convs[i].id);
          Get.to(
            () => ChatRoomScreen(conversation: convs[i]),
            transition: Transition.cupertino,
          );
        },
        onArchive:  () => ctrl.archiveConversation(convs[i].id),
        onBlock:    () => _confirmBlock(context, ctrl, convs[i]),
      ),
    );
  }

  void _confirmBlock(
      BuildContext context, SellerChatController ctrl, ConversationModel conv) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('block_user'.tr,
            style: AppTextStyle.heading3.copyWith(color: AppColor.error)),
        content: Text(
          '${'block_confirm_msg'.tr} ${conv.buyerName}؟',
          style: AppTextStyle.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr,
                style: AppTextStyle.labelLarge.copyWith(color: AppColor.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              ctrl.blockUser(conv.buyerId, conv.id);
              Get.snackbar(
                'block_user'.tr, '${conv.buyerName} ${'has_been_blocked'.tr}',
                backgroundColor: AppColor.errorLight,
                colorText: AppColor.errorDark,
                icon: const Icon(Icons.block_rounded, color: AppColor.error),
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
            child: Text('block'.tr,
                style: AppTextStyle.labelLarge.copyWith(color: AppColor.error)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyConversations extends StatelessWidget {
  final bool hasSearch;
  const _EmptyConversations({required this.hasSearch});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: AppColor.primarySurface,
          shape: BoxShape.circle,
        ),
        child: Icon(
          hasSearch ? Icons.search_off_rounded : Icons.chat_bubble_outline_rounded,
          size: 36, color: AppColor.primaryColor,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        hasSearch ? 'no_results'.tr : 'no_conversations'.tr,
        style: AppTextStyle.heading3.copyWith(color: AppColor.grey),
      ),
      const SizedBox(height: 6),
      Text(
        hasSearch ? 'try_different_keywords'.tr : 'buyer_messages_appear_here'.tr,
        style: AppTextStyle.bodyMedium,
        textAlign: TextAlign.center,
      ),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer
// ─────────────────────────────────────────────────────────────────────────────
class _ConversationsShimmer extends StatelessWidget {
  const _ConversationsShimmer();

  @override
  Widget build(BuildContext context) => ListView.builder(
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
    itemCount: 6,
    itemBuilder: (_, __) => Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColor.cardShadow,
      ),
      child: Row(children: [
        const ShimmerBox.circle(size: 48),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              ShimmerBox(width: 120, height: 12),
              SizedBox(height: 8),
              ShimmerBox(width: 200, height: 10),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            ShimmerBox(width: 38, height: 10),
            SizedBox(height: 8),
            ShimmerBox(width: 22, height: 22, radius: 11),
          ],
        ),
      ]),
    ),
  );
}
