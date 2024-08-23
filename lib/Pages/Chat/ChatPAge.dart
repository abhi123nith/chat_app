// ignore: file_names
// ignore_for_file: unused_local_variable, avoid_unnecessary_containers

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Controller/CallController.dart';
import 'package:chat_app/Controller/ProfileController.dart';
import 'package:chat_app/Controller/chattcontroller.dart';
import 'package:chat_app/Model/UserModel.dart';
import 'package:chat_app/Pages/CallPage/AudioCallPage.dart';
import 'package:chat_app/Pages/CallPage/VideoCall.dart';
import 'package:chat_app/Pages/Chat/Widgets/ChatBubble.dart';
import 'package:chat_app/Pages/Chat/Widgets/TypeMessage.dart';
import 'package:chat_app/Pages/UserProfile/userprofilenotedit.dart';
import 'package:chat_app/Pages/UserProfile/viewfullProfileImage.dart';
import 'package:chat_app/config/Images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatelessWidget {
  final UserModel userModel;
  const ChatPage({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    TextEditingController messageController = TextEditingController();
    ProfileController profileController = Get.put(ProfileController());
    CallController callController = Get.put(CallController());
    ChattController chattController = Get.put(ChattController());

    bool isSameUser = profileController.currentUser.value.id == userModel.id;

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            Get.to(FullProfilePic(userModel: userModel));
          },
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CachedNetworkImage(
                imageUrl:
                    userModel.profileImage ?? AssetsImage.defaultProfileUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
        ),
        title: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            Get.to(UserProfilePageWithoutEdit(userModel: userModel));
          },
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userModel.name ?? "User",
                      style: Theme.of(context).textTheme.bodyLarge),
                  isSameUser
                      ? const Text("Message yourself",
                          style: TextStyle(fontSize: 12, color: Colors.grey))
                      : StreamBuilder(
                          stream: chattController.getStatus(userModel.id!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text("........");
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.status == null) {
                              return const Text(
                                "Offline",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              );
                            }

                            var userStatus = snapshot.data!;
                            String status = userStatus.status ?? "Offline";

                            if (status == "Online") {
                              return const Text(
                                "Online",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.green),
                              );
                            } else {
                              DateTime lastSeenTime;
                              try {
                                lastSeenTime =
                                    userStatus.lastOnlineStatus != null
                                        ? DateTime.parse(
                                            userStatus.lastOnlineStatus!)
                                        : DateTime.now();
                              } catch (e) {
                                lastSeenTime = DateTime.now();
                              }

                              String formattedDate = DateTime.now()
                                          .difference(lastSeenTime)
                                          .inHours <
                                      12
                                  ? "Last seen: ${DateFormat('hh:mm a').format(lastSeenTime)}"
                                  : "Last seen: ${DateFormat('MMM d, yyyy').format(lastSeenTime)}";

                              return Text(
                                formattedDate,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              );
                            }
                          },
                        ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          if (!isSameUser) ...[
            IconButton(
              onPressed: () {
                Get.to(AudioCallPage(target: userModel));
                callController.callAction(
                    userModel, profileController.currentUser.value, "audio");
              },
              icon: const Icon(Icons.phone),
            ),
            IconButton(
              onPressed: () {
                Get.to(VideoCallPage(target: userModel));
                callController.callAction(
                    userModel, profileController.currentUser.value, "video");
              },
              icon: const Icon(Icons.video_call),
            ),
          ],
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
                    stream: chattController.getMessages(userModel.id!),
                    builder: (context, snapshot) {
                      var roomid = chattController.getRoomId(userModel.id!);
                      chattController.markMessagesAsRead(roomid);

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      if (snapshot.data == null || snapshot.data!.isEmpty) {
                        return const Center(child: Text("No Messages"));
                      }

                      return ListView.builder(
                        reverse: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          DateTime timestamp =
                              DateTime.parse(snapshot.data![index].timestamp!);
                          String formattedTime =
                              DateFormat('hh:mm a').format(timestamp);

                          return ChatBubble(
                            message: snapshot.data![index].message!,
                            imageUrl: snapshot.data![index].imageUrl ?? "",
                            isComming: snapshot.data![index].receiverId ==
                                profileController.currentUser.value.id,
                            status: snapshot.data![index].readStatus!,
                            time: formattedTime,
                            messageId: snapshot.data![index].id!,
                            roomId: roomid,
                            videoUrl: snapshot.data![index].videoUrl ?? "",
                          );
                        },
                      );
                    },
                  ),
                  Obx(
                    () => chattController.selectedImagePath.value.isNotEmpty
                        ? Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: FileImage(File(
                                      chattController.selectedImagePath.value)),
                                  fit: BoxFit.contain,
                                ),
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              height: 200,
                            ),
                          )
                        : Container(),
                  ),
                ],
              ),
            ),
            TypeMessage(
              userModel: userModel,
            ),
          ],
        ),
      ),
    );
  }
}
