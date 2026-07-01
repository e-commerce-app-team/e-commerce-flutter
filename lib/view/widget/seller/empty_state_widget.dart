import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/color.dart';

class EmptyStateWidget extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColor.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.confirmation_number_outlined,
                  size: 42, color: AppColor.primaryColor),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColor.greyText, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
