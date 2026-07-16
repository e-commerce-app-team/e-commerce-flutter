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
    extends State<BranchLocationPickerScreen> with TickerProviderStateMixin {

  late LatLng _selectedPoint;
  bool _mapReady    = false;
  bool _isLocating  = false;
  bool _isDragging  = false;
  String _currentAddress = 'جاري تحديد الموقع...';

  final MapController        _mapController    = MapController();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController   _pinAnim;
  late Animation<double>     _pinLift;
  late Animation<double>     _shadowScale;

  static const LatLng _damascusCenter = LatLng(33.5138, 36.2765);

  @override
  void initState() {
    super.initState();

    _selectedPoint = (widget.initialLat != null && widget.initialLng != null)
        ? LatLng(widget.initialLat!, widget.initialLng!)
        : _damascusCenter;

    _pinAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _pinLift = Tween<double>(begin: 0, end: -20)
        .animate(CurvedAnimation(parent: _pinAnim, curve: Curves.easeOut));
    _shadowScale = Tween<double>(begin: 1, end: 0.5)
        .animate(CurvedAnimation(parent: _pinAnim, curve: Curves.easeOut));

    if (widget.initialLat == null) {
      _goToMyLocation();
    } else {
      _getAddressFromLatLng(_selectedPoint);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    _pinAnim.dispose();
    super.dispose();
  }

  void _onMapMoveStart() {
    setState(() => _isDragging = true);
    _pinAnim.forward();
  }

  void _onMapMoveEnd(LatLng newCenter) {
    setState(() {
      _isDragging    = false;
      _selectedPoint = newCenter;
    });
    _pinAnim.reverse();
    _getAddressFromLatLng(newCenter);
  }

  Future<void> _goToMyLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('تنبيه', 'الرجاء تفعيل الـ GPS في هاتفك');
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return;
      }
      if (perm == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition();
      final myLatLng = LatLng(pos.latitude, pos.longitude);

      if (_mapReady) _mapController.move(myLatLng, 15.0);
      setState(() => _selectedPoint = myLatLng);
      _getAddressFromLatLng(myLatLng);
    } catch (_) {
      Get.snackbar('خطأ', 'لم نتمكن من تحديد موقعك الحالي');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _searchPlace(String query) async {
    if (query.trim().isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      final locations = await geo.locationFromAddress(query);
      if (locations.isNotEmpty) {
        final point = LatLng(locations.first.latitude, locations.first.longitude);
        _mapController.move(point, 15.0);
        setState(() => _selectedPoint = point);
        _getAddressFromLatLng(point);
      }
    } catch (_) {
      Get.snackbar('عذراً', 'لم نتمكن من العثور على المكان');
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(
          position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final addr = [p.street, p.subLocality, p.locality, p.country]
            .where((e) => e != null && e.isNotEmpty)
            .join(', ');
        if (mounted) setState(() => _currentAddress = addr.isNotEmpty ? addr : 'موقع محدد');
      }
    } catch (_) {
      if (mounted) setState(() => _currentAddress = 'موقع محدد');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColor.secondBackground,
    body: Stack(children: [

      // ── Map ──────────────────────────────────────────────────────────────
      FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _selectedPoint,
          initialZoom:   15.0,
          onMapReady:    () => setState(() => _mapReady = true),
          onPositionChanged: (pos, hasGesture) {
            if (hasGesture && pos.center != null) {
              if (!_isDragging) _onMapMoveStart();
              setState(() => _selectedPoint = pos.center!);
            }
          },
          onPointerUp: (_, __) {
            if (_isDragging) _onMapMoveEnd(_selectedPoint);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.e_commerce',
          ),
        ],
      ),

      // ── Animated center pin ───────────────────────────────────────────────
      IgnorePointer(
        child: Center(
          child: AnimatedBuilder(
            animation: _pinAnim,
            builder: (_, __) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pin body
                Transform.translate(
                  offset: Offset(0, _pinLift.value),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primaryColor.withOpacity(0.45),
                          blurRadius: _isDragging ? 20 : 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.location_on_rounded,
                        color: Colors.white, size: 24),
                  ),
                ),
                // Pin stem
                Transform.translate(
                  offset: Offset(0, _pinLift.value),
                  child: Container(
                    width: 2.5, height: 14,
                    color: AppColor.primaryColor,
                  ),
                ),
                // Shadow dot
                Transform.scale(
                  scale: _shadowScale.value,
                  child: Container(
                    width: 10, height: 5,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ── Top bar ───────────────────────────────────────────────────────────
      SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(children: [
              // Back button
              _CircleBtn(
                onTap: Get.back,
                child: const Icon(Icons.arrow_back_ios_rounded,
                    size: 18, color: AppColor.black),
              ),
              const SizedBox(width: 10),
              // Search bar
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppColor.cardShadow,
                  ),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _searchPlace,
                    style: AppTextStyle.labelMedium.copyWith(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن منطقة أو شارع...',
                      hintStyle: AppTextStyle.labelMedium
                          .copyWith(fontSize: 13, color: AppColor.greyLight),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColor.primaryColor, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border:      InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
            ]),
          ),

          const Spacer(),

          // ── My location FAB ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 14, bottom: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: _CircleBtn(
                size: 48,
                onTap: _goToMyLocation,
                child: _isLocating
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                            color: AppColor.primaryColor, strokeWidth: 2.5))
                    : const Icon(Icons.my_location_rounded,
                        color: AppColor.primaryColor, size: 22),
              ),
            ),
          ),

          // ── Bottom info & confirm panel ──────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(children: [
              // Address row
              Row(children: [
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
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_currentAddress,
                        style: AppTextStyle.labelMedium.copyWith(
                            fontSize: 12, fontWeight: FontWeight.w700),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      '${_selectedPoint.latitude.toStringAsFixed(5)}, '
                      '${_selectedPoint.longitude.toStringAsFixed(5)}',
                      style: AppTextStyle.labelSmall.copyWith(
                          fontSize: 10, color: AppColor.greyLight),
                    ),
                  ]),
                ),
              ]),
              const SizedBox(height: 12),
              // Confirm button
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton.icon(
                  onPressed: _mapReady
                      ? () => Get.back(result: _selectedPoint)
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

// ─── Circle icon button helper ────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Widget       child;
  final double       size;
  const _CircleBtn({required this.onTap, required this.child, this.size = 46});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: AppColor.cardShadow,
      ),
      child: child,
    ),
  );
}