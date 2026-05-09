import 'package:e_commerce/core/constant/imgaeasset.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:e_commerce/core/class/status_request.dart';

class HandlingDataView extends StatelessWidget {
  final StatusRequest statusRequest;
  final Widget widget;

  const HandlingDataView({Key? key, required this.statusRequest, required this.widget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      if (statusRequest == StatusRequest.loading) {
      return Center(child: Lottie.asset(AppImageAsset.loading));
    }
    else if (statusRequest == StatusRequest.offlinefailure) {
      return Center(child: Lottie.asset(AppImageAsset.offline));
    }
    else if (statusRequest == StatusRequest.serverfailure) {
      return Center(child: Lottie.asset(AppImageAsset.serverError));
    }
    else {
      return widget;
    }
  }
}