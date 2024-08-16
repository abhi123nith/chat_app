import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Controller/ChatController.dart';
import 'package:chat_app/Controller/ProfileController.dart';
import 'package:chat_app/Model/UserModel.dart';
import 'package:chat_app/Pages/CallPage/AudioCallPage.dart'; // Import AudioCallPage
import 'package:chat_app/Pages/CallPage/VideoCall.dart'; // Import VideoCallPage
import 'package:chat_app/Pages/Chat/ChatPAge.dart';
import 'package:chat_app/Pages/ProfilePage/fullpicfromUrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Config/Images.dart';

class CallHistory extends StatelessWidget {
  const CallHistory({super.key});

  @override
  Widget build(BuildContext context) {
    ChatController chatController = Get.put(ChatController());
    ProfileController profileController = Get.put(ProfileController());

    return StreamBuilder(
        stream: chatController.getCalls(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                DateTime timestamp =
                    DateTime.parse(snapshot.data![index].timestamp!);
                String formattedTime = DateFormat('hh:mm a').format(timestamp);

                // Determine the target user for the call
                UserModel targetUser = snapshot.data![index].callerUid ==
                        profileController.currentUser.value.id
                    ? UserModel(
                        id: snapshot.data![index].receiverUid!,
                        name: snapshot.data![index].receiverName!,
                        email: snapshot.data![index].receiverEmail!,
                        profileImage: snapshot.data![index].receiverPic,
                      )
                    : UserModel(
                        id: snapshot.data![index].callerUid!,
                        name: snapshot.data![index].callerName!,
                        email: snapshot.data![index].callerEmail!,
                        profileImage: snapshot.data![index].callerPic,
                      );

                return ListTile(
                  leading: GestureDetector(
                    onTap: () {
                      Get.to(FullProfilePicUrl(
                          imageUrl: targetUser.profileImage ??
                              AssetsImage.defaultProfileUrl));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: CachedNetworkImage(
                        height: 100,
                        width: 60,
                        fit: BoxFit.cover,
                        imageUrl: targetUser.profileImage ??
                            AssetsImage.defaultProfileUrl,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                  title: GestureDetector(
                    onTap: () {
                      _navigateToChatPage(context, targetUser);
                    },
                    child: Text(
                      targetUser.name!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  subtitle: Text(
                    formattedTime,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  trailing: snapshot.data![index].type == "video"
                      ? IconButton(
                          icon: const Icon(Icons.video_call),
                          onPressed: () {
                            Get.to(VideoCallPage(target: targetUser));
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.call),
                          onPressed: () {
                            Get.to(AudioCallPage(target: targetUser));
                          },
                        ),
                );
              },
            );
          } else {
            return const Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }

  void _navigateToChatPage(BuildContext context, UserModel member) {
    // Example function to navigate to the chat page
    // Replace `ChatPage` with the actual page you want to navigate to
    Get.to(() => ChatPage(
          userModel: member,
        ));
  }
}
