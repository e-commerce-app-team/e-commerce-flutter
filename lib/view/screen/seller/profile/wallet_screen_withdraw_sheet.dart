part of 'wallet_screen.dart';

void _showWithdrawSheet(
    BuildContext context, SellerWalletController ctrl) {
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
      child: Column(mainAxisSize: MainAxisSize.min, children: [
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
        Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColor.primarySurface,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.download_rounded,
                size: 18, color: AppColor.primaryColor),
          ),
          const SizedBox(width: 10),
          Text('wallet_withdraw_title'.tr,
              style: AppTextStyle.heading3.copyWith(fontSize: 16)),
          const Spacer(),
          _AvailableBadge(ctrl: ctrl),
        ]),
        const SizedBox(height: 18),
        _MethodSelector(ctrl: ctrl),
        const SizedBox(height: 16),
        Form(
          key: ctrl.formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AppField(
              controller: ctrl.withdrawAmountCtrl,
              label: 'wallet_amount_label'.tr,
              hint: 'wallet_amount_hint'.tr,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: ctrl.validateAmount,
            ),
            const SizedBox(height: 12),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 240),
              crossFadeState: ctrl.selectedMethod == 0
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: AppField(
                controller: ctrl.shaamPhoneCtrl,
                label: 'wallet_shaam_phone'.tr,
                hint: 'wallet_shaam_phone_hint'.tr,
                keyboardType: TextInputType.phone,
                validator: ctrl.validateShaamPhone,
              ),
              secondChild: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                AppField(
                  controller: ctrl.bankNameCtrl,
                  label: 'wallet_bank_name'.tr,
                  hint: 'wallet_bank_name_hint'.tr,
                  validator: ctrl.validateBankName,
                ),
                const SizedBox(height: 10),
                AppField(
                  controller: ctrl.bankIbanCtrl,
                  label: 'wallet_iban'.tr,
                  hint: 'wallet_iban_hint'.tr,
                  validator: ctrl.validateIban,
                ),
                const SizedBox(height: 10),
                AppField(
                  controller: ctrl.bankHolderCtrl,
                  label: 'wallet_account_holder'.tr,
                  hint: 'wallet_account_holder_hint'.tr,
                  validator: ctrl.validateHolder,
                ),
              ]),
            ),
          ]),
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
              disabledBackgroundColor:
                  AppColor.primaryColor.withOpacity(0.6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: ctrl.withdrawStatusRequest == StatusRequest.loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Text('wallet_confirm_withdraw'.tr,
                    style: AppTextStyle.buttonMedium),
          ),
        ),
      ]),
    );
  }
}

class _AvailableBadge extends StatelessWidget {
  final SellerWalletController ctrl;
  const _AvailableBadge({required this.ctrl});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColor.successLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColor.success.withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.account_balance_wallet_outlined,
              size: 12, color: AppColor.successDark),
          const SizedBox(width: 5),
          Text(ctrl.formattedAvailable,
              style: AppTextStyle.chip.copyWith(
                  color: AppColor.successDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 11)),
        ]),
      );
}

class _MethodSelector extends StatelessWidget {
  final SellerWalletController ctrl;
  const _MethodSelector({required this.ctrl});

  @override
  Widget build(BuildContext context) => Row(children: [
        _MethodCard(
          index: 0,
          icon: Icons.phone_android_rounded,
          label: 'wallet_method_shaam'.tr,
          sublabel: 'wallet_method_shaam_sub'.tr,
          isSelected: ctrl.selectedMethod == 0,
          onTap: () => ctrl.selectMethod(0),
        ),
        const SizedBox(width: 10),
        _MethodCard(
          index: 1,
          icon: Icons.account_balance_outlined,
          label: 'wallet_method_bank'.tr,
          sublabel: 'wallet_method_bank_sub'.tr,
          isSelected: ctrl.selectedMethod == 1,
          onTap: () => ctrl.selectMethod(1),
        ),
      ]);
}

class _MethodCard extends StatelessWidget {
  final int        index;
  final IconData   icon;
  final String     label;
  final String     sublabel;
  final bool       isSelected;
  final VoidCallback onTap;
  const _MethodCard({
    required this.index,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
                vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColor.primarySurface
                  : AppColor.secondBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? AppColor.primaryColor
                    : AppColor.greyBorder,
                width: isSelected ? 1.8 : 0.8,
              ),
            ),
            child: Row(children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColor.primaryColor
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon,
                    size: 18,
                    color: isSelected
                        ? Colors.white
                        : AppColor.grey),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(label,
                      style: AppTextStyle.labelLarge.copyWith(
                        fontSize: 12,
                        color: isSelected
                            ? AppColor.primaryColor
                            : AppColor.black,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      )),
                  Text(sublabel,
                      style: AppTextStyle.labelSmall.copyWith(
                          fontSize: 9.5,
                          color: isSelected
                              ? AppColor.primaryColor.withOpacity(0.7)
                              : AppColor.greyLight)),
                ]),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded,
                    size: 16, color: AppColor.primaryColor),
            ]),
          ),
        ),
      );
}

class _MinAmountNote extends StatelessWidget {
  final SellerWalletController ctrl;
  const _MinAmountNote({required this.ctrl});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: AppColor.infoLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: AppColor.info.withOpacity(0.25)),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline_rounded,
              size: 14, color: AppColor.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${'wallet_min_note'.tr} SP ${ctrl.minWithdrawal ~/ 1000}k',
              style: AppTextStyle.labelSmall.copyWith(
                  color: AppColor.info,
                  fontSize: 11),
            ),
          ),
        ]),
      );
}
