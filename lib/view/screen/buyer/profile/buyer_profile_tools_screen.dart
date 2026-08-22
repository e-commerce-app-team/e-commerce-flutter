import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:e_commerce/controller/buyer/buyer_profile_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/controller/notification_controller.dart';
import 'package:e_commerce/view/widget/notifications/notification_widgets.dart';

class BuyerProfileToolsScreen extends StatelessWidget {
  final String mode;
  const BuyerProfileToolsScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<BuyerProfileController>())
      Get.put(BuyerProfileController());
    final controller = Get.find<BuyerProfileController>();
    return GetBuilder<BuyerProfileController>(
      initState: (_) {
        if (mode == 'addresses') controller.loadAddresses();
        if (mode == 'wallet') controller.loadWallet();
        if (mode == 'notifications') controller.loadNotificationSettings();
        if (mode == 'conversations') controller.loadConversations();
      },
      builder: (_) => Scaffold(
        backgroundColor: Get.isDarkMode
            ? AppColor.darkSecondBackground
            : AppColor.secondBackground,
        appBar: AppBar(
          backgroundColor: AppColor.primaryColor,
          title: Text(
            _titleKey.tr,
            style: AppTextStyle.heading2.copyWith(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: _body(controller),
      ),
    );
  }

  String get _titleKey => switch (mode) {
    'addresses' => 'buyer_profile_addresses',
    'wallet' => 'buyer_profile_wallet',
    'notifications' => 'buyer_profile_notifications',
    'conversations' => 'buyer_profile_messages',
    _ => 'buyer_profile_edit_profile',
  };

  Widget _body(BuyerProfileController controller) {
    if (mode == 'edit') return _EditProfile(controller: controller);
    if (mode == 'addresses') return _Addresses(controller: controller);
    if (mode == 'wallet') return _Wallet(controller: controller);
    if (mode == 'notifications') return _Notifications(controller: controller);
    return _Conversations(controller: controller);
  }
}

class _EditProfile extends StatefulWidget {
  final BuyerProfileController controller;
  const _EditProfile({required this.controller});
  @override
  State<_EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<_EditProfile> {
  late final TextEditingController first, last, email, phone;
  @override
  void initState() {
    super.initState();
    final p = widget.controller.profile;
    first = TextEditingController(text: p?.firstName ?? '');
    last = TextEditingController(text: p?.lastName ?? '');
    email = TextEditingController(text: p?.email ?? '');
    phone = TextEditingController(text: p?.phone ?? '');
  }

  @override
  void dispose() {
    first.dispose();
    last.dispose();
    email.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Center(
        child: InkWell(
          onTap: widget.controller.pickPhoto,
          child: CircleAvatar(
            radius: 46,
            backgroundColor: AppColor.primarySurface,
            backgroundImage: widget.controller.selectedPhoto == null
                ? null
                : FileImage(widget.controller.selectedPhoto!),
            child: widget.controller.selectedPhoto == null
                ? Icon(Icons.camera_alt_outlined, color: AppColor.primaryColor)
                : null,
          ),
        ),
      ),
      const SizedBox(height: 24),
      _field(first, 'first_name'.tr),
      _field(last, 'last_name'.tr),
      _field(email, 'email'.tr, keyboard: TextInputType.emailAddress),
      _field(phone, 'phone'.tr, keyboard: TextInputType.phone),
      const SizedBox(height: 12),
      SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: () => widget.controller.updateProfile(
            firstName: first.text,
            lastName: last.text,
            email: email.text,
            phone: phone.text,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
          ),
          child: Text('save'.tr, style: AppTextStyle.buttonMedium),
        ),
      ),
    ],
  );
  Widget _field(
    TextEditingController c,
    String label, {
    TextInputType? keyboard,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Get.isDarkMode ? AppColor.darkCard : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}

class _Addresses extends StatelessWidget {
  final BuyerProfileController controller;
  const _Addresses({required this.controller});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      ...controller.addresses.map(
        (address) => Card(
          child: ListTile(
            leading: Icon(
              Icons.location_on_outlined,
              color: AppColor.primaryColor,
            ),
            title: Text(address['title']?.toString() ?? ''),
            subtitle: Text(address['details']?.toString() ?? ''),
            trailing: address['is_default'] == true
                ? Chip(label: Text('default_address'.tr))
                : null,
            onTap: () => controller.setDefaultAddress(address['id'].toString()),
          ),
        ),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () async {
          final result = await Get.toNamed('/buyer/address-map');
          if (result != null) {
            controller.saveAddress({
              'title': result.title,
              'details': result.details,
              'latitude': result.latitude,
              'longitude': result.longitude,
              'driver_notes': result.driverNotes,
              'is_default': controller.addresses.isEmpty,
            });
          }
        },
        icon: const Icon(Icons.map_outlined),
        label: Text('pick_address'.tr),
      ),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: () => _add(context),
        icon: const Icon(Icons.add),
        label: Text('add_new_address'.tr),
      ),
    ],
  );
  Future<void> _add(BuildContext context) async {
    final title = TextEditingController(), details = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('add_new_address'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: InputDecoration(labelText: 'address_title'.tr),
            ),
            TextField(
              controller: details,
              decoration: InputDecoration(labelText: 'detected_address'.tr),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.saveAddress({
                'title': title.text.trim(),
                'details': details.text.trim(),
                'is_default': controller.addresses.isEmpty,
              });
            },
            child: Text('save_address'.tr),
          ),
        ],
      ),
    );
  }
}

