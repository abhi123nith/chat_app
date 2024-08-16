// ignore_for_file: deprecated_member_use, unused_local_variable, sized_box_for_whitespace

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Controller/CallController.dart';
import 'package:chat_app/Model/UserModel.dart';
import 'package:chat_app/Pages/UserProfile/viewfullProfileImage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Controller/ProfileController.dart';

class LoginUserInfo extends StatelessWidget {
  final String profileImage;
  final String userName;
  final String userEmail;
  final String userAbout;
  final UserModel userModel;
  const LoginUserInfo(
      {super.key,
      required this.profileImage,
      required this.userName,
      required this.userEmail,
      required this.userModel,
      required this.userAbout});

  @override
  Widget build(BuildContext context) {
    ProfileController profileController = Get.put(ProfileController());
    CallController callController = Get.put(CallController());
    return Container(
      padding: const EdgeInsets.all(20),
      // height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.to(FullProfilePic(userModel: userModel));
                      },
                      child: Container(
                        width: 150,
                        height: 150,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CachedNetworkImage(
                            imageUrl: profileImage,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userEmail,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userAbout.toString() == ""
                          ? "Hii, I am using Sampark"
                          : userAbout,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          )
        ],
      ),
    );
  }
}
