import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/inventory_models.dart';

class ProductGridCard extends StatefulWidget {
final ProductModel product;
final int index;
final VoidCallback onEdit;
final VoidCallback onToggleStatus;
final VoidCallback onDelete;
const ProductGridCard({
super.key, required this.product, required this.index,
required this.onEdit, required this.onToggleStatus, required this.onDelete,
});

@override
State<ProductGridCard> createState() => _ProductGridCardState();
}

class _ProductGridCardState extends State<ProductGridCard>
with SingleTickerProviderStateMixin {
late AnimationController _ctrl;
late Animation<double> _fade;
late Animation<Offset> _slide;

@override
void initState() {
super.initState();
_ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
_fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
_slide = Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero)
    .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
Future.delayed(Duration(milliseconds: widget.index * 55), () {
if (mounted) _ctrl.forward();
});
}

@override
void dispose() {
_ctrl.dispose();
super.dispose();
}

String _fmt(int v) => v >= 1000 ? '${v ~/ 1000}k ${'currency'.tr}' : '$v ${'currency'.tr}';

void _showOptions() {
Get.bottomSheet(
_OptionsSheet(product: widget.product, onEdit: widget.onEdit,
onToggleStatus: widget.onToggleStatus, onDelete: widget.onDelete),
backgroundColor: Colors.transparent,
isScrollControlled: true,
);
}

@override
Widget build(BuildContext context) {
final p = widget.product;
final borderColor = p.isOutOfStock
? AppColor.error.withOpacity(0.6)
    : p.isLowStock
? AppColor.warning.withOpacity(0.5)
    : AppColor.greyBorder;

return FadeTransition(
opacity: _fade,
child: SlideTransition(
position: _slide,
child: Container(
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(14),
boxShadow: AppColor.cardShadow,
border: Border.all(color: borderColor, width: 1),
),
child: Material(
color: Colors.transparent,
borderRadius: BorderRadius.circular(14),
clipBehavior: Clip.antiAlias,
child: InkWell(
onTap: widget.onEdit,
onLongPress: _showOptions,
child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Expanded(
child: Stack(fit: StackFit.expand, children: [
Container(
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
AppColor.primarySurface,
AppColor.primaryColor.withOpacity(0.06),
],
),
),
child: Icon(
Icons.inventory_2_outlined,
size: 34,
color: AppColor.primaryColor.withOpacity(0.3),
),
),
Positioned(top: 8, right: 8, child: _StatusBadge(status: p.status)),
if (p.hasVariants)
Positioned(
top: 8, left: 8,
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
decoration: BoxDecoration(
color: AppColor.statOrders.withOpacity(0.1),
borderRadius: BorderRadius.circular(6),
border: Border.all(color: AppColor.statOrders.withOpacity(0.3)),
),
child: const Icon(Icons.color_lens_outlined, size: 11, color: AppColor.statOrders),
),
),
if (p.hasDiscount)
Positioned(
bottom: p.isLowStock || p.isOutOfStock ? 24 : 0,
left: 0,
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
decoration: const BoxDecoration(
color: AppColor.error,
borderRadius: BorderRadius.only(
topRight: Radius.circular(8),
bottomRight: Radius.circular(0),
),
),
child: Text('-${p.discountPercent}%', style: AppTextStyle.badge),
),
),
if (p.isLowStock || p.isOutOfStock)
Positioned(
bottom: 0, left: 0, right: 0,
child: Container(
padding: const EdgeInsets.symmetric(vertical: 3),
color: p.isOutOfStock ? AppColor.error : AppColor.warning,
child: Text(
p.isOutOfStock
? 'out_of_stock_short'.tr
    : '${'stock_low'.tr}: ${p.stock}',
style: AppTextStyle.badge.copyWith(fontSize: 9),
textAlign: TextAlign.center,
),
),
),
]),
),
Padding(
padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Text(p.name,
style: AppTextStyle.labelLarge.copyWith(fontSize: 12),
maxLines: 1, overflow: TextOverflow.ellipsis),
const SizedBox(height: 2),
Text(p.sku,
style: AppTextStyle.labelSmall.copyWith(
fontFamily: 'PlayfairDisplay', fontSize: 9)),
const SizedBox(height: 6),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
if (p.hasDiscount)
Text(_fmt(p.price),
style: AppTextStyle.labelSmall.copyWith(
decoration: TextDecoration.lineThrough,
fontSize: 9,
color: AppColor.greyLight)),
Text(_fmt(p.salePrice ?? p.price),
style: AppTextStyle.price.copyWith(fontSize: 13)),
]),
Container(
padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
decoration: BoxDecoration(
color: p.isLowStock
? AppColor.warningLight
    : p.isOutOfStock
? AppColor.errorLight
    : AppColor.secondBackground,
borderRadius: BorderRadius.circular(8),
border: Border.all(
color: p.isLowStock
? AppColor.warning.withOpacity(0.4)
    : AppColor.greyBorder,
),
),
child: Text(
'${p.stock}',
style: AppTextStyle.labelSmall.copyWith(
color: p.isLowStock
? AppColor.warning
    : p.isOutOfStock
? AppColor.error
    : AppColor.grey,
fontWeight: FontWeight.w700,
fontSize: 10,
),
),
),
],
),
]),
),
]),
),
),
),
),
);
}
}

