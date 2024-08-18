import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Controller/GroupController.dart';
import 'package:chat_app/Controller/ProfileController.dart';
import 'package:chat_app/Model/GroupModel.dart';
import 'package:chat_app/Pages/Chat/Widgets/ChatBubble.dart';
import 'package:chat_app/Pages/GroupChat/GroupTypeMessage.dart';
import 'package:chat_app/Pages/GroupInfo/GroupInfo.dart';
import 'package:chat_app/Pages/ProfilePage/fullpicfromUrl.dart';
import 'package:chat_app/config/Images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class GroupChatPage extends StatelessWidget {
  final GroupModel groupModel;

  const GroupChatPage({super.key, required this.groupModel});

  @override
  Widget build(BuildContext context) {
    final GroupController groupController = Get.put(GroupController());
    final ProfileController profileController = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            // Add functionality if needed
          },
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: GestureDetector(
              onTap: () => FullProfilePicUrl(
                imageUrl: groupModel.profileUrl == ""
                    ? AssetsImage.defaultProfileUrl
                    : groupModel.profileUrl!,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageUrl: groupModel.profileUrl == ""
                      ? AssetsImage.defaultProfileUrl
                      : groupModel.profileUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
        ),
        title: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            Get.to(GroupInfo(
              groupModel: groupModel,
            ));
          },
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(groupModel.name ?? "Group Name",
                      style: Theme.of(context).textTheme.bodyLarge),
                  Text(
                    "tap here for group info",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              //    Get.to(GroupAudioCallPage(target: ))
            },
            icon: const Icon(
              Icons.phone,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.video_call,
            ),
          )
        ],
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 10),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  StreamBuilder(
                    stream: groupController.getGroupMessages(groupModel.id!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text("Error: ${snapshot.error}"),
                        );
                      }
                      if (snapshot.data == null) {
                        return const Center(
                          child: Text("No Messages"),
                        );
                      } else {
                        return ListView.builder(
                          reverse: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            DateTime timestamp = DateTime.parse(
                                snapshot.data![index].timestamp!);
                            String formattedTime =
                                DateFormat('hh:mm a').format(timestamp);
                            return ChatBubble(
                              message: snapshot.data![index].message!,
                              imageUrl: snapshot.data![index].imageUrl ?? "",
                              isComming: snapshot.data![index].senderId !=
                                  profileController.currentUser.value.id,
                              status: "read",
                              time: formattedTime,
                            );
                          },
                        );
                      }
                    },
                  ),
                  Obx(
                    () => (groupController.selectedImagePath.value != "")
                        ? Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: FileImage(
                                        File(groupController
                                            .selectedImagePath.value),
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  height: 500,
                                ),
                                Positioned(
                                  right: 0,
                                  child: IconButton(
                                    onPressed: () {
                                      groupController.selectedImagePath.value =
                                          "";
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                  )
                ],
              ),
            ),
            GroupTypeMessage(
              groupModel: groupModel,
            ),
          ],
        ),
      ),
    );
  }
}