class _Wallet extends StatelessWidget {
  final BuyerProfileController controller;
  const _Wallet({required this.controller});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Card(
        color: AppColor.primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'sham_cash_balance'.tr,
                style: AppTextStyle.bodyMedium.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                (controller.wallet['balance'] ??
                        controller.wallet['data']?['balance'] ??
                        '0')
                    .toString(),
                style: AppTextStyle.heading1.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () => _requestDeposit(context),
        icon: const Icon(Icons.add),
        label: Text('wallet_add_balance'.tr),
      ),
      const SizedBox(height: 20),
      Text('transaction_history'.tr, style: AppTextStyle.heading3),
      ...controller.walletHistory.map(
        (item) => ListTile(
          title: Text(
            item['description']?.toString() ?? item['type']?.toString() ?? '',
          ),
          subtitle: Text(item['created_at']?.toString() ?? ''),
          trailing: Text(item['amount']?.toString() ?? ''),
        ),
      ),
      const SizedBox(height: 18),
      Text('wallet_deposit_requests'.tr, style: AppTextStyle.heading3),
      ...controller.depositRequests.map(
        (item) => ListTile(
          title: Text('${item['amount'] ?? ''}'),
          subtitle: Text(item['created_at']?.toString() ?? ''),
          trailing: Text('${item['status'] ?? ''}'),
        ),
      ),
    ],
  );

  Future<void> _requestDeposit(BuildContext context) async {
    final amount = TextEditingController();
    final reference = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('wallet_add_balance'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'wallet_amount'.tr),
            ),
            TextField(
              controller: reference,
              decoration: InputDecoration(labelText: 'wallet_reference'.tr),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              final value = double.tryParse(amount.text.trim());
              if (value != null && value > 0)
                controller.requestWalletDeposit(value, reference.text);
            },
            child: Text('send_request'.tr),
          ),
        ],
      ),
    );
  }
}

class _Notifications extends StatelessWidget {
  final BuyerProfileController controller;
  const _Notifications({required this.controller});
  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController(), permanent: true);
    }
    final notifications = Get.find<NotificationController>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(
          'notifications_title'.tr,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        GetBuilder<NotificationController>(
          builder: (_) => NotificationListSection(controller: notifications),
        ),
        const SizedBox(height: 24),
        Text(
          'notifications_settings'.tr,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        NotificationPreferencesPanel(
          preferences: controller.notificationSettings,
          onChanged: controller.update,
          onSave: controller.saveNotificationSettings,
        ),
      ],
    );
  }
}

class _Conversations extends StatelessWidget {
  final BuyerProfileController controller;
  const _Conversations({required this.controller});
  @override
  Widget build(BuildContext context) {
    final buyerId = int.tryParse(controller.services.userId) ?? 0;
    if (buyerId == 0) {
      return Center(child: Text('login_required'.tr));
    }
    final query = FirebaseFirestore.instance
        .collection('conversations')
        .where('buyer_uid', isEqualTo: buyerId.toString());

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('server_error'.tr));
        }
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: AppColor.primaryColor),
          );
        }
        final conversations = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final aTime =
                (a.data()['last_time'] as Timestamp?)?.millisecondsSinceEpoch ??
                0;
            final bTime =
                (b.data()['last_time'] as Timestamp?)?.millisecondsSinceEpoch ??
                0;
            return bTime.compareTo(aTime);
          });
        if (conversations.isEmpty) {
          return Center(child: Text('buyer_no_conversations'.tr));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: conversations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, index) {
            final doc = conversations[index];
            final data = doc.data();
            final sellerId = int.tryParse('${data['seller_id'] ?? 0}') ?? 0;
            final unread = int.tryParse('${data['unread_buyer'] ?? 0}') ?? 0;
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColor.primarySurface,
                  backgroundImage: '${data['store_logo'] ?? ''}'.isNotEmpty
                      ? NetworkImage('${data['store_logo']}')
                      : null,
                  child: '${data['store_logo'] ?? ''}'.isEmpty
                      ? Icon(Icons.store_outlined, color: AppColor.primaryColor)
                      : null,
                ),
                title: Text(data['store_name']?.toString() ?? ''),
                subtitle: Text(
                  data['last_message']?.toString() ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: unread > 0
                    ? CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColor.error,
                        child: Text(
                          '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      )
                    : null,
                onTap: () => Get.toNamed(
                  AppRoute.buyerChatRoom,
                  arguments: {
                    'seller_id': sellerId,
                    'store_name': data['store_name']?.toString() ?? '',
                    'store_logo': data['store_logo']?.toString() ?? '',
                    'buyer_id': buyerId,
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
