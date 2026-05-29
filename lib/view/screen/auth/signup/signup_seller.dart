import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/auth/signup_controoler/signup_seller_controller.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/functions/alert_exitapp.dart';
import 'package:e_commerce/core/functions/valid_input.dart';
import 'package:e_commerce/view/widget/auth/custombuttonauth.dart';
import 'package:e_commerce/view/widget/auth/customtextformauth.dart';
import 'package:e_commerce/data/datasource/static/categories_data.dart';
import '../../../../core/class/handling_dataview.dart';

class SignUpSeller extends StatelessWidget {
  const SignUpSeller({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SignUpSellerControllerImp controller = Get.put(SignUpSellerControllerImp());
    final double screenHeight = Get.height;

    return Scaffold(
      backgroundColor: AppColor.secondBackground,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) return;
          if (controller.currentPage > 0) {
            controller.back();
          } else {
            await alertExitApp();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: screenHeight * 0.35,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColor.mainGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: GetBuilder<SignUpSellerControllerImp>(
                      builder: (contr) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const SizedBox(height: 20),
                          Text(
                            contr.currentPage == 0
                                ? "step1_title".tr
                                : contr.currentPage == 1
                                ? "step2_title".tr
                                : "step3_title".tr,
                            style: Theme.of(context).textTheme.displayLarge!.copyWith(color: Colors.white, fontSize: 26),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            contr.currentPage == 0
                                ? "step1_body".tr
                                : contr.currentPage == 1
                                ? "step2_body".tr
                                : "step3_body".tr,
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: screenHeight * 0.28,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  color: AppColor.backgroundcolor,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                ),
                child: GetBuilder<SignUpSellerControllerImp>(
                  builder: (controllerView) => HandlingDataRequest(
                    statusRequest: controllerView.statusRequest,
                    widget: Form(
                  key: controller.formstate,
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: controller.pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            ListView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 20),
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: CustomTextFormAuth(isNumber: false,
                                        valid: (val) => validInput(val!, 2, 20, "name"),
                                        mycontroller: controller.firstName,
                                        hint_text: "first_name_hint".tr,
                                        iconData: Icons.person_outline,
                                        label_text: "first_name".tr)),
                                    const SizedBox(width: 15),
                                    Expanded(child: CustomTextFormAuth(isNumber: false, valid: (val) => validInput(val!, 2, 20, "name"),
                                        mycontroller: controller.lastName,
                                        hint_text: "last_name_hint".tr,
                                        iconData: Icons.person_outline,
                                        label_text: "last_name".tr)),
                                  ],
                                ),
                                CustomTextFormAuth(
                                    isNumber: false,
                                    valid: (val) => validInput(val!, 5, 40, "email"),
                                    mycontroller: controller.email,
                                    hint_text: "email_hint".tr,
                                    iconData: Icons.email_outlined,
                                    label_text: "email".tr),
                                CustomTextFormAuth(isNumber: true, valid: (val) => validInput(val!, 7, 15, "phone"),
                                    mycontroller: controller.phone,
                                    hint_text: "phone_hint".tr,
                                    iconData: Icons.phone_android_outlined,
                                    label_text: "phone".tr),
                                CustomTextFormAuth(isNumber: false, obscureText: true, valid: (val) => validInput(val!, 6, 30, "password"),
                                    mycontroller: controller.password,
                                    hint_text: "password_hint".tr,
                                    iconData: Icons.lock_outline,
                                    label_text: "password".tr),
                                CustomTextFormAuth(isNumber: false, obscureText: true, valid: (val) {
                                  if (val != controller.password.text) return "password_not_match".tr;
                                  return validInput(val!, 6, 30, "password");
                                }, mycontroller: controller.confirmPassword,
                                    hint_text: "confirm_password_hint".tr,
                                    iconData: Icons.lock_reset_outlined,
                                    label_text: "confirm_password".tr),
                              ],
                            ),

                            ListView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 20),
                              children: [
                                CustomTextFormAuth(
                                    isNumber: false, valid: (val) => validInput(val!, 2, 50, "store_name"),
                                    mycontroller: controller.storeName,
                                    hint_text: "store_name_hint".tr,
                                    iconData: Icons.storefront_outlined,
                                    label_text: "store_name".tr),

                                Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(right: 15, bottom: 8),
                                        child: Text("store_category".tr,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      ),
                                      DropdownButtonFormField<int>(
                                        decoration: InputDecoration(
                                          hintText: "store_category_hint".tr,
                                          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                                          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                                        ),
                                        initialValue: controller.selectedCategoryId,
                                        items: CategoriesStatic.categoriesData.map((category) {
                                          return DropdownMenuItem<int>(
                                            value: category['id'],
                                            child: Text(category['name']),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          controller.setCategory(val!);
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10),
                                Text("account_type".tr, style: Theme.of(context).textTheme.bodyLarge),
                                const SizedBox(height: 10),
                                GetBuilder<SignUpSellerControllerImp>(
                                  builder: (contr) => RadioGroup<String>(
                                    groupValue: contr.accountType,
                                    onChanged: (String? value) {
                                      if (value != null) {
                                        contr.changeAccountType(value);
                                      }
                                    },
                                    child: Column(
                                      children: [
                                      RadioListTile<String>(
                                        title: Text("vendor".tr, style: Theme.of(context).textTheme.bodyMedium),
                                        activeColor: AppColor.primaryColor,
                                        value: 'vendor',
                                      ),
                                      RadioListTile<String>(
                                        title: Text("wholesale".tr, style: Theme.of(context).textTheme.bodyMedium),
                                        activeColor: AppColor.primaryColor,
                                        value: 'wholesale',
                                      ),
                                    ],
                                  ),
                                ),
                                )
                              ],
                            ),
                            GetBuilder<SignUpSellerControllerImp>(
                              builder: (contr) => ListView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 20),
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.image, color: AppColor.primaryColor),
                                    title: Text("upload_logo".tr),
                                    trailing: contr.logoImage != null ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.upload_file),
                                    onTap: () => contr.pickDocument('logo'),
                                  ),
                                  const Divider(),
                                  ListTile(
                                    leading: const Icon(Icons.badge_outlined, color: AppColor.primaryColor),
                                    title: Text("upload_id".tr),
                                    trailing: contr.idImage != null ? const Icon(Icons.check_circle,
                                        color: Colors.green) : const Icon(Icons.upload_file),
                                    onTap: () => contr.pickDocument('id'),
                                  ),
                                  const Divider(),

                                  if (contr.accountType == 'wholesale') ...[
                                    const SizedBox(height: 20),
                                    CustomTextFormAuth(isNumber: true, valid: (val) => validInput(val!, 5, 20, "commercial_registe"),
                                        mycontroller: controller.crNumber,
                                        hint_text: "cr_number_hint".tr,
                                        iconData: Icons.numbers_outlined,
                                        label_text: "cr_number".tr),
                                    CustomTextFormAuth(isNumber: true, valid: (val) => validInput(val!, 11, 13, "tax_number"),
                                        mycontroller: controller.vatNumber,
                                        hint_text: "vat_number_hint".tr,
                                        iconData: Icons.receipt_long_outlined,
                                        label_text: "vat_number".tr),
                                    ListTile(
                                      leading: const Icon(Icons.description_outlined, color: AppColor.primaryColor),
                                      title: Text("upload_cr".tr),
                                      trailing: contr.crImage != null ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.upload_file),
                                      onTap: () => contr.pickDocument('cr'),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      GetBuilder<SignUpSellerControllerImp>(
                        builder: (contr) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                          child: CustomButtomAuth(
                            text: contr.currentPage == 2 ? "submit_account".tr : "next_step".tr,
                            onPressed: () => contr.next(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}