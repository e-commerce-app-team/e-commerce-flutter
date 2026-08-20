import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/models/buyer/cart_models.dart';

class BuyerAddressMapScreen extends StatefulWidget {
  const BuyerAddressMapScreen({super.key});

  @override
  State<BuyerAddressMapScreen> createState() => _BuyerAddressMapScreenState();
}

class _BuyerAddressMapScreenState extends State<BuyerAddressMapScreen> {
  late LatLng _point;
  String _addressText = '';
  final _titleCtrl = TextEditingController(text: 'Home');
  final _notesCtrl = TextEditingController();
  bool _loading = true;

  static const _damascus = LatLng(33.5138, 36.2765);

  @override
  void initState() {
    super.initState();
    _point = _damascus;
    _resolveAddress();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _resolveAddress() async {
    setState(() => _loading = true);
    try {
      final places = await geo.placemarkFromCoordinates(
        _point.latitude,
        _point.longitude,
      );
      if (places.isNotEmpty) {
        final p = places.first;
        _addressText = [
          p.street,
          p.subLocality,
          p.locality,
          p.country,
        ].where((e) => e != null && e.trim().isNotEmpty).join(', ');
      }
    } catch (_) {
      _addressText = '${_point.latitude}, ${_point.longitude}';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _goToMyLocation() async {
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return;
    }
    final pos = await Geolocator.getCurrentPosition();
    setState(() => _point = LatLng(pos.latitude, pos.longitude));
    await _resolveAddress();
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty || _addressText.isEmpty) return;

    Get.back(
      result: BuyerAddress(
        id: '',
        title: _titleCtrl.text.trim(),
        details: _addressText,
        latitude: _point.latitude,
        longitude: _point.longitude,
        driverNotes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        isDefault: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundScaffold,
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        title: Text('pick_address'.tr, style: AppTextStyle.appBarTitle),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _point,
                    initialZoom: 15,
                    onPositionChanged: (pos, hasGesture) {
                      if (hasGesture) {
                        _point = pos.center;
                        _resolveAddress();
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.e_commerce',
                    ),
                  ],
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 36),
                    child: Icon(Icons.location_pin,
                        color: AppColor.primaryColor, size: 42),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton.small(
                    backgroundColor: AppColor.cardBackground,
                    onPressed: _goToMyLocation,
                    child: const Icon(Icons.my_location_rounded,
                        color: AppColor.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: BoxDecoration(
              color: AppColor.cardBackground,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: AppColor.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('address_title'.tr, style: AppTextStyle.inputLabel),
                const SizedBox(height: 6),
                TextField(
                  controller: _titleCtrl,
                  style: AppTextStyle.inputText,
                  decoration: InputDecoration(
                    hintText: 'address_title_hint'.tr,
                    filled: true,
                    fillColor: AppColor.secondBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('detected_address'.tr, style: AppTextStyle.inputLabel),
                const SizedBox(height: 6),
                Text(
                  _loading ? 'loading'.tr : _addressText,
                  style: AppTextStyle.bodyMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesCtrl,
                  style: AppTextStyle.inputText,
                  decoration: InputDecoration(
                    hintText: 'driver_notes_hint'.tr,
                    filled: true,
                    fillColor: AppColor.secondBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text('save_address'.tr, style: AppTextStyle.buttonLarge),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
