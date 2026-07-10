import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/data/datasource/remote/seller/seller_wallet_data.dart';
import 'package:e_commerce/data/model/seller/wallet_models.dart';

class SellerWalletController extends GetxController {
  final MyServices _myServices = Get.find();
  late final SellerWalletRemoteData _walletData;

  StatusRequest statusRequest         = StatusRequest.none;
  StatusRequest withdrawStatusRequest = StatusRequest.none;

  WalletModel?                   wallet;
  WalletStatsModel?              stats;
  List<WalletTransaction>        transactions    = [];
  List<PendingWithdrawalModel>   pendingRequests = [];

  String  txFilter       = 'all';
  bool    showBalance    = true;
  int     selectedMethod = 0;

  final withdrawAmountCtrl = TextEditingController();
  final shaamPhoneCtrl     = TextEditingController();
  final bankNameCtrl       = TextEditingController();
  final bankIbanCtrl       = TextEditingController();
  final bankHolderCtrl     = TextEditingController();
  final formKey            = GlobalKey<FormState>();

  final int minWithdrawal = 50000;

  String get _token => _myServices.sharedPreferences.getString('token') ?? '';

  List<WalletTransaction> get filteredTransactions {
    if (txFilter == 'all') return transactions;
    return transactions.where((t) => t.type == txFilter).toList();
  }

  bool get canWithdraw =>
      wallet != null && wallet!.available >= minWithdrawal;

  String get formattedAvailable => _fmt(wallet?.available ?? 0);
  String get formattedReserved  => _fmt(wallet?.reserved  ?? 0);

  String _fmt(int v) {
    if (v >= 1000000) return 'SP ${(v / 1000000).toStringAsFixed(1)}م';
    if (v >= 1000)    return 'SP ${v ~/ 1000},${((v % 1000) ~/ 100)}00';
    return 'SP $v';
  }

  void toggleBalanceVisibility() {
    showBalance = !showBalance;
    update();
  }

  void setTxFilter(String f) {
    if (txFilter == f) return;
    txFilter = f;
    update();
  }

  void selectMethod(int i) {
    selectedMethod = i;
    update();
  }

  Future<void> loadData() async {
    statusRequest = StatusRequest.loading;
    update();

    // ─── 1. جلب الرصيد من /balance ───────────────────────────────────────
    final balanceResult = await _walletData.getBalance(_token);
    balanceResult.fold(
      (failure) {
        statusRequest = failure;
        update();
        return;
      },
      (data) {
        wallet = WalletModel.fromJson(data);
        // إحصائيات - الباك لا يُرجعها حالياً، نستخدم mock
        stats = WalletStatsModel.mock();
      },
    );

    // ─── 2. جلب تاريخ السحوبات من /history ──────────────────────────────
    final historyResult = await _walletData.getWithdrawalHistory(_token);
    historyResult.fold(
      (failure) {
        // فشل التاريخ لا يمنع عرض الرصيد
        transactions    = [];
        pendingRequests = [];
      },
      (data) {
        List<dynamic> rawList = [];
        if (data.containsKey('data') && data['data'] is List) {
          rawList = data['data'] as List<dynamic>;
        } else if (data.isEmpty == false) {
          // If the backend returned a flat object instead of list for some reason
          rawList = [];
        }

        transactions = rawList
            .map((e) => WalletTransaction.fromPayoutJson(e as Map))
            .toList();

        pendingRequests = rawList
            .where((e) => e['status'] == 'pending')
            .map((e) => PendingWithdrawalModel.fromPayoutJson(e as Map))
            .toList();
      },
    );

    statusRequest = StatusRequest.success;
    update();
  }

