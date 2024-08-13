import 'package:chat_app/Controller/GroupController.dart';
import 'package:chat_app/Pages/GroupChat/GroupChat.dart';
import 'package:chat_app/Pages/Home/Widget/ChatTile.dart';
import 'package:chat_app/config/Images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        return ListView.builder(
          itemCount: groups!.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Get.to(GroupChatPage(groupModel: groups[index]));
              },
              child: ChatTile(
                name: groups[index].name!,
                imageUrl: groups[index].profileUrl == ""
                    ? AssetsImage.defaultProfileUrl
                    : groups[index].profileUrl!,
                lastChat: "Group Created",
                lastTime: "Just Now",
              ),
            );
          },
        );
      },
    );
  }
}