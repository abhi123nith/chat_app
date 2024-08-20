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
    ChattController chatController = Get.put(ChattController());
    TextEditingController messageController = TextEditingController();
    ProfileController profileController = Get.put(ProfileController());
    CallController callController = Get.put(CallController());

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
            child: Container(
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
        ),
        title: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            Get.to(UserProfilePageWithoutEdit(
              userModel: userModel,
            ));
          },
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userModel.name ?? "User",
                      style: Theme.of(context).textTheme.bodyLarge),
                  isSameUser
                      ? const Text(
                          "Message yourself",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      : StreamBuilder(
                          stream: chatController.getStatus(userModel.id!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text("........");
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.status == null) {
                              return const Text("Offline");
                            }
                            var userStatus = snapshot.data!;
                            String status = userStatus.status ?? "Offline";

                            if (status == "Online") {
                              return Text(
                                status,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                ),
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

                              Duration difference =
                                  DateTime.now().difference(lastSeenTime);

                              String formattedDate;
                              if (difference.inHours < 12) {
                                formattedDate =
                                    "Last seen: ${DateFormat('hh:mm a').format(lastSeenTime)}";
                              } else {
                                formattedDate =
                                    "Last seen: ${DateFormat('MMM d, yyyy').format(lastSeenTime)}";
                              }

                              return Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              );
                            }
                          },
                        )
                ],
              ),
            ],
          ),
        ),
        actions: [
          if (profileController.currentUser.value.id != userModel.id) ...[
            IconButton(
              onPressed: () {
                Get.to(AudioCallPage(target: userModel));
                callController.callAction(
                    userModel, profileController.currentUser.value, "audio");
              },
              icon: const Icon(
                Icons.phone,
              ),
            ),
            IconButton(
              onPressed: () {
                Get.to(VideoCallPage(target: userModel));
                callController.callAction(
                  userModel,
                  profileController.currentUser.value,
                  "video",
                );
              },
              icon: const Icon(
                Icons.video_call,
              ),
            )
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
                    stream: chatController.getMessages(userModel.id!),
                    builder: (context, snapshot) {
                      var roomid = chatController.getRoomId(userModel.id!);
                      chatController.markMessagesAsRead(roomid);
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
                      if (snapshot.data == null || snapshot.data!.isEmpty) {
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
                              isComming: snapshot.data![index].receiverId ==
                                  profileController.currentUser.value.id,
                              status: snapshot.data![index].readStatus!,
                              time: formattedTime,
                              messageId: snapshot.data![index].id!,
                              roomId: roomid,
                            );
                          },
                        );
                      }
                    },
                  ),
                  Obx(
                    () => (chatController.selectedImagePath.value.isNotEmpty)
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
                                        File(chatController
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
                                      chatController.selectedImagePath.value =
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
            TypeMessage(
              userModel: userModel,
            ),
          ],
        ),
      ),
    );
  }
}
