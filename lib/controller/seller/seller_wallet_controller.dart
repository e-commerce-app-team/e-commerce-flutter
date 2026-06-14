import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/data/model/seller/wallet_models.dart';

class SellerWalletController extends GetxController {
  StatusRequest statusRequest          = StatusRequest.none;
  StatusRequest withdrawStatusRequest  = StatusRequest.none;

  WalletModel?                   wallet;
  WalletStatsModel?              stats;
  List<WalletTransaction>        transactions    = [];
  List<PendingWithdrawalModel>   pendingRequests = [];

  String  txFilter        = 'all';
  bool    showBalance     = true;
  int     selectedMethod  = 0;

  final withdrawAmountCtrl = TextEditingController();
  final shaamPhoneCtrl     = TextEditingController();
  final bankNameCtrl       = TextEditingController();
  final bankIbanCtrl       = TextEditingController();
  final bankHolderCtrl     = TextEditingController();
  final formKey            = GlobalKey<FormState>();

  final int minWithdrawal = 50000;

  List<WalletTransaction> get filteredTransactions {
    if (txFilter == 'all') return transactions;
    return transactions.where((t) => t.type == txFilter).toList();
  }

  bool get canWithdraw =>
      wallet != null && wallet!.available >= minWithdrawal;

  String get formattedAvailable =>
      _fmt(wallet?.available ?? 0);

  String get formattedReserved =>
      _fmt(wallet?.reserved ?? 0);

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

    await Future.delayed(const Duration(milliseconds: 700));

    wallet          = WalletModel.mock();
    stats           = WalletStatsModel.mock();
    transactions    = WalletTransaction.mockList();
    pendingRequests = PendingWithdrawalModel.mockList();

    statusRequest = StatusRequest.success;
    update();
  }

  Future<void> submitWithdrawal() async {
    if (!formKey.currentState!.validate()) return;
    withdrawStatusRequest = StatusRequest.loading;
    update();

    await Future.delayed(const Duration(milliseconds: 800));

    final amount = int.tryParse(
          withdrawAmountCtrl.text.trim().replaceAll(',', ''),
        ) ?? 0;

    final newTx = WalletTransaction(
      id:          (transactions.length + 1),
      type:        'debit',
      amount:      amount,
      description: selectedMethod == 0
          ? 'wallet_withdraw_shaam'.tr
          : 'wallet_withdraw_bank'.tr,
      reference:   '#WD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      date:        'wallet_just_now'.tr,
      status:      'pending',
    );

    transactions.insert(0, newTx);
    wallet = WalletModel(
      available: wallet!.available - amount,
      reserved:  wallet!.reserved,
    );

    pendingRequests.insert(
      0,
      PendingWithdrawalModel(
        id:          newTx.id,
        amount:      amount,
        method:      selectedMethod == 0 ? 'shaam_cash' : 'bank_transfer',
        methodInfo:  selectedMethod == 0
            ? shaamPhoneCtrl.text.trim()
            : bankNameCtrl.text.trim(),
        status:      'pending',
        requestedAt: 'wallet_just_now'.tr,
      ),
    );

    _clearWithdrawForm();
    withdrawStatusRequest = StatusRequest.success;
    update();

    Get.back();
    customSnackbar(
      'wallet_withdraw_sent_title'.tr,
      'wallet_withdraw_sent_body'.tr,
      isError: false,
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
    if (n == null)           return 'wallet_amount_invalid'.tr;
    if (n < minWithdrawal)   return 'wallet_amount_min'.tr;
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
