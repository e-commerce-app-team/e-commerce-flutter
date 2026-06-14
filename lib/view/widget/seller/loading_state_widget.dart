import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/color.dart';

class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: AppColor.primaryColor,
        strokeWidth: 2.5,
      ),
    );
  }
}
