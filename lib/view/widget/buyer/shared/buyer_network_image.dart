import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/color.dart';

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
    Key? key,
    required this.url,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image_outlined,
    this.backgroundColor,
    this.fallbackIconSize = 28,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(color: backgroundColor ?? AppColor.secondBackground);
      },
      errorBuilder: (context, error, stack) => Container(
        color: backgroundColor ?? AppColor.secondBackground,
        alignment: Alignment.center,
        child: Icon(
          fallbackIcon,
          color: AppColor.greyLight,
          size: fallbackIconSize,
        ),
      ),
    );
  }
}