class ProductListCard extends StatelessWidget {
final ProductModel product;
final int index;
final VoidCallback onEdit;
final VoidCallback onToggleStatus;
final VoidCallback onDelete;
const ProductListCard({
super.key, required this.product, required this.index,
required this.onEdit, required this.onToggleStatus, required this.onDelete,
});

String _fmt(int v) => v >= 1000 ? '${v ~/ 1000}k ${'currency'.tr}' : '$v ${'currency'.tr}';

@override
Widget build(BuildContext context) {
final p = product;
return Dismissible(
key: ValueKey(p.id),
direction: DismissDirection.endToStart,
background: Container(
alignment: Alignment.centerRight,
padding: const EdgeInsets.symmetric(horizontal: 20),
margin: const EdgeInsets.only(bottom: 10),
decoration: BoxDecoration(
color: AppColor.error,
borderRadius: BorderRadius.circular(14),
),
child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
),
confirmDismiss: (_) => Get.dialog<bool>(
AlertDialog(
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
title: Text('delete_product'.tr, style: AppTextStyle.heading3),
content: Text(
'${'delete_confirm_msg'.tr} "${p.name}"؟',
style: AppTextStyle.bodyMedium,
),
actions: [
TextButton(
onPressed: () => Get.back(result: false),
child: Text('cancel'.tr, style: TextStyle(color: AppColor.grey)),
),
ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: AppColor.error, elevation: 0,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
),
onPressed: () => Get.back(result: true),
child: Text('delete'.tr, style: AppTextStyle.buttonSmall),
),
],
),
),
onDismissed: (_) => onDelete(),
child: Container(
margin: const EdgeInsets.only(bottom: 10),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(14),
boxShadow: AppColor.cardShadow,
border: Border.all(
color: p.isOutOfStock
? AppColor.error.withOpacity(0.25)
    : p.isLowStock
? AppColor.warning.withOpacity(0.25)
    : AppColor.greyBorder,
width: 0.8,
),
),
child: Material(
color: Colors.transparent,
borderRadius: BorderRadius.circular(14),
clipBehavior: Clip.antiAlias,
child: InkWell(
onTap: onEdit,
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
child: Row(children: [
Container(
width: 52, height: 52,
decoration: BoxDecoration(
gradient: LinearGradient(colors: [
AppColor.primarySurface,
AppColor.primaryColor.withOpacity(0.06),
]),
borderRadius: BorderRadius.circular(12),
),
child: Icon(
Icons.inventory_2_outlined,
size: 22,
color: AppColor.primaryColor.withOpacity(0.45),
),
),
const SizedBox(width: 12),
Expanded(
child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Row(children: [
Expanded(
child: Text(p.name,
style: AppTextStyle.labelLarge.copyWith(fontSize: 13),
maxLines: 1, overflow: TextOverflow.ellipsis),
),
if (p.hasVariants)
Container(
margin: const EdgeInsets.only(right: 4),
padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
decoration: BoxDecoration(
color: AppColor.statOrders.withOpacity(0.1),
borderRadius: BorderRadius.circular(5),
),
child: const Icon(Icons.color_lens_outlined, size: 10, color: AppColor.statOrders),
),
]),
const SizedBox(height: 3),
Row(children: [
Text('${p.category} · ',
style: AppTextStyle.labelSmall.copyWith(fontSize: 10)),
Text(p.sku,
style: AppTextStyle.labelSmall.copyWith(
fontFamily: 'PlayfairDisplay', fontSize: 10)),
]),
]),
),
Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
Text(_fmt(p.salePrice ?? p.price),
style: AppTextStyle.price.copyWith(fontSize: 13)),
const SizedBox(height: 4),
Row(children: [
_StockChip(product: p),
const SizedBox(width: 5),
_StatusBadge(status: p.status, small: true),
]),
]),
]),
),
),
),
),
);
}
}

