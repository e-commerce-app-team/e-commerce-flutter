import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/color.dart';

class CustomAccountTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;
  final bool isSelected;
  final void Function()? onTap;

  const CustomAccountTypeCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.isSelected,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primaryColor.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? AppColor.primaryColor : AppColor.grey.withOpacity(0.2),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColor.primaryColor.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColor.primaryColor : AppColor.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                iconData,
                size: 30,
                color: isSelected ? Colors.white : AppColor.grey,
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColor.primaryColor : AppColor.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColor.grey.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),


            if (isSelected) ...[
              const SizedBox(width: 10),
              const Icon(
                Icons.check_circle,
                color: AppColor.primaryColor,
                size: 28,
              ),
            ]
          ],
        ),
      ),
    );
  }
}