import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;

import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';

class BranchLocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const BranchLocationPickerScreen({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<BranchLocationPickerScreen> createState() =>
      _BranchLocationPickerScreenState();
}

class _BranchLocationPickerScreenState
    extends State<BranchLocationPickerScreen> {
  late LatLng _currentCenter;
  bool        _mapReady = false;
  bool        _isLocating = false;

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  static const LatLng _damascusCenter = LatLng(33.5138, 36.2765);

  @override
  void initState() {
    super.initState();
    _currentCenter = widget.initialLat != null && widget.initialLng != null
        ? LatLng(widget.initialLat!, widget.initialLng!)
        : _damascusCenter;

    if (widget.initialLat == null && widget.initialLng == null) {
      _goToMyLocation();
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _goToMyLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar("تنبيه", "الرجاء تفعيل الـ GPS في هاتفك");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      Position pos = await Geolocator.getCurrentPosition();
      final myLatLng = LatLng(pos.latitude, pos.longitude);

      _mapController.move(myLatLng, 15.0);
      setState(() => _currentCenter = myLatLng);

    } catch (e) {
      Get.snackbar("خطأ", "لم نتمكن من تحديد موقعك الحالي");
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _searchPlace(String query) async {
    if (query.trim().isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      List<geo.Location> locations = await geo.locationFromAddress(query);
      if (locations.isNotEmpty) {
        final searchLatLng = LatLng(locations.first.latitude, locations.first.longitude);
        _mapController.move(searchLatLng, 15.0);
        setState(() => _currentCenter = searchLatLng);
      }
    } catch (e) {
      Get.snackbar("عذراً", "لم نتمكن من العثور على المكان، جرب اسماً آخر");
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColor.secondBackground,
    body: Stack(children: [
      FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentCenter,
          initialZoom: 15.0,
          onPositionChanged: (position, hasGesture) {
            if (hasGesture) {
              setState(() => _currentCenter = position.center);
            }
          },
          onMapReady: () => setState(() => _mapReady = true),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.e_commerce',
          ),
        ],
      ),

      // 2. الدبوس في المنتصف
      const Center(child: _CenterMarker()),

      SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              GestureDetector(
                onTap: Get.back,
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppColor.cardShadow,
                  ),
                  child: const Icon(Icons.arrow_back_ios_rounded,
                      size: 20, color: AppColor.black),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppColor.cardShadow,
                  ),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _searchPlace,
                    decoration: InputDecoration(
                      hintText: "ابحث عن منطقة، شارع...",
                      hintStyle: AppTextStyle.labelMedium.copyWith(fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColor.primaryColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ]),
          ),

          const Spacer(),

          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 16),
              child: FloatingActionButton(
                heroTag: "my_location_btn",
                backgroundColor: Colors.white,
                onPressed: _goToMyLocation,
                child: _isLocating
                    ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(color: AppColor.primaryColor, strokeWidth: 3),
                )
                    : const Icon(Icons.my_location_rounded, color: AppColor.primaryColor),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppColor.cardShadow,
                ),
                child: Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColor.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.pin_drop_rounded,
                        size: 18, color: AppColor.primaryColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('branch_selected_location'.tr,
                              style: AppTextStyle.labelSmall
                                  .copyWith(fontSize: 10)),
                          Text(
                            '${_currentCenter.latitude.toStringAsFixed(5)}'
                                ', ${_currentCenter.longitude.toStringAsFixed(5)}',
                            style: AppTextStyle.orderNumber
                                .copyWith(fontSize: 12),
                          ),
                        ]),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton.icon(
                  onPressed: _mapReady
                      ? () => Get.back(result: _currentCenter)
                      : null,
                  icon: const Icon(Icons.check_rounded,
                      size: 20, color: Colors.white),
                  label: Text('branch_confirm_location'.tr,
                      style: AppTextStyle.buttonMedium),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    ]),
  );
}

class _CenterMarker extends StatelessWidget {
  const _CenterMarker();

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppColor.primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.location_on_rounded,
            color: Colors.white, size: 24),
      ),
      Container(
        width: 2, height: 16,
        color: AppColor.primaryColor,
      ),
      Container(
        width: 8, height: 8,
        decoration: BoxDecoration(
          color: AppColor.primaryColor.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
      ),
    ],
  );
}