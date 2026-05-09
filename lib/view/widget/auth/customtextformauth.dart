import 'package:e_commerce/core/constant/color.dart';
import 'package:flutter/material.dart';

class CustomTextFormAuth extends StatelessWidget {
  final String hint_text;
  final String label_text;
  final IconData iconData;
  final TextEditingController? mycontroller;
  final String? Function(String?) valid;
  final bool isNumber;
  final bool? obscureText;
  final void Function()? onTapIcon;

  const CustomTextFormAuth(
      {Key? key,
        this.obscureText,
        this.onTapIcon,
        required this.hint_text,
        required this.label_text,
        required this.iconData,
        required this.mycontroller,
        required this.valid,
        required this.isNumber})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 15, bottom: 8),
            child: Text(
              label_text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          TextFormField(
            keyboardType: isNumber
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            validator: valid,
            controller: mycontroller,
            obscureText: obscureText == false || obscureText == null ? false : true,
            decoration: InputDecoration(
              hintText: hint_text,
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              suffixIcon: InkWell(onTap: onTapIcon, child: Icon(iconData,color:AppColor.primaryColor,)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              // filled: true,
              // fillColor: Colors.grey[100],
            ),
          ),
        ],
      ),
    );
  }
}