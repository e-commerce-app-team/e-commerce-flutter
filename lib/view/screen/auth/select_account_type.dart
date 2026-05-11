import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/controller/auth/select_account_type_controller.dart';
import 'package:e_commerce/view/widget/auth/customtexttitleauth.dart';
import 'package:e_commerce/view/widget/auth/custombuttonauth.dart';
import 'package:e_commerce/view/widget/auth/custom_account_type_card.dart';

import '../../../core/class/wave_curve_clipper.dart';
// import '../../../core/localization/changelocal.dart';

class SelectAccountType extends StatelessWidget {
  const SelectAccountType({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(SelectAccountTypeControllerImp());
    final double screenHeight = Get.height;


    return Scaffold(
      backgroundColor: AppColor.backgroundcolor,
      body: GetBuilder<SelectAccountTypeControllerImp>(
        builder: (controller) =>  Stack(
          children: [
            ClipPath(
              clipper: DiagonalCurveClipper(),
              child: Container(
                height: screenHeight * 0.50,
                color: AppColor.primaryColor.withOpacity(0.2),
              ),
            ),

            ClipPath(
              clipper: DiagonalCurveClipper(),
              child: Container(
                height: screenHeight * 0.45,
                decoration: const BoxDecoration(
                  gradient: AppColor.mainGradient,
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  CustomTextTitleAuth(text: "SelectAccountType".tr),
                  const SizedBox(height: 20),
                  Text(

                    "bodySelectAccountType".tr,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,fontSize: 16
                    ),
                  ),

                  const SizedBox(height: 180),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        CustomAccountTypeCard(
                          title: "buyer".tr,
                          subtitle: "buyerDesc".tr,
                          iconData: Icons.shopping_bag_outlined,
                          isSelected: controller.selectedType == "buyer",
                          onTap: () => controller.chooseUserType("buyer"),
                        ),

                        const SizedBox(height: 30),

                        CustomAccountTypeCard(
                          title: "seller".tr,
                          subtitle: "sellerDesc".tr,
                          iconData: Icons.storefront_outlined,
                          isSelected: controller.selectedType == "seller",
                          onTap: () => controller.chooseUserType("seller"),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: CustomButtomAuth(
                      text: "continue".tr,
                      onPressed: () {
                        controller.goToNext();
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

