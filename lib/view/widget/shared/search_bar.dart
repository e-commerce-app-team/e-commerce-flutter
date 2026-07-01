import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final VoidCallback? onClear;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        style: AppTextStyle.inputText.copyWith(fontSize: 13),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyle.inputHint.copyWith(
            fontSize: 13,
            color: AppColor.grey.withOpacity(0.7),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColor.grey,
            size: 19,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) => value.text.isNotEmpty
                ? GestureDetector(
              onTap: () {
                controller.clear();
                onClear?.call();
              },
              child: const Icon(
                Icons.close_rounded,
                color: AppColor.grey,
                size: 18,
              ),
            )
                : const SizedBox.shrink(),
          ),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}