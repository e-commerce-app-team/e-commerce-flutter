import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/link_api.dart';

/// A network image with one consistent loading placeholder and a graceful
/// fallback icon on failure, so every photo across the buyer UI degrades
/// the same way instead of each card inventing its own placeholder.
class BuyerNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final IconData fallbackIcon;
  final Color? backgroundColor;
  final double fallbackIconSize;

  const BuyerNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image_outlined,
    this.backgroundColor,
    this.fallbackIconSize = 28,
  });

  String? get _resolvedUrl {
    final value = url.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final host = AppLink.server.replaceFirst('/api', '');
    if (value.startsWith('/storage/')) return '$host$value';
    if (value.startsWith('storage/')) return '$host/$value';
    return AppLink.storageUrl(value.replaceFirst(RegExp(r'^/+'), ''));
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolvedUrl;
    if (imageUrl == null) return _fallback();

    return Image.network(
      imageUrl,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(color: backgroundColor ?? AppColor.secondBackground);
      },
      errorBuilder: (context, error, stack) => _fallback(),
    );
  }

  Widget _fallback() => Container(
    color: backgroundColor ?? AppColor.secondBackground,
    alignment: Alignment.center,
    child: Icon(
      fallbackIcon,
      color: AppColor.greyLight,
      size: fallbackIconSize,
    ),
  );
}
