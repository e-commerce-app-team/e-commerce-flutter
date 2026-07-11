import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/view/screen/buyer/store_details/buyer_store_details_screen.dart';

class TopStoresSection extends StatelessWidget {
  const TopStoresSection({super.key});

  @override
  Widget build(BuildContext context) {
    final stores = [
      "Nike",
      "Apple",
      "Zara",
      "IKEA",
      "Adidas",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Top Stores",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 95,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: stores.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Get.to(() => const BuyerStoreDetailsScreen());
                },
                child: Container(
                  width: 75,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                        AppColor.primaryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.storefront,
                          size: 18,
                          color: AppColor.primaryColor,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        stores[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}