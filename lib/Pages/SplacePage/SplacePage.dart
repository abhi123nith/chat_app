import 'package:chat_app/Controller/SplaceController.dart';
import 'package:chat_app/config/Images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class SplacePage extends StatelessWidget {
  const SplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    SplaceController splaceController = Get.put(SplaceController());
    return Scaffold(
      body: Center(
        child: SvgPicture.asset(
          AssetsImage.appIconSVG,
        ),
      ),
    );
  }
}
