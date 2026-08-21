import 'package:get/get.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/data/datasource/remote/wallet_data.dart';
import 'package:e_commerce/data/model/wallet_model.dart';

class WalletController extends GetxController {
  late final WalletDataSource data;
  final services = Get.find<MyServices>();
  WalletSnapshot? wallet;
  List<WalletLedgerEntry> history = [];
  StatusRequest status = StatusRequest.none;
  String? qrPayload;

  String get token => services.sharedPreferences.getString('token') ?? '';

  @override
  void onInit() {
    super.onInit();
    data = WalletDataSource(Get.find<Crud>());
    load();
  }

  Future<void> load() async {
    status = StatusRequest.loading;
    update();
    final results = await Future.wait([
      data.summary(token),
      data.history(token),
    ]);
    final balance = results[0];
    final ledger = results[1];
    balance.fold((failure) => status = failure, (body) {
      wallet = WalletSnapshot.fromJson(body);
      status = StatusRequest.success;
    });
    ledger.fold((_) {}, (body) {
      history = ((body['data'] as List?) ?? const [])
          .whereType<Map>()
          .map(WalletLedgerEntry.fromJson)
          .toList();
    });
    update();
  }

  Future<bool> requestDeposit(double amount) async {
    final result = await data.requestDeposit(token, amount);
    return result.fold<Future<bool>>(
      (_) async {
        _error();
        return false;
      },
      (body) async {
        if (body['success'] == true) {
          customSnackbar(
            'success'.tr,
            'wallet_deposit_pending'.tr,
            isError: false,
          );
          await load();
          return true;
        }
        customSnackbar(
          'error'.tr,
          body['message']?.toString() ?? 'server_error'.tr,
        );
        return false;
      },
    );
  }

  Future<bool> requestWithdrawal(double amount) async {
    final result = await data.requestWithdrawal(token, amount);
    return result.fold<Future<bool>>(
      (_) async {
        _error();
        return false;
      },
      (body) async {
        if (body['success'] == true) {
          customSnackbar(
            'success'.tr,
            'wallet_withdraw_pending'.tr,
            isError: false,
          );
          await load();
          return true;
        }
        customSnackbar(
          'error'.tr,
          body['message']?.toString() ?? 'server_error'.tr,
        );
        return false;
      },
    );
  }

  Future<String?> loadQr() async {
    final result = await data.myQr(token);
    return result.fold<String?>(
      (_) {
        _error();
        return null;
      },
      (body) {
        qrPayload = body['payload']?.toString();
        return qrPayload;
      },
    );
  }

  Future<Map<String, dynamic>?> resolveQr(String payload) async {
    final result = await data.resolveQr(token, payload);
    return result.fold<Map<String, dynamic>?>(
      (_) {
        _error();
        return null;
      },
      (body) =>
          body['success'] == true ? Map<String, dynamic>.from(body) : null,
    );
  }

  Future<bool> transfer(String recipientToken, double amount) async {
    final result = await data.transfer(token, recipientToken, amount);
    return result.fold<Future<bool>>(
      (_) async {
        _error();
        return false;
      },
      (body) async {
        if (body['success'] == true) {
          customSnackbar(
            'success'.tr,
            'wallet_transfer_done'.tr,
            isError: false,
          );
          await load();
          return true;
        }
        customSnackbar(
          'error'.tr,
          body['message']?.toString() ?? 'server_error'.tr,
        );
        return false;
      },
    );
  }

  Future<bool> payOrder(String orderId) async {
    final result = await data.payOrder(token, orderId);
    return result.fold<Future<bool>>(
      (_) async {
        _error();
        return false;
      },
      (body) async {
        if (body['success'] == true) {
          customSnackbar('success'.tr, 'wallet_order_paid'.tr, isError: false);
          await load();
          return true;
        }
        customSnackbar(
          'error'.tr,
          body['message']?.toString() ?? 'server_error'.tr,
        );
        return false;
      },
    );
  }

  void _error() => customSnackbar('error'.tr, 'server_error'.tr);
}

