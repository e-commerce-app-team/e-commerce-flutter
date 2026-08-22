import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/notification_controller.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/view/widget/notifications/notification_widgets.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController());
    }
    final controller = Get.find<NotificationController>();
    if (controller.preferences.isEmpty) {
      controller.loadPreferences();
    }
    return GetBuilder<NotificationController>(
      builder: (_) => Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.primaryColor,
          title: Text('notifications_settings'.tr),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Text(
              'notifications_title'.tr,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            NotificationListSection(controller: controller),
            const SizedBox(height: 24),
            Text(
              'notifications_settings'.tr,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            NotificationPreferencesPanel(
              preferences: controller.preferences,
              onChanged: controller.update,
              onSave: controller.savePreferences,
            ),
          ],
        ),
      ),
    );
  }
}
