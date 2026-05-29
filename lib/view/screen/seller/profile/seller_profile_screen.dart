import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/constant/color.dart';

class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        automaticallyImplyLeading: false,
        title: const Text("حسابي", style: TextStyle(fontFamily: "Cairo", color: Colors.white)),
      ),
      body: const Center(child: Text("Profile — قيد التطوير")),
    );
  }
}
