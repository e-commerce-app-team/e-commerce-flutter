import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/color.dart';

class StoreHeader extends StatelessWidget {
  const StoreHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [

        Container(
          height: 170,
          decoration: BoxDecoration(
            color: AppColor.primaryColor.withOpacity(.12),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
        ),

        Positioned(
          top: 16,
          left: 10,
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),

        const Positioned(
          bottom: -40,
          left: 0,
          right: 0,
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.storefront,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }
}