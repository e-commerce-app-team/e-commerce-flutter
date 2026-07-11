import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/color.dart';

/// The signature accent of the buyer UI: a slim brand-gradient line.
///
/// It shows up in a few deliberate places (section eyebrows, the active
/// category indicator, banner corner marks) so it reads as one coherent
/// identity thread running through the screen instead of a one-off effect.
class GradientHairline extends StatelessWidget {
  final double width;
  final double height;

  const GradientHairline({
    Key? key,
    this.width = 22,
    this.height = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: AppColor.mainGradient,
        borderRadius: BorderRadius.circular(height),
      ),
    );
  }
}
