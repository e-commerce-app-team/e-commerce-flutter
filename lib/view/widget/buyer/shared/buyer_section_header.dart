import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'gradient_hairline.dart';

/// The recurring three-part header used above every home-screen section:
/// a small gradient-marked eyebrow, a display title, and an optional
/// "see all" action. Repeating this exact rhythm is what gives the page
/// its editorial, catalog-like structure instead of a stack of
/// unrelated widgets.
class BuyerSectionHeader extends StatelessWidget {
  final String title;
  final String? eyebrow;
  final VoidCallback? onSeeAll;
  final String? seeAllLabel;

  const BuyerSectionHeader({
    Key? key,
    required this.title,
    this.eyebrow,
    this.onSeeAll,
    this.seeAllLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Row(
            children: [
              const GradientHairline(width: 16, height: 3),
              const SizedBox(width: 8),
              Text(
                eyebrow!,
                style: AppTextStyle.labelMedium.copyWith(
                  color: AppColor.primaryColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyle.heading2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onSeeAll != null)
              InkWell(
                onTap: onSeeAll,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        seeAllLabel ?? 'see_all'.tr,
                        style: AppTextStyle.labelMedium.copyWith(
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: AppColor.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
