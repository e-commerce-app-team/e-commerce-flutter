import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/constant/color.dart';

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        automaticallyImplyLeading: false,
        title: const Text("الطلبات", style: TextStyle(fontFamily: "Cairo", color: Colors.white)),
      ),
      body: const Center(child: Text("Orders — قيد التطوير")),
    );
  }
}