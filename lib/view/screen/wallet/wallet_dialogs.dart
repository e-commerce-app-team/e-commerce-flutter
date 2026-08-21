import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletTransferInput {
  final String recipientToken;
  final double amount;

  const WalletTransferInput({
    required this.recipientToken,
    required this.amount,
  });
}

Future<double?> showWalletAmountDialog({required bool withdrawal}) async {
  final value = await Get.dialog<double>(
    _WalletAmountDialog(withdrawal: withdrawal),
    barrierDismissible: true,
  );
  await Future<void>.delayed(const Duration(milliseconds: 220));
  return value;
}

Future<WalletTransferInput?> showWalletTransferDialog({
  String? recipientToken,
  String? recipientName,
}) async {
  final value = await Get.dialog<WalletTransferInput>(
    _WalletTransferDialog(
      recipientToken: recipientToken,
      recipientName: recipientName,
    ),
    barrierDismissible: true,
  );
  await Future<void>.delayed(const Duration(milliseconds: 220));
  return value;
}

class _WalletAmountDialog extends StatefulWidget {
  final bool withdrawal;

  const _WalletAmountDialog({required this.withdrawal});

  @override
  State<_WalletAmountDialog> createState() => _WalletAmountDialogState();
}

class _WalletAmountDialogState extends State<_WalletAmountDialog> {
  late final TextEditingController _amountController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final value = double.tryParse(_amountController.text.trim());
    if (value == null || value <= 0) {
      setState(() => _error = 'wallet_amount_invalid'.tr);
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.withdrawal ? 'wallet_withdraw_title'.tr : 'wallet_add_balance'.tr,
    ),
    content: TextField(
      controller: _amountController,
      autofocus: true,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'wallet_amount'.tr,
        errorText: _error,
      ),
      onSubmitted: (_) => _submit(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text('cancel'.tr),
      ),
      ElevatedButton(onPressed: _submit, child: Text('confirm'.tr)),
    ],
  );
}

class _WalletTransferDialog extends StatefulWidget {
  final String? recipientToken;
  final String? recipientName;

  const _WalletTransferDialog({this.recipientToken, this.recipientName});

  @override
  State<_WalletTransferDialog> createState() => _WalletTransferDialogState();
}

class _WalletTransferDialogState extends State<_WalletTransferDialog> {
  late final TextEditingController _tokenController;
  late final TextEditingController _amountController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: widget.recipientToken ?? '');
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final token = _tokenController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    if (token.isEmpty || amount == null || amount <= 0) {
      setState(() => _error = 'wallet_transfer_data_invalid'.tr);
      return;
    }
    Navigator.of(
      context,
    ).pop(WalletTransferInput(recipientToken: token, amount: amount));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('wallet_send'.tr),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.recipientName != null) ...[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text('${'wallet_recipient'.tr}: ${widget.recipientName}'),
            ),
            const SizedBox(height: 10),
          ],
          TextField(
            controller: _tokenController,
            decoration: InputDecoration(labelText: 'wallet_recipient_token'.tr),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'wallet_amount'.tr,
              errorText: _error,
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text('cancel'.tr),
      ),
      ElevatedButton(onPressed: _submit, child: Text('confirm'.tr)),
    ],
  );
}

