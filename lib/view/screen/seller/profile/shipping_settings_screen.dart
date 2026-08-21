import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_profile_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';

class ShippingSettingsScreen extends StatelessWidget {
  const ShippingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<SellerProfileController>(
    builder: (ctrl) => Scaffold(
      backgroundColor: AppColor.backgroundScaffold,
      appBar: AppBar(
        backgroundColor: AppColor.cardBackground,
        elevation: 0,
        title: Text('shipping_settings'.tr, style: AppTextStyle.appBarTitle),
        centerTitle: true,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
        children: [
          _IntroCard(),
          const SizedBox(height: 14),
          _Section(
            title: 'طريقة تنفيذ الشحن',
            icon: Icons.route_outlined,
            child: Column(
              children: [
                _ChoiceTile(
                  icon: Icons.storefront_outlined,
                  title: 'الشحن الذاتي',
                  subtitle: 'أنت تحدد التكلفة والموعد وتنفذ التوصيل.',
                  selected: ctrl.shippingMethod == 'self_delivery',
                  onTap: () => ctrl.setShippingMethod('self_delivery'),
                ),
                const SizedBox(height: 8),
                _ChoiceTile(
                  icon: Icons.hub_outlined,
                  title: 'الشحن عن طريق المنصة',
                  subtitle: 'متوفر قريبًا',
                  selected: false,
                  enabled: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Section(
            title: 'طرق التسليم المتاحة',
            icon: Icons.local_shipping_outlined,
            child: Column(
              children: [
                _ToggleTile(
                  icon: Icons.shopping_bag_outlined,
                  title: 'استلام شخصي',
                  subtitle: 'يستخدم موقع المتجر الرئيسي.',
                  value: ctrl.pickupDeliveryEnabled,
                  onChanged: ctrl.setPickupDelivery,
                ),
                _ToggleTile(
                  icon: Icons.local_shipping_outlined,
                  title: 'توصيل عادي',
                  subtitle: 'تحدد تكلفته عند قبول الطلب.',
                  value: ctrl.standardDeliveryEnabled,
                  onChanged: ctrl.setStandardDelivery,
                ),
                _ToggleTile(
                  icon: Icons.bolt_outlined,
                  title: 'توصيل سريع',
                  subtitle: 'تحدد تكلفته عند قبول الطلب.',
                  value: ctrl.expressDeliveryEnabled,
                  onChanged: ctrl.setExpressDelivery,
                ),
                _ToggleTile(
                  icon: Icons.local_offer_outlined,
                  title: 'seller_free_shipping'.tr,
                  subtitle: 'seller_free_shipping_sub'.tr,
                  value: ctrl.freeShippingEnabled,
                  onChanged: (value) {
                    ctrl.freeShippingEnabled = value;
                    ctrl.update();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Section(
            title: 'ملاحظة مهمة',
            icon: Icons.info_outline_rounded,
            child: Text(
              'لن تظهر تكلفة التوصيل العادي أو السريع للمشتري قبل قبول الطلب وتحديد التكلفة من طرفك.',
              style: AppTextStyle.bodyMedium,
            ),
          ),
          const SizedBox(height: 14),
          _Section(
            title: 'موقع المتجر الرئيسي',
            icon: Icons.location_on_outlined,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    ctrl.profile?.latitude != null &&
                            ctrl.profile?.longitude != null &&
                            (ctrl.profile?.detailedAddress ?? '').isNotEmpty
                        ? 'تم تحديد الموقع ويمكن استخدام الاستلام الشخصي.'
                        : 'حدد موقع المتجر ليظهر الاستلام الشخصي بشكل صحيح.',
                    style: AppTextStyle.bodyMedium,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed('/seller/store-location'),
                  child: const Text('تحديد الموقع'),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: ctrl.saveStatusRequest == StatusRequest.loading
                ? null
                : ctrl.saveShipping,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: ctrl.saveStatusRequest == StatusRequest.loading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text('save_settings'.tr, style: AppTextStyle.buttonLarge),
          ),
        ),
      ),
    ),
  );
}

class _IntroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: AppColor.mainGradient,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Row(
      children: [
        const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 30),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            'تحكم بالخيارات التي تظهر للمشتري لكل متجر.',
            style: AppTextStyle.bodyMedium.copyWith(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColor.cardBackground,
      borderRadius: BorderRadius.circular(20),
      boxShadow: AppColor.cardShadow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColor.primaryColor, size: 21),
            const SizedBox(width: 9),
            Text(title, style: AppTextStyle.heading3),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

class _ChoiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;
  const _ChoiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    this.enabled = true,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: enabled ? onTap : null,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: selected ? AppColor.primarySurface : AppColor.backgroundScaffold,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? AppColor.primaryColor : AppColor.greyBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: enabled ? AppColor.primaryColor : AppColor.grey,
            size: 23,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyle.labelLarge),
                const SizedBox(height: 3),
                Text(subtitle, style: AppTextStyle.labelSmall),
              ],
            ),
          ),
          Icon(
            selected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_off_rounded,
            color: enabled ? AppColor.primaryColor : AppColor.greyLight,
          ),
        ],
      ),
    ),
  );
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
    contentPadding: EdgeInsets.zero,
    secondary: Icon(icon, color: value ? AppColor.primaryColor : AppColor.grey),
    title: Text(title, style: AppTextStyle.labelLarge),
    subtitle: Text(subtitle, style: AppTextStyle.labelSmall),
    value: value,
    onChanged: onChanged,
    activeColor: AppColor.primaryColor,
  );
}