  Future<void> submitWithdrawal() async {
    if (!formKey.currentState!.validate()) return;
    withdrawStatusRequest = StatusRequest.loading;
    update();

    final amount = int.tryParse(
          withdrawAmountCtrl.text.trim().replaceAll(',', ''),
        ) ??
        0;

    final Map<String, dynamic> body;
    if (selectedMethod == 0) {
      // شام كاش
      body = {
        'amount':         amount,
        'payout_method':  'sham cash',
        'sham_code':      shaamPhoneCtrl.text.trim(),
        // qr_image: يحتاج multipart - الباك يقبله بدونه لو أرسلناه بـ postData
      };
    } else {
      // بنك
      body = {
        'amount':          amount,
        'payout_method':   'bank account',
        'payout_account':  bankIbanCtrl.text.trim().isNotEmpty
            ? bankIbanCtrl.text.trim()
            : bankHolderCtrl.text.trim(),
      };
    }

    final result = await _walletData.withdraw(_token, data: body);

    result.fold(
      (failure) {
        withdrawStatusRequest = failure;
        update();
        customSnackbar('error'.tr, 'server_error'.tr);
      },
      (res) {
        if (res['success'] == true) {
          // تحديث الرصيد من الاستجابة
          if (res['new_balance'] != null) {
            final newBal = (res['new_balance'] as num).round();
            wallet = WalletModel(
              available: newBal,
              reserved:  wallet?.reserved ?? 0,
              total:     newBal + (wallet?.reserved ?? 0),
            );
          }

          // إضافة السحب للقائمة المحلية
          final newTx = WalletTransaction(
            id:          (transactions.length + 1),
            type:        'debit',
            amount:      amount,
            description: selectedMethod == 0 ? 'wallet_withdraw_shaam'.tr : 'wallet_withdraw_bank'.tr,
            reference:   '#WD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
            date:        'wallet_just_now'.tr,
            status:      'completed',
          );
          transactions.insert(0, newTx);

          _clearWithdrawForm();
          withdrawStatusRequest = StatusRequest.success;
          update();

          Get.back();
          customSnackbar(
            'wallet_withdraw_sent_title'.tr,
            'wallet_withdraw_sent_body'.tr,
            isError: false,
          );
        } else {
          withdrawStatusRequest = StatusRequest.none;
          customSnackbar('warning'.tr, (res['message'] ?? '').toString());
          update();
        }
      },
    );
  }

  void _clearWithdrawForm() {
    withdrawAmountCtrl.clear();
    shaamPhoneCtrl.clear();
    bankNameCtrl.clear();
    bankIbanCtrl.clear();
    bankHolderCtrl.clear();
    selectedMethod = 0;
  }

  String? validateAmount(String? v) {
    if (v == null || v.trim().isEmpty) return 'wallet_amount_required'.tr;
    final n = int.tryParse(v.trim().replaceAll(',', ''));
    if (n == null)               return 'wallet_amount_invalid'.tr;
    if (n < minWithdrawal)       return 'wallet_amount_min'.tr;
    if (n > (wallet?.available ?? 0)) return 'wallet_amount_exceeds'.tr;
    return null;
  }

  String? validateShaamPhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'wallet_phone_required'.tr;
    if (v.trim().length < 9)           return 'wallet_phone_invalid'.tr;
    return null;
  }

  String? validateBankName(String? v) {
    if (v == null || v.trim().isEmpty) return 'wallet_bank_name_required'.tr;
    return null;
  }

  String? validateIban(String? v) {
    if (v == null || v.trim().isEmpty) return 'wallet_iban_required'.tr;
    return null;
  }

  String? validateHolder(String? v) {
    if (v == null || v.trim().isEmpty) return 'wallet_holder_required'.tr;
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    _walletData = SellerWalletRemoteData(Get.find<Crud>());
    loadData();
  }

  @override
  void onClose() {
    withdrawAmountCtrl.dispose();
    shaamPhoneCtrl.dispose();
    bankNameCtrl.dispose();
    bankIbanCtrl.dispose();
    bankHolderCtrl.dispose();
    super.onClose();
  }
}
