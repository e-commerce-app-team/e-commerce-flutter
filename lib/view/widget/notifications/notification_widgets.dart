import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:e_commerce/controller/notification_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/notification_model.dart';

class NotificationPreferencesPanel extends StatelessWidget {
  final Map<String, bool> preferences;
  final VoidCallback onChanged;
  final Future<void> Function() onSave;

  const NotificationPreferencesPanel({
    super.key,
    required this.preferences,
    required this.onChanged,
    required this.onSave,
  });

  static const _types = ['orders', 'chat', 'marketing'];
  static const _labels = {
    'orders': 'notifications_orders',
    'chat': 'notifications_chat',
    'marketing': 'notifications_marketing',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColor.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          ..._types.map(
            (type) => SwitchListTile.adaptive(
              value: preferences[type] ?? true,
              onChanged: (value) {
                preferences[type] = value;
                onChanged();
                onSave();
              },
              title: Text(_labels[type]!.tr),
              secondary: Icon(
                type == 'orders'
                    ? Icons.receipt_long_outlined
                    : type == 'chat'
                    ? Icons.chat_bubble_outline_rounded
                    : Icons.campaign_outlined,
                color: AppColor.primaryColor,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextButton.icon(
                onPressed: () {
                  for (final type in _types) {
                    preferences[type] = true;
                  }
                  onChanged();
                  onSave();
                },
                icon: const Icon(Icons.done_all_rounded, size: 18),
                label: Text('enable_all_notifications'.tr),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationListSection extends StatelessWidget {
  final NotificationController controller;
  final bool shrinkWrap;

  const NotificationListSection({
    super.key,
    required this.controller,
    this.shrinkWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.notifications.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Center(child: Text('notifications_empty'.tr)),
      );
    }
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      itemCount: controller.notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final item = controller.notifications[index];
        return NotificationCard(
          item: item,
          onTap: () => controller.markRead(item),
        );
      },
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel item;
  final VoidCallback onTap;

  const NotificationCard({super.key, required this.item, required this.onTap});

  String _text(String? key, String? raw, Map<String, dynamic> params) {
    if (item.type == 'announcement' && raw != null && raw.isNotEmpty) {
      return raw;
    }
    final localized = (key ?? '').isNotEmpty
        ? key!.trParams(params.map((k, v) => MapEntry(k, '$v')))
        : '';
    if (localized.isNotEmpty && localized != key) return localized;
    final arabic = (Get.locale?.languageCode ?? 'ar') == 'ar';
    return raw ?? (arabic ? item.titleAr : item.titleEn) ?? key ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final arabic = (Get.locale?.languageCode ?? 'ar') == 'ar';
    final title = _text(
      item.titleKey,
      arabic ? item.titleAr : item.titleEn,
      item.params,
    );
    final message = _text(
      item.messageKey,
      arabic ? item.messageAr : item.messageEn,
      item.params,
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: item.isRead
                ? AppColor.cardBackground
                : AppColor.primarySurface.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: item.isRead
                  ? AppColor.greyBorder.withValues(alpha: 0.7)
                  : AppColor.primaryColor.withValues(alpha: 0.35),
            ),
            boxShadow: AppColor.cardShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColor.primarySurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_icon(item.type), color: AppColor.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColor.greyText, height: 1.35),
                    ),
                    if (item.createdAt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        DateFormat(
                          'dd/MM/yyyy • HH:mm',
                        ).format(item.createdAt!),
                        style: AppTextStyle.timestamp,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(String type) {
    if (type.contains('chat')) return Icons.chat_bubble_outline_rounded;
    if (type == 'announcement') return Icons.campaign_outlined;
    if (type.contains('payment') || type == 'refund') {
      return Icons.account_balance_wallet_outlined;
    }
    return Icons.receipt_long_outlined;
  }
}
