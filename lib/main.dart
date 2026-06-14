import 'package:e_commerce/view/screen/buyer/BuyerMainScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/view/screen/buyer/home/buyer_home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: BuyerMainScreen(),
    );
  }
}