class _StatusBadge extends StatelessWidget {
final String status;
final bool small;
const _StatusBadge({required this.status, this.small = false});

static const _cfg = <String, (Color, String, Color)>{
'active': (Color(0xffE8F8F0), 'product_active', Color(0xff1B5E20)),
'draft':  (Color(0xffF5F5F5), 'product_draft',  Color(0xff757575)),
'hidden': (Color(0xffFFF8E1), 'product_hidden',  Color(0xffF39C12)),
};

@override
Widget build(BuildContext context) {
final c = _cfg[status] ?? _cfg['draft']!;
return Container(
padding: EdgeInsets.symmetric(horizontal: small ? 5 : 7, vertical: small ? 2 : 3),
decoration: BoxDecoration(color: c.$1, borderRadius: BorderRadius.circular(6)),
child: Text(c.$2.tr,
style: AppTextStyle.badge.copyWith(color: c.$3, fontSize: small ? 8 : 9)),
);
}
}

class _StockChip extends StatelessWidget {
final ProductModel product;
const _StockChip({required this.product});

@override
Widget build(BuildContext context) {
Color bg, text;
String label;
if (product.isOutOfStock) {
bg = AppColor.errorLight; text = AppColor.errorDark; label = 'out_of_stock_short'.tr;
} else if (product.isLowStock) {
bg = AppColor.warningLight; text = AppColor.warningDark; label = '${product.stock}';
} else {
bg = AppColor.successLight; text = AppColor.successDark; label = '${product.stock}';
}
return Container(
padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
child: Text(label, style: AppTextStyle.badge.copyWith(color: text, fontSize: 9)),
);
}
}

class _OptionsSheet extends StatelessWidget {
final ProductModel product;
final VoidCallback onEdit, onToggleStatus, onDelete;
const _OptionsSheet({
required this.product, required this.onEdit,
required this.onToggleStatus, required this.onDelete,
});

@override
Widget build(BuildContext context) => Container(
padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
decoration: const BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
),
child: Column(mainAxisSize: MainAxisSize.min, children: [
Container(width: 40, height: 4,
decoration: BoxDecoration(color: AppColor.greyBorder, borderRadius: BorderRadius.circular(2))),
const SizedBox(height: 14),
Text(product.name, style: AppTextStyle.heading3, textAlign: TextAlign.center),
const SizedBox(height: 14),
_OptionRow(icon: Icons.edit_outlined, label: 'edit_product'.tr, color: AppColor.primaryColor,
onTap: () { Get.back(); onEdit(); }),
_OptionRow(
icon: product.status == 'active' ? Icons.visibility_off_outlined : Icons.visibility_outlined,
label: product.status == 'active' ? 'hide_product'.tr : 'show_product'.tr,
color: AppColor.warning,
onTap: () { Get.back(); onToggleStatus(); },
),
_OptionRow(icon: Icons.delete_outline_rounded, label: 'delete_product'.tr, color: AppColor.error,
onTap: () { Get.back(); onDelete(); }),
]),
);
}

class _OptionRow extends StatelessWidget {
final IconData icon; final String label; final Color color; final VoidCallback onTap;
const _OptionRow({required this.icon, required this.label, required this.color, required this.onTap});

@override
Widget build(BuildContext context) => ListTile(
contentPadding: EdgeInsets.zero,
leading: Container(
width: 38, height: 38,
decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
child: Icon(icon, color: color, size: 19),
),
title: Text(label, style: AppTextStyle.labelLarge),
trailing: Icon(Icons.chevron_right_rounded, color: AppColor.greyLight),
onTap: onTap,
);
}