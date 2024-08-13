// ignore_for_file: sized_box_for_whitespace

import 'package:chat_app/config/String.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:slide_to_act/slide_to_act.dart';
import '../../../Config/Images.dart';

class WelcomeFooterbutton extends StatelessWidget {
  const WelcomeFooterbutton({super.key});

  @override
  Widget build(BuildContext context) {
    return SlideAction(
      onSubmit: () {
        Get.offAllNamed("/authPage");
        return null;
      },
      sliderButtonIcon: Container(
        width: 25,
        height: 25,
        child: SvgPicture.asset(
          AssetsImage.plugSVG,
          width: 25,
        ),
      ),
      text: WelcomePageString.slideToStart,
      textStyle: Theme.of(context).textTheme.labelLarge,
      submittedIcon: SvgPicture.asset(
        AssetsImage.connetSVG,
        width: 25,
      ),
      innerColor: Theme.of(context).colorScheme.primary,
      outerColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}