import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      "Electronics",
      "Fashion",
      "Beauty",
      "Sports",
      "Furniture",
    ];

    return SizedBox(
      height: 35,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Chip(
            label: Text(
              categories[index],
              style: const TextStyle(fontSize: 11),
            ),
          );
        },
      ),
    );
  }
}