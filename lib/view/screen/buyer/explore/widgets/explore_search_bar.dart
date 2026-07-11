import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/color.dart';

class ExploreSearchBar extends StatelessWidget {
  const ExploreSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Search products or stores...",
          prefixIcon: Icon(Icons.search),
          suffixIcon: Icon(Icons.tune),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}