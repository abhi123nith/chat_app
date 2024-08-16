import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Model/UserModel.dart';
import 'package:chat_app/config/Images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FullProfilePic extends StatelessWidget {
  final UserModel userModel;
  const FullProfilePic({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Center(
        child: CachedNetworkImage(
          height: MediaQuery.of(context).size.height * 0.9,
          imageUrl: userModel.profileImage ?? AssetsImage.defaultProfileUrl,
          fit: BoxFit.contain,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }
}
