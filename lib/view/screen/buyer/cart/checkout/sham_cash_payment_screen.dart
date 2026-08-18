import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/functions/format_price.dart';
import 'package:e_commerce/data/datasource/remote/buyer/cart_datasource.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/core/services/services.dart';

class ShamCashPaymentScreen extends StatefulWidget {
  final String orderId;
  final String orderNumber;
  final double totalAmount;
  final double walletBalance;

  const ShamCashPaymentScreen({
    super.key,
    required this.orderId,
    required this.orderNumber,
    required this.totalAmount,
    required this.walletBalance,
  });

  @override
  State<ShamCashPaymentScreen> createState() => _ShamCashPaymentScreenState();
}

class _ShamCashPaymentScreenState extends State<ShamCashPaymentScreen> {
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _isPaying = false;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (_passwordCtrl.text.trim().isEmpty) {
      customSnackbar('error'.tr, 'sham_cash_password_required'.tr);
      return;
    }

    setState(() => _isPaying = true);

    final token = Get.find<MyServices>().sharedPreferences.getString('token') ?? '';
    final ds = BuyerCartDataSource(Get.find<Crud>());
    final result = await ds.payOrder(token, widget.orderId, _passwordCtrl.text);

    if (!mounted) return;
    setState(() => _isPaying = false);

    result.fold(
      (_) => customSnackbar('error'.tr, 'server_error'.tr),
      (body) {
        if (body['success'] == true) {
          Get.back(result: true);
        } else {
          customSnackbar(
            'error'.tr,
            body['message']?.toString() ?? 'payment_failed'.tr,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canPay = widget.walletBalance >= widget.totalAmount;

    return Scaffold(
      backgroundColor: AppColor.backgroundScaffold,
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
        title: Text('sham_cash_title'.tr, style: AppTextStyle.appBarTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: _isPaying ? null : () => Get.back(result: false),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            children: [
              _ShamHeader(orderNumber: widget.orderNumber),
              const SizedBox(height: 20),
              _InfoCard(
                icon: Icons.account_balance_wallet_outlined,
                title: 'sham_cash_balance'.tr,
                value: '${formatPrice(widget.walletBalance)} ${'currency'.tr}',
              ),
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.payments_outlined,
                title: 'sham_cash_amount'.tr,
                value: '${formatPrice(widget.totalAmount)} ${'currency'.tr}',
                highlight: true,
              ),
              const SizedBox(height: 24),
              Text('sham_cash_password'.tr, style: AppTextStyle.inputLabel),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                enabled: !_isPaying,
                style: AppTextStyle.inputText,
                decoration: InputDecoration(
                  hintText: 'sham_cash_password_hint'.tr,
                  hintStyle: AppTextStyle.inputHint,
                  filled: true,
                  fillColor: AppColor.cardBackground,
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                      color: AppColor.primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColor.grey,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColor.greyBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColor.greyBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColor.primaryColor, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColor.infoLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColor.info.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColor.info, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'sham_cash_escrow_note'.tr,
                        style: AppTextStyle.bodySmall.copyWith(color: AppColor.infoDark),
                      ),
                    ),
                  ],
                ),
              ),
              if (!canPay) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColor.errorLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'insufficient_balance'.tr,
                    style: AppTextStyle.bodySmall.copyWith(color: AppColor.error),
                  ),
                ),
              ],
            ],
          ),
          if (_isPaying)
            Container(
              color: AppColor.black.withOpacity(0.45),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColor.cardBackground,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppColor.primaryColor),
                      const SizedBox(height: 18),
                      Text('payment_processing'.tr, style: AppTextStyle.heading3),
                      const SizedBox(height: 8),
                      Text(
                        'payment_processing_sub'.tr,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: (_isPaying || !canPay) ? null : _pay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                disabledBackgroundColor: AppColor.greyLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              child: Text('pay_now'.tr, style: AppTextStyle.buttonLarge),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShamHeader extends StatelessWidget {
  final String orderNumber;
  const _ShamHeader({required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColor.mainGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColor.primaryShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColor.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.account_balance_wallet_rounded,
                color: AppColor.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('sham_cash_brand'.tr,
                    style: AppTextStyle.heading2.copyWith(color: AppColor.white)),
                const SizedBox(height: 4),
                Text(
                  '${'order_number'.tr}: $orderNumber',
                  style: AppTextStyle.bodySmall.copyWith(color: AppColor.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool highlight;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? AppColor.primarySurface : AppColor.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? AppColor.primaryColor.withOpacity(0.25)
              : AppColor.greyBorder,
        ),
        boxShadow: AppColor.cardShadow,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColor.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyle.labelMedium),
                Text(
                  value,
                  style: highlight ? AppTextStyle.priceLarge : AppTextStyle.price,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
