import 'package:chat_app/Controller/GroupController.dart';
import 'package:chat_app/Pages/GroupChat/GroupChat.dart';
import 'package:chat_app/Pages/Home/Widget/ChatTile.dart';
import 'package:chat_app/config/Images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Model/GroupModel.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    GroupController groupController = Get.put(GroupController());
    return StreamBuilder<List<GroupModel>>(
      stream: groupController.getGroupss(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        List<GroupModel>? groups = snapshot.data;

        // Sort groups: groups with no messages or older messages come first
        groups?.sort((a, b) {
          DateTime? aTime = a.lastMessageTime != null
              ? DateTime.parse(a.lastMessageTime!)
              : null;
          DateTime? bTime = b.lastMessageTime != null
              ? DateTime.parse(b.lastMessageTime!)
              : null;

          if (aTime == null && bTime == null) {
            return 0;
          } else if (aTime == null) {
            return -1; // Groups with no last message come first
          } else if (bTime == null) {
            return 1; // Groups with no last message come first
          } else {
            // Compare times for groups with last messages
            return aTime.compareTo(bTime);
          }
        });

        return ListView.builder(
          itemCount: groups!.length,
          itemBuilder: (context, index) {
            GroupModel group = groups[index];
            String formattedTime = "";

            // Check if lastMessageTime is available
            if (group.lastMessageTime != null) {
              DateTime lastMessageDate = DateTime.parse(group.lastMessageTime!);
              DateTime now = DateTime.now();

              // Calculate difference in hours
              Duration difference = now.difference(lastMessageDate);

              if (difference.inHours > 24) {
                // Show date if more than 24 hours
                formattedTime =
                    DateFormat('MMM d, yyyy').format(lastMessageDate);
              } else {
                // Show time if within 24 hours
                formattedTime = DateFormat('hh:mm a').format(lastMessageDate);
              }
            }
            return InkWell(
              onTap: () {
                Get.to(GroupChatPage(groupModel: group));
              },
              child: ChatTile(
                name: group.name!,
                imageUrl: group.profileUrl == ""
                    ? AssetsImage.defaultProfileUrl
                    : group.profileUrl!,
                lastChat: group.lastMessage ?? 'No messages yet',
                lastTime: formattedTime,
                roomId: group.id ?? '',
              ),
            );
          },
        );
      },
    );
  }
}
