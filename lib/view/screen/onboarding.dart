import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/onboarding_controller.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/view/widget/onboarding/custombutton.dart';
import 'package:e_commerce/view/widget/onboarding/customslider.dart';
import 'package:e_commerce/view/widget/onboarding/dotcontroller.dart';

import '../../core/class/wave_curve_clipper.dart';

class OnBoarding extends StatelessWidget {
  const OnBoarding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(OnBoardingControllerImp());
    final double screenHeight = Get.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ClipPath(
            clipper: DiagonalCurveClipper(),
            child: Container(
              height: screenHeight * 0.65,
              color: AppColor.primaryColor.withOpacity(0.2),
            ),
          ),

          ClipPath(
            clipper: DiagonalCurveClipper(),
            child: Container(
              height: screenHeight * 0.62,
              decoration: const BoxDecoration(
                gradient: AppColor.mainGradient,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Expanded(

                  flex: 5,
                  child: CustomSliderOnBoarding(),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      CustomDotControllerOnBoarding(),
                      SizedBox(height: 40),
                      CustomButtonOnBoarding(),
                      SizedBox(height: 30),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}