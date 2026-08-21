import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';

class WalletQrScreen extends StatelessWidget {
  WalletQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final payload = Get.arguments?.toString() ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text('wallet_my_qr'.tr),
        backgroundColor: AppColor.primaryColor,
      ),
      body: payload.isEmpty
          ? Center(child: Text('wallet_qr_unavailable'.tr))
          : Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'wallet_qr_show'.tr,
                      style: AppTextStyle.heading2,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    Container(
                      padding: EdgeInsets.all(18),
                      color: Colors.white,
                      child: QrImageView(data: payload, size: 260),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'wallet_qr_text_label'.tr,
                      style: AppTextStyle.labelLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColor.secondBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColor.greyBorder),
                      ),
                      child: SelectableText(
                        payload,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: payload));
                        Get.snackbar(
                          'success'.tr,
                          'wallet_qr_copied'.tr,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: EdgeInsets.all(12),
                        );
                      },
                      icon: Icon(Icons.copy_outlined),
                      label: Text('wallet_qr_copy'.tr),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'wallet_qr_safe_note'.tr,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
