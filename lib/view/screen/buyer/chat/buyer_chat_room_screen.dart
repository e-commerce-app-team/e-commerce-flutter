import 'package:e_commerce/controller/buyer/buyer_chat_room_controller.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/chat_models.dart';
import 'package:e_commerce/view/widget/buyer/shared/buyer_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuyerChatRoomScreen extends StatelessWidget {
  const BuyerChatRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Map<String, dynamic>.from(Get.arguments ?? {});
    final sellerId = int.tryParse('${args['seller_id'] ?? 0}') ?? 0;
    final tag = 'buyer_chat_$sellerId';

    Get.put(
      BuyerChatRoomController(
        sellerId: sellerId,
        storeName: '${args['store_name'] ?? ''}',
        storeLogo: '${args['store_logo'] ?? ''}',
        initialBuyerId: int.tryParse('${args['buyer_id'] ?? 0}') ?? 0,
        initialBuyerName: '${args['buyer_name'] ?? ''}',
      ),
      tag: tag,
    );

    return GetBuilder<BuyerChatRoomController>(
      tag: tag,
      builder: (controller) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        appBar: AppBar(
          backgroundColor: AppColor.primaryColor,
          elevation: 0,
          leading: IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColor.white),
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: BuyerNetworkImage(
                    url: controller.storeLogo,
                    fallbackIcon: Icons.storefront_rounded,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  controller.storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColor.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: controller.messages.isEmpty
                  ? const _EmptyConversation()
                  : ListView.builder(
                      controller: controller.scrollController,
                      reverse: true,
                      padding: const EdgeInsets.fromLTRB(14, 18, 14, 10),
                      itemCount: controller.messages.length,
                      itemBuilder: (_, index) {
                        final message = controller.messages[index];
                        return _BuyerMessageBubble(
                          message: message,
                          isMine: message.senderId == controller.buyerId,
                        );
                      },
                    ),
            ),
            _BuyerMessageInput(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _BuyerMessageBubble extends StatelessWidget {
  const _BuyerMessageBubble({required this.message, required this.isMine});

  final MessageModel message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
        decoration: BoxDecoration(
          color: isMine ? AppColor.primaryColor : AppColor.white,
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(16),
            topEnd: const Radius.circular(16),
            bottomStart: Radius.circular(isMine ? 16 : 4),
            bottomEnd: Radius.circular(isMine ? 4 : 16),
          ),
          boxShadow: AppColor.cardShadow,
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isMine ? AppColor.white : AppColor.black,
            fontSize: 14,
            height: 1.45,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _BuyerMessageInput extends StatelessWidget {
  const _BuyerMessageInput({required this.controller});

  final BuyerChatRoomController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: const BoxDecoration(
          color: AppColor.white,
          border: Border(top: BorderSide(color: AppColor.greyBorder)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.messageController,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  filled: true,
                  fillColor: AppColor.secondBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: controller.sendMessage,
              customBorder: const CircleBorder(),
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  gradient: AppColor.mainGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: AppColor.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColor.greyLight),
            SizedBox(height: 12),
            Text(
              'ابدأ المحادثة مع التاجر',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 6),
            Text(
              'اسأل عن المقاسات، التوفر، أو تفاصيل المنتج.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColor.greyText),
            ),
          ],
        ),
      ),
    );
  }
}
