import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String greeting;
  final String storeName;
  final double rating;
  final int reviewCount;
  final VoidCallback onNotificationTap;
  final int notificationCount;

  const DashboardAppBar({
    super.key,
    required this.greeting,
    required this.storeName,
    required this.rating,
    required this.reviewCount,
    required this.onNotificationTap,
    this.notificationCount=0 ,
  });

  @override
  Size get preferredSize => const Size.fromHeight(115);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColor.headerGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.menu_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: AppTextStyle.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            storeName,
                            style: AppTextStyle.heading2.copyWith(color:Colors.white)


                            ,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: onNotificationTap,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(

                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        if (notificationCount > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 19,
                              height: 19,
                              decoration: BoxDecoration(
                                color: const Color(0xffFFD700),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColor.primaryDark,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  notificationCount > 9
                                      ? '9+'
                                      : notificationCount.toString(),
                                  style:
                                    AppTextStyle.statNumberSmall.copyWith(fontSize: 10)
                                  ),
                                ),
                              ),
                            ),

                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: Color(0xffFFD700),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$rating',
                    style: AppTextStyle.statNumber.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    ' · $reviewCount ${'reviews'.tr}',
                    style: AppTextStyle.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
