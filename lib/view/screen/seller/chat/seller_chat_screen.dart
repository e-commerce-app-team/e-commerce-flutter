import 'package:e_commerce/view/screen/seller/chat/chat_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_chat_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/chat_models.dart';
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
                    ? _EmptyConversations(
                        hasSearch: ctrl.searchQuery.isNotEmpty)
                    : _ConversationsList(ctrl: ctrl),
              ),
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SellerChatController ctrl;
  const _ChatAppBar({required this.ctrl});

  @override
  Size get preferredSize => const Size.fromHeight(110);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColor.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(children: [
              Text('الرسائل', style: AppTextStyle.appBarTitle),
              const Spacer(),
              if (ctrl.totalUnread > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4)),
                  ),
                  child: Text(
                    '${ctrl.totalUnread} غير مقروء',
                    style: AppTextStyle.chip.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11),
                  ),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _SearchBar(ctrl: ctrl),
          ),
        ]),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final SellerChatController ctrl;
  const _SearchBar({required this.ctrl});

  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.95),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextField(
      onChanged: ctrl.onSearch,
      textAlignVertical: TextAlignVertical.center,
      style: AppTextStyle.inputText.copyWith(fontSize: 13),
      decoration: InputDecoration(
        hintText: 'ابحث في المحادثات...',
        hintStyle: AppTextStyle.inputHint.copyWith(fontSize: 12),
        prefixIcon: const Icon(Icons.search_rounded,
            color: AppColor.grey, size: 18),
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    ),
  );
}

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
      ),
    );
  }
}

class _EmptyConversations extends StatelessWidget {
  final bool hasSearch;
  const _EmptyConversations({required this.hasSearch});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(
        hasSearch ? Icons.search_off_rounded : Icons.chat_bubble_outline,
        size: 60, color: AppColor.greyLight,
      ),
      const SizedBox(height: 14),
      Text(
        hasSearch ? 'لا توجد نتائج' : 'لا توجد محادثات بعد',
        style: AppTextStyle.heading3.copyWith(color: AppColor.grey),
      ),
      const SizedBox(height: 6),
      Text(
        hasSearch
            ? 'جرّب البحث بكلمات مختلفة'
            : 'ستظهر رسائل المشترين هنا',
        style: AppTextStyle.bodyMedium,
        textAlign: TextAlign.center,
      ),
    ]),
  );
}

class _ConversationsShimmer extends StatelessWidget {
  const _ConversationsShimmer();
  @override
  Widget build(BuildContext context) => ListView.builder(
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
    itemCount: 6,
    itemBuilder: (_, __) => Container(
      height: 76,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColor.cardShadow,
      ),
      child: Row(children: [
        const ShimmerBox.circle(size: 46),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              ShimmerBox(width: 110, height: 12),
              SizedBox(height: 8),
              ShimmerBox(width: 180, height: 10),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            ShimmerBox(width: 35, height: 10),
            SizedBox(height: 8),
            ShimmerBox(width: 20, height: 20, radius: 10),
          ],
        ),
      ]),
    ),
  );
}
