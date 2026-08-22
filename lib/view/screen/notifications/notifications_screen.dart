import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/notification_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/services/fcm_service.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/view/widget/notifications/notification_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController());
    }
    return GetBuilder<NotificationController>(
      builder: (controller) => Scaffold(
        backgroundColor: Get.isDarkMode
            ? AppColor.darkSecondBackground
            : AppColor.secondBackground,
        appBar: AppBar(
          backgroundColor: AppColor.primaryColor,
          title: Text(
            'notifications_title'.tr,
            style: AppTextStyle.heading2.copyWith(color: Colors.white),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'notifications_settings'.tr,
              onPressed: () => Get.toNamed(
                Get.find<MyServices>().userRole == 'buyer'
                    ? '/buyer/notification-settings'
                    : '/seller/notification-settings',
              ),
              icon: const Icon(Icons.settings_outlined),
            ),
            if (controller.unreadCount > 0)
              TextButton(
                onPressed: controller.markAllRead,
                child: Text(
                  'notifications_mark_all'.tr,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
        body: _body(controller),
      ),
    );
  }

  Widget _body(NotificationController controller) {
    if (controller.statusRequest == StatusRequest.loading &&
        controller.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.notifications.isEmpty) {
      return Center(child: Text('notifications_empty'.tr));
    }
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) => NotificationCard(
          item: controller.notifications[index],
          onTap: () async {
            final item = controller.notifications[index];
            await controller.markRead(item);
            if (Get.isRegistered<FCMService>()) {
              Get.find<FCMService>().handleNotificationData(item.data);
            }
          },
        ),
      ),
    );
  }
}
