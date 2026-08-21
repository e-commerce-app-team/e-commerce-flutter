part of 'wallet_screen.dart';

void _showWithdrawSheet(BuildContext context, SellerWalletController ctrl) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => GetBuilder<SellerWalletController>(
      builder: (c) => _WithdrawSheet(ctrl: c),
    ),
  );
}

class _WithdrawSheet extends StatelessWidget {
  final SellerWalletController ctrl;
  const _WithdrawSheet({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColor.greyBorder,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColor.primarySurface,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.download_rounded,
                  size: 18,
                  color: AppColor.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'wallet_withdraw_title'.tr,
                style: AppTextStyle.heading3.copyWith(fontSize: 16),
              ),
              const Spacer(),
              _AvailableBadge(ctrl: ctrl),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                tooltip: 'cancel'.tr,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Form(
            key: ctrl.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppField(
                  controller: ctrl.withdrawAmountCtrl,
                  label: 'wallet_amount_label'.tr,
                  hint: 'wallet_amount_hint'.tr,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: ctrl.validateAmount,
                ),
                const SizedBox(height: 12),
                AppField(
                  controller: ctrl.shamCashQrCtrl,
                  label: 'wallet_sham_qr_code'.tr,
                  hint: 'wallet_sham_qr_hint'.tr,
                  keyboardType: TextInputType.text,
                  validator: ctrl.validateShamCashQr,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _MinAmountNote(ctrl: ctrl),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: ctrl.withdrawStatusRequest == StatusRequest.loading
                  ? null
                  : ctrl.submitWithdrawal,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                disabledBackgroundColor: AppColor.primaryColor.withOpacity(0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: ctrl.withdrawStatusRequest == StatusRequest.loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'wallet_confirm_withdraw'.tr,
                      style: AppTextStyle.buttonMedium,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailableBadge extends StatelessWidget {
  final SellerWalletController ctrl;
  const _AvailableBadge({required this.ctrl});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppColor.successLight,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColor.success.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.account_balance_wallet_outlined,
          size: 12,
          color: AppColor.successDark,
        ),
        const SizedBox(width: 5),
        Text(
          ctrl.formattedAvailable,
          style: AppTextStyle.chip.copyWith(
            color: AppColor.successDark,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ],
    ),
  );
}

class _MinAmountNote extends StatelessWidget {
  final SellerWalletController ctrl;
  const _MinAmountNote({required this.ctrl});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: AppColor.infoLight,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColor.info.withOpacity(0.25)),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline_rounded, size: 14, color: AppColor.info),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${'wallet_min_note'.tr} SP ${ctrl.minWithdrawal ~/ 1000}k',
            style: AppTextStyle.labelSmall.copyWith(
              color: AppColor.info,
              fontSize: 11,
            ),
          ),
        ),
      ],
    ),
  );
}
