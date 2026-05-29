import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/color.dart';


import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final bool isCircle;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 21,
    this.isCircle = false,
  });

  const ShimmerBox.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        radius = size / 2,
        isCircle = true;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xffEBEBF4),
      highlightColor: const Color(0xffF8F8FF),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            isCircle ? width / 2 : radius,
          ),
        ),
      ),
    );
  }
}
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: List.generate(
                4,
                (_) => Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColor.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerBox(width: 32, height: 32, radius: 10),
                      const Spacer(),
                      const ShimmerBox(width: 80, height: 10),
                      const SizedBox(height: 6),
                      const ShimmerBox(width: 110, height: 22),
                      const SizedBox(height: 6),
                      const ShimmerBox(width: 60, height: 10),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColor.cardShadow,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 120, height: 14),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (i) {
                      final heights = [40.0, 60.0, 30.0, 90.0, 50.0, 120.0, 70.0];
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ShimmerBox(
                            width: double.infinity,
                            height: heights[i],
                            radius: 6,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppColor.cardShadow,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const ShimmerBox(width: 44, height: 44, radius: 12),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            ShimmerBox(width: 100, height: 12),
                            SizedBox(height: 8),
                            ShimmerBox(width: 140, height: 10),
                          ],
                        ),
                      ),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ShimmerBox(width: 70, height: 14),
                          SizedBox(height: 8),
                          ShimmerBox(width: 50, height: 10),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
