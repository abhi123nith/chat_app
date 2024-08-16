import 'package:chat_app/Model/UserModel.dart';
import 'package:chat_app/Pages/UserProfile/Widgets/userInfo.dart';
import 'package:chat_app/config/Images.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package

class UserProfilePageWithoutEdit extends StatelessWidget {
  final UserModel userModel;

  const UserProfilePageWithoutEdit({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    //ProfileController profileController = Get.put(ProfileController());
    final date = DateTime.now();
    // Format the date
    String formattedDate = DateFormat('dd MMM yyyy').format(date);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LoginUserInfo(
              profileImage:
                  userModel.profileImage ?? AssetsImage.defaultProfileUrl,
              userName: userModel.name ?? "User",
              userEmail: userModel.email ?? "",
              userModel: userModel,
              userAbout: userModel.about ?? "Hi, I am using Sampark",
            ),
            const Spacer(),
            Center(
              child: Text(
                "Joined At: $formattedDate",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
