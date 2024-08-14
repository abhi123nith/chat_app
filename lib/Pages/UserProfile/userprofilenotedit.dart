import 'package:chat_app/Controller/ProfileController.dart';
import 'package:chat_app/Model/UserModel.dart';
import 'package:chat_app/Pages/UserProfile/Widgets/userInfo.dart';
import 'package:chat_app/config/Images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfilePageWithoutEdit extends StatelessWidget {
  final UserModel userModel;
  const UserProfilePageWithoutEdit({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    // AuthController authController = Get.put(AuthController());
    // ignore: unused_local_variable
    ProfileController profileController = Get.put(ProfileController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            LoginUserInfo(
              profileImage:
                  userModel.profileImage ?? AssetsImage.defaultProfileUrl,
              userName: userModel.name ?? "User",
              userEmail: userModel.email ?? "",
            ),
            // const Spacer(),
            // ElevatedButton(
            //   onPressed: () {
            //     authController.logoutUser();
            //   },
            //   child: const Text("Logout"),
            // )
          ],
        ),
      ),
    );
  }
}
