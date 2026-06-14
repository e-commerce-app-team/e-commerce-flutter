import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/color.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {"icon": Icons.phone_android, "name": "Electronics"},
      {"icon": Icons.checkroom, "name": "Fashion"},
      {"icon": Icons.chair, "name": "Furniture"},
      {"icon": Icons.sports_soccer, "name": "Sports"},
      {"icon": Icons.face, "name": "Beauty"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Categories",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 85,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) =>
            const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      categories[index]["icon"] as IconData,
                      color: AppColor.primaryColor,
                      size: 22,
                    ),
                  ),

                  const SizedBox(height: 6),

                  SizedBox(
                    width: 65,
                    child: Text(
                      categories[index]["name"] as String,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}