import 'package:chat_app/config/String.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../Config/Images.dart';


class WelcomeBody extends StatelessWidget {
  const WelcomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AssetsImage.boyPic),
            SvgPicture.asset(AssetsImage.connetSVG),
            Image.asset(AssetsImage.girlPic),
          ],
        ),
        const SizedBox(height: 30),
        Text(
          WelcomePageString.nowYourAre,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          WelcomePageString.connected,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 30),
        Text(
          WelcomePageString.discription,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge,
        )
      ],
    );
  }
}