import 'package:chat_app/Controller/ChatController.dart';
import 'package:chat_app/Controller/ContactController.dart';
import 'package:chat_app/Controller/ProfileController.dart';
import 'package:chat_app/Pages/Chat/ChatPAge.dart';
import 'package:chat_app/Pages/Home/Widget/ChatTile.dart';
import 'package:chat_app/config/Images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Model/ChatRoomModel.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    ContactController contactController = Get.put(ContactController());
    ProfileController profileController = Get.put(ProfileController());
    ChatController chatController = Get.put(ChatController());
    return StreamBuilder<List<ChatRoomModel>>(
      stream: contactController.getChatRoom(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        List<ChatRoomModel>? chatRooms = snapshot.data;

        if (chatRooms == null || chatRooms.isEmpty) {
          return const Center(child: Text('No chat rooms available.'));
        }
        return ListView.builder(
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            ChatRoomModel chatRoom = chatRooms[index];
            String? roomId = chatRoom.id;

            // Ensure roomId is not null or empty
            if (roomId == null || roomId.isEmpty) {
              return const SizedBox.shrink(); // Skip this tile
            }
            String currentUserId = profileController.currentUser.value.id ?? '';

            // Determine userModel and imageUrl
            var userModel = chatRoom.receiver!.id == currentUserId
                ? chatRoom.sender
                : chatRoom.receiver;

            return InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                chatController.markMessagesAsRead(roomId);
                Get.to(
                  ChatPage(
                    userModel: userModel!,
                  ),
                );
              },
              child: StreamBuilder<int>(
                stream: chatController.getUnreadMessageCount(roomId),
                builder: (context, snapshot) {
                  int unreadCount = snapshot.data ?? 0;

                  return ChatTile(
                    imageUrl: userModel!.profileImage ??
                        AssetsImage.defaultProfileUrl,
                    name: userModel.name ?? 'User',
                    lastChat: chatRoom.lastMessage ?? 'Last Message',
                    lastTime: chatRoom.lastMessageTimestamp ?? 'Last Time',
                    roomId: roomId,
                    unreadCount: unreadCount, // Pass unread count to ChatTile
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
