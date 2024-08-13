// ignore_for_file: deprecated_member_use

import 'package:chat_app/config/String.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../Config/Images.dart';


class WelcomeHeading extends StatelessWidget {
  const WelcomeHeading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AssetsImage.appIconSVG,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          AppString.appName,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(),
        ),
      ],
    );
  }
}