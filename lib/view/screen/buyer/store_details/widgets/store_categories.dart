import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/color.dart';

class StoreCategories extends StatelessWidget {
  const StoreCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      "All",
      "Electronics",
      "Accessories",
      "Gaming",
      "Smart Home",
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == 0;

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? AppColor.primaryColor
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColor.primaryColor,
              ),
            ),
            child: Text(
              categories[index],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : AppColor.primaryColor,
              ),
            ),
          );
        },
      ),
    );
  }
}