// ignore_for_file: unused_local_variable, sized_box_for_whitespace

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Controller/GroupController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Controller/ProfileController.dart';

class GroupMemberInfo extends StatelessWidget {
  final String profileImage;
  final String userName;
  final String userEmail;
  final String groupId;

  const GroupMemberInfo(
      {super.key,
      required this.profileImage,
      required this.userName,
      required this.userEmail,
      required this.groupId});

  @override
  Widget build(BuildContext context) {
    ProfileController profileController = Get.put(ProfileController());
    GroupController groupController = Get.put(GroupController());
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
                    Container(
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
                // SizedBox(height: 20),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //   children: [
                //     Container(
                //       height: 50,
                //       padding: EdgeInsets.all(15),
                //       decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(15),
                //         color: Theme.of(context).colorScheme.background,
                //       ),
                //       child: Row(children: [
                //         SvgPicture.asset(
                //           AssetsImage.profileAudioCall,
                //           width: 25,
                //         ),
                //         SizedBox(width: 10),
                //         Text(
                //           "Call",
                //           style: TextStyle(
                //             color: Color(0xff039C00),
                //           ),
                //         )
                //       ]),
                //     ),
                //     Container(
                //       height: 50,
                //       padding: EdgeInsets.all(15),
                //       decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(15),
                //         color: Theme.of(context).colorScheme.background,
                //       ),
                //       child: Row(children: [
                //         SvgPicture.asset(
                //           AssetsImage.profileVideoCall,
                //           width: 25,
                //           color: Color(0xffFF9900),
                //         ),
                //         SizedBox(width: 10),
                //         Text(
                //           "Video",
                //           style: TextStyle(
                //             color: Color(0xffFF9900),
                //           ),
                //         )
                //       ]),
                //     ),
                //     InkWell(
                //       onTap: () {
                //         var newMember = UserModel(
                //           email: "Nitish@gmail.com",
                //           name: "Nitish",
                //           profileImage: "",
                //           role: "admin",
                //         );

                //         groupController.addMemberToGroup(groupId, newMember);
                //       },
                //       child: Container(
                //         height: 50,
                //         padding: EdgeInsets.all(15),
                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(15),
                //           color: Theme.of(context).colorScheme.background,
                //         ),
                //         child: Row(children: [
                //           SvgPicture.asset(
                //             AssetsImage.groupAddUser,
                //             width: 25,
                //           ),
                //           SizedBox(width: 10),
                //           Text(
                //             "Add",
                //           )
                //         ]),
                //       ),
                //     )
                //   ],
                // )
              ],
            ),
          )
        ],
      ),
    );
  }
}
