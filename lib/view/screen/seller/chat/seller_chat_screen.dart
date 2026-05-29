import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/constant/color.dart';

class SellerChatScreen extends StatelessWidget {
  const SellerChatScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        automaticallyImplyLeading: false,
        title: const Text("الرسائل", style: TextStyle(fontFamily: "Cairo", color: Colors.white)),
      ),
      body: const Center(child: Text("Chat — قيد التطوير")),
    );
  }
}