import 'package:e_commerce/controller/onboarding_controller.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/datasource/static/static.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class CustomSliderOnBoarding extends GetView<OnBoardingControllerImp> {
  const CustomSliderOnBoarding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller.pageController,
      onPageChanged: (val) {
        controller.onPageChanged(val);
      },
      itemCount: onBoardingList.length,
      itemBuilder: (context, i) => Column(
        children: [
          const SizedBox(height: 20),


          Transform.translate(
            offset: const Offset(-40, 0),
          child: SizedBox(

            height: Get.height * 0.35,
            width: Get.width * 0.85,
            child: Lottie.asset(
              onBoardingList[i].image!,
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),
),
          const Spacer(),

          Text(
            onBoardingList[i].title!,
            style: Theme.of(context).textTheme.displayLarge
          ),
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              onBoardingList[i].body!,
              textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge
            ),
          ),
         // const SizedBox(height: 10),
        ],
      ),
    );
  }
}