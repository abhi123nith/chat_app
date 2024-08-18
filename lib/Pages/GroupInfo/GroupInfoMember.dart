import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Controller/GroupController.dart';
import 'package:chat_app/Model/UserModel.dart';
import 'package:chat_app/Pages/ProfilePage/fullpicfromUrl.dart';
import 'package:chat_app/config/Images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class GroupMemberInfo extends StatelessWidget {
  final String profileImage;
  final String userName;
  final String userEmail;
  final String groupId;
  final UserModel? user; // Make user optional

  const GroupMemberInfo({
    super.key,
    required this.profileImage,
    required this.userName,
    required this.userEmail,
    required this.groupId,
    this.user, // Optional parameter
  });

  @override
  Widget build(BuildContext context) {
    final GroupController groupController = Get.find<GroupController>();

    return Container(
      padding: const EdgeInsets.all(20),
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
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: InkWell(
                        onTap: () {
                          Get.to(FullProfilePicUrl(imageUrl: profileImage));
                        },
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: Row(children: [
                          SvgPicture.asset(
                            AssetsImage.profileAudioCall,
                            width: 25,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Call",
                            style: TextStyle(
                              color: Color(0xff039C00),
                            ),
                          )
                        ]),
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: Row(children: [
                          SvgPicture.asset(
                            AssetsImage.profileVideoCall,
                            width: 25,
                            color: const Color(0xffFF9900),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Video",
                            style: TextStyle(
                              color: Color(0xffFF9900),
                            ),
                          )
                        ]),
                      ),
                    ),
                    if (user != null)
                      InkWell(
                        onTap: () async {
                          await groupController.addMemberToGroup(
                              groupId, user!);
                        },
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: Row(children: [
                            SvgPicture.asset(
                              AssetsImage.groupAddUser,
                              width: 25,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Add",
                            ),
                          ]),
                        ),
                      ),
                    InkWell(
                      onTap: () {
                        groupController.showEditGroupDialog(
                            context, groupId, userName, userEmail);
                      },
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: const Row(children: [
                          Icon(Icons.edit),
                          SizedBox(width: 10),
                          Text(
                            "Edit",
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
