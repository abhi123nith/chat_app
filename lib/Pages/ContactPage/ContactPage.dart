// ignore_for_file: unused_local_variable

import 'package:chat_app/Controller/ChatController.dart';
import 'package:chat_app/Controller/ContactController.dart';
import 'package:chat_app/Controller/ProfileController.dart';
import 'package:chat_app/Pages/Chat/ChatPAge.dart';
import 'package:chat_app/Pages/ContactPage/Widgets/ContactSearch.dart';
import 'package:chat_app/Pages/ContactPage/Widgets/NewContactTile.dart';
import 'package:chat_app/Pages/Groups/NewGroup/NewGroup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Config/Images.dart';
import '../Home/Widget/ChatTile.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    RxBool isSearchEnable = false.obs;
    ContactController contactController = Get.put(ContactController());
    ProfileController profileController = Get.put(ProfileController());
    ChatController chatController = Get.put(ChatController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select contact"),
        actions: [
          Obx(
            () => IconButton(
              onPressed: () {
                isSearchEnable.value = !isSearchEnable.value;
              },
              icon: isSearchEnable.value
                  ? const Icon(Icons.close)
                  : const Icon(Icons.search),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            Obx(
              () => isSearchEnable.value
                  ? const ContactSearch()
                  : const SizedBox(),
            ),
            const SizedBox(height: 10),
            NewContactTile(
              btnName: "New contact",
              icon: Icons.person_add,
              ontap: () {},
            ),
            const SizedBox(height: 10),
            NewContactTile(
              btnName: "New Group",
              icon: Icons.group_add,
              ontap: () {
                Get.to(const NewGroup());
              },
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Text("Contacts on Sampark"),
              ],
            ),
            const SizedBox(height: 10),
            Obx(
              () => Column(
                children: contactController.userList.map((e) {
                  String roomId = chatController.getRoomId(e.id!);
                  return InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      Get.to(ChatPage(userModel: e));
                    },
                    child: ChatTile(
                      imageUrl:
                          e.profileImage != null && e.profileImage!.isNotEmpty
                              ? e.profileImage ?? AssetsImage.defaultProfileUrl
                              : AssetsImage.defaultProfileUrl,
                      name: e.name ?? "User",
                      lastChat: e.about ?? "Hey there",
                      lastTime:
                          e.email == profileController.currentUser.value.email
                              ? "You"
                              : "",
                      roomId: roomId,
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
