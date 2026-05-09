import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/auth/select_account_type_controller.dart';
import 'package:e_commerce/data/datasource/static/account_type_data.dart';
import 'package:lottie/lottie.dart';

class CustomSliderAccount extends GetView<SelectAccountTypeController> {
  const CustomSliderAccount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller.pageController,
      onPageChanged: (val) => controller.onPageChanged(val),
      itemCount: AccountTypeData.data.length,
      itemBuilder: (context, i) =>
          Column(

            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              Lottie.asset(
                AccountTypeData.data[i]['image']!,
           height: Get.width / 1.3,
                fit: BoxFit.fill,
              ),
              const SizedBox(height: 40),
              Text(
                AccountTypeData.data[i]['title']!,
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                AccountTypeData.data[i]['body']!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

  }
