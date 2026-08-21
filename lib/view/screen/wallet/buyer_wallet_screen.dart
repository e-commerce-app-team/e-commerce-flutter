import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/wallet_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/view/screen/wallet/wallet_scanner_screen.dart';
import 'package:e_commerce/view/screen/wallet/wallet_qr_screen.dart';
import 'package:e_commerce/view/screen/wallet/wallet_dialogs.dart';

class BuyerWalletScreen extends StatelessWidget {
  BuyerWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<WalletController>()) {
      Get.put(WalletController());
    }
    return GetBuilder<WalletController>(
      builder: (controller) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        appBar: AppBar(
          title: Text('buyer_profile_wallet'.tr),
          backgroundColor: AppColor.primaryColor,
        ),
        body:
            controller.status == StatusRequest.loading &&
                controller.wallet == null
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: controller.load,
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    _BalanceCard(controller: controller),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _Action(
                          icon: Icons.add,
                          label: 'wallet_add_balance'.tr,
                          onTap: () => _amountDialog(controller, false),
                        ),
                        _Action(
                          icon: Icons.send_outlined,
                          label: 'wallet_send'.tr,
                          onTap: () => _sendDialog(controller),
                        ),
                        _Action(
                          icon: Icons.download_outlined,
                          label: 'wallet_withdraw_btn'.tr,
                          onTap: () => _amountDialog(controller, true),
                        ),
                        _Action(
                          icon: Icons.qr_code_2,
                          label: 'wallet_my_qr'.tr,
                          onTap: () => _showMyQr(controller),
                        ),
                        _Action(
                          icon: Icons.qr_code_scanner,
                          label: 'wallet_scan_qr'.tr,
                          onTap: () => _scan(controller),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Text(
                      'transaction_history'.tr,
                      style: AppTextStyle.heading3,
                    ),
                    SizedBox(height: 8),
                    if (controller.history.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('wallet_no_tx'.tr)),
                      )
                    else
                      ...controller.history.map(
                        (entry) => Card(
                          child: ListTile(
                            leading: Icon(
                              entry.isCredit
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: entry.isCredit
                                  ? AppColor.success
                                  : AppColor.error,
                            ),
                            title: Text(
                              entry.description.isEmpty
                                  ? entry.type
                                  : entry.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(entry.status),
                            trailing: Text(
                              '${entry.isCredit ? '+' : '-'}${entry.amount.toStringAsFixed(0)} SP',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _showMyQr(WalletController controller) async {
    final payload = await controller.loadQr();
    if (payload != null) {
      Get.to(() => WalletQrScreen(), arguments: payload);
    }
  }

  Future<void> _scan(WalletController controller) async {
    final result = await Get.to(() => WalletScannerScreen());
    if (result is! Map) {
      return;
    }
    if (result['type'] == 'wallet') {
      final recipient = Map<String, dynamic>.from(result['recipient'] as Map);
      await _sendDialog(
        controller,
        recipientToken: recipient['wallet_token']?.toString(),
        recipientName: recipient['name']?.toString(),
      );
    } else if (result['type'] == 'order_payment') {
      final order = Map<String, dynamic>.from(result['order'] as Map);
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: Text('wallet_order_payment'.tr),
          content: Text(
            '${order['store_name'] ?? ''}\n${order['number'] ?? ''}\n${order['amount'] ?? 0} SP',
          ),
          actions: [
            TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: Text('confirm'.tr),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await controller.payOrder('${order['id']}');
      }
    }
  }

  Future<void> _amountDialog(
    WalletController controller,
    bool withdrawal,
  ) async {
    final value = await showWalletAmountDialog(withdrawal: withdrawal);
    if (value != null) {
      await (withdrawal
          ? controller.requestWithdrawal(value)
          : controller.requestDeposit(value));
    }
  }

  Future<void> _sendDialog(
    WalletController controller, {
    String? recipientToken,
    String? recipientName,
  }) async {
    final input = await showWalletTransferDialog(
      recipientToken: recipientToken,
      recipientName: recipientName,
    );
    if (input != null) {
      await controller.transfer(input.recipientToken, input.amount);
    }
  }
}

class _BalanceCard extends StatelessWidget {
  final WalletController controller;
  _BalanceCard({required this.controller});
  @override
  Widget build(BuildContext context) {
    final wallet = controller.wallet;
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff0F3460), Color(0xff185FA5)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'wallet_total_balance'.tr,
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 6),
          Text(
            '${wallet?.total.toStringAsFixed(0) ?? '0'} SP',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'wallet_available_balance'.tr,
                  value: wallet?.available ?? 0,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _Metric(
                  label: 'wallet_locked_balance'.tr,
                  value: wallet?.locked ?? 0,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 96,
                child: _Metric(
                  label: 'wallet_incoming'.tr,
                  value: wallet?.incoming ?? 0,
                ),
              ),
              SizedBox(
                width: 96,
                child: _Metric(
                  label: 'wallet_outgoing'.tr,
                  value: wallet?.outgoing ?? 0,
                ),
              ),
              SizedBox(
                width: 96,
                child: _Metric(
                  label: 'wallet_commission'.tr,
                  value: wallet?.commission ?? 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final double value;
  _Metric({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.white70, fontSize: 11),
      ),
      Text(
        '${value.toStringAsFixed(0)} SP',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ],
  );
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _Action({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: (MediaQuery.of(context).size.width - 42) / 2,
    child: OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    ),
  );
}
