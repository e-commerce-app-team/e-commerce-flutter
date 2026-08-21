import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:e_commerce/controller/wallet_controller.dart';
import 'package:e_commerce/core/constant/color.dart';

class WalletScannerScreen extends StatefulWidget {
  WalletScannerScreen({super.key});

  @override
  State<WalletScannerScreen> createState() => _WalletScannerScreenState();
}

class _WalletScannerScreenState extends State<WalletScannerScreen> {
  late final MobileScannerController _scannerController;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      autoStart: true,
      detectionSpeed: DetectionSpeed.normal,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled || capture.barcodes.isEmpty) return;
    final value = capture.barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;
    setState(() => _handled = true);
    final controller = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(WalletController());
    final result = await controller.resolveQr(value);
    if (!mounted) return;
    if (result == null) {
      setState(() => _handled = false);
      return;
    }
    Get.back(result: result);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      title: Text('wallet_scan_qr'.tr),
      backgroundColor: AppColor.primaryColor,
    ),
    body: Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: _onDetect,
          placeholderBuilder: (_) =>
              Center(child: CircularProgressIndicator(color: Colors.white)),
          errorBuilder: (context, error) => _ScannerError(
            error: error,
            onRetry: () async {
              try {
                await _scannerController.start();
              } catch (_) {
                if (mounted) setState(() {});
              }
            },
          ),
        ),
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        Positioned(
          bottom: 36,
          left: 24,
          right: 24,
          child: Text(
            'wallet_scan_instruction'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    ),
  );
}

class _ScannerError extends StatelessWidget {
  final MobileScannerException error;
  final VoidCallback onRetry;

  _ScannerError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black,
    alignment: Alignment.center,
    padding: EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.no_photography_outlined, color: Colors.white, size: 52),
        SizedBox(height: 14),
        Text(
          'wallet_camera_error'.tr,
          style: TextStyle(color: Colors.white, fontSize: 17),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          error.errorDetails?.message ?? error.errorCode.name,
          style: TextStyle(color: Colors.white70, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: Icon(Icons.refresh, color: Colors.white),
          label: Text('retry'.tr, style: TextStyle(color: Colors.white)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
