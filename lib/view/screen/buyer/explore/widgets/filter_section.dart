import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/color.dart';

class FilterSection extends StatelessWidget {
  const FilterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final filters = [
      "All",
      "Stores",
      "Products",
      "Nearby",
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == 0;

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? AppColor.primaryColor
                  : Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppColor.primaryColor,
              ),
            ),
            child: Text(
              filters[index],
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : AppColor.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }
}