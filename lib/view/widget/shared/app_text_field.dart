import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';

class AppField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final String? helperText;

  const AppField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines=1,
    this.keyboardType,
    this.inputFormatters,
    required this.validator,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyle.inputLabel),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller, maxLines: maxLines,
        keyboardType: keyboardType, inputFormatters: inputFormatters,
        validator: validator, style: AppTextStyle.inputText,
        decoration: InputDecoration(
          hintText: hint, hintStyle: AppTextStyle.inputHint,
          helperText: helperText, helperStyle: AppTextStyle.labelSmall,
          filled: true, fillColor: AppColor.secondBackground,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.greyBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.greyBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColor.primaryColor, width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.error)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColor.error, width: 1.5)),
          errorStyle: AppTextStyle.inputError,
        ),
      ),
    ],
  );
}
