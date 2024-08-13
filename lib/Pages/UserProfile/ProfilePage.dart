import 'package:chat_app/Controller/AuthController.dart';
import 'package:chat_app/Controller/ProfileController.dart';
import 'package:chat_app/Model/UserModel.dart';
import 'package:chat_app/Pages/UserProfile/Widgets/userInfo.dart';
import 'package:chat_app/config/Images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfilePage extends StatelessWidget {
  final UserModel userModel;
  const UserProfilePage({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.put(AuthController());
    // ignore: unused_local_variable
    ProfileController profileController = Get.put(ProfileController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed("/updateProfilePage");
            },
            icon: const Icon(
              Icons.edit,
            ),
          )
        ],
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
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                authController.logoutUser();
              },
              child: const Text("Logout"),
            )
          ],
        ),
      ),
    );
  }
}
