import 'package:get/get.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/data/datasource/remote/notification_data.dart';
import 'package:e_commerce/data/model/notification_model.dart';
import 'package:e_commerce/core/class/crud.dart';

class NotificationController extends GetxController {
  final MyServices services = Get.find<MyServices>();
  late final NotificationData dataSource;
  StatusRequest statusRequest = StatusRequest.none;
  List<NotificationModel> notifications = [];
  Map<String, bool> preferences = {};
  int unreadCount = 0;

  String get token => services.sharedPreferences.getString('token') ?? '';

  @override
  void onInit() {
    super.onInit();
    dataSource = NotificationData(Get.find<Crud>());
    load();
  }

  Future<void> load() async {
    if (token.isEmpty) return;
    statusRequest = StatusRequest.loading;
    update();
    final response = await dataSource.index(token);
    response.fold((failure) => statusRequest = failure, (body) {
      final list = body['data'];
      notifications = list is List
          ? list.whereType<Map>().map(NotificationModel.fromJson).toList()
          : [];
      unreadCount =
          int.tryParse('${body['unread_count'] ?? 0}') ??
          notifications.where((item) => !item.isRead).length;
      statusRequest = StatusRequest.success;
    });
    update();
  }

  Future<void> markRead(NotificationModel notification) async {
    if (notification.isRead || notification.id.isEmpty) return;
    final index = notifications.indexWhere(
      (item) => item.id == notification.id,
    );
    if (index >= 0) notifications[index] = notification.copyWith(isRead: true);
    if (unreadCount > 0) unreadCount--;
    update();
    await dataSource.markRead(token, notification.id);
  }

  Future<void> markAllRead() async {
    if (unreadCount == 0) return;
    notifications = notifications
        .map((item) => item.copyWith(isRead: true))
        .toList();
    unreadCount = 0;
    update();
    await dataSource.markAllRead(token);
  }

  Future<void> loadPreferences() async {
    final response = await dataSource.preferences(token);
    response.fold((_) {}, (body) {
      final list = body['data'];
      preferences = {
        for (final item
            in (list is List ? list : const <dynamic>[]).whereType<Map>())
          '${item['type']}':
              item['enabled'] == true || '${item['enabled']}' == '1',
      };
      update();
    });
  }

  Future<void> savePreferences() async {
    await dataSource.updatePreferences(
      token,
      preferences.entries
          .map((entry) => {'type': entry.key, 'enabled': entry.value})
          .toList(),
    );
  }
}
