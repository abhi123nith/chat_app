import 'package:chat_app/Controller/ContactController.dart';
import 'package:chat_app/Controller/ProfileController.dart';
import 'package:chat_app/Pages/Chat/ChatPage.dart';
import 'package:chat_app/Pages/ContactPage/Widgets/NewContactTile.dart';
import 'package:chat_app/Pages/Groups/NewGroup/NewGroup.dart';
import 'package:chat_app/Pages/Home/Widget/userSearchBar.dart';
import 'package:chat_app/Pages/Live/live.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Config/Images.dart';
import '../Home/Widget/ChatTile.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize RxBool for search state
    final RxBool isSearchEnable = false.obs;
    final TextEditingController searchController = TextEditingController();

    // Initialize ContactController and ProfileController
    final ContactController contactController = Get.put(ContactController());
    final ProfileController profileController = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          if (isSearchEnable.value) {
            return UserSearchBar(
              searchController: searchController,
              onChanged: contactController.searchUsers,
            );
          } else {
            return const Text("Select contact");
          }
        }),
        actions: [
          Obx(() {
            return IconButton(
              onPressed: () {
                isSearchEnable.value = !isSearchEnable.value;
                if (!isSearchEnable.value) {
                  searchController.clear();
                  contactController.searchUsers('');
                }
              },
              icon: Icon(isSearchEnable.value ? Icons.close : Icons.search),
            );
          }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Obx(() {
          if (isSearchEnable.value) {
            // Search mode is enabled
            return Expanded(
              child: ListView.separated(
                itemCount: contactController.filteredUserList.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  var user = contactController.filteredUserList[index];
                  return InkWell(
                    onTap: () {
                      Get.to(ChatPage(userModel: user));
                    },
                    child: ChatTile(
                      imageUrl: user.profileImage?.isNotEmpty == true
                          ? user.profileImage!
                          : AssetsImage.defaultProfileUrl,
                      name: user.id == profileController.currentUser.value.id
                          ? 'You'
                          : user.name ?? 'User',
                      lastChat: user.about ?? 'Hey there!',
                      lastTime:
                          '', // Update this according to your requirements
                      roomId: '', // Handle this appropriately
                    ),
                  );
                },
              ),
            );
          } else {
            // Default view
            return Column(
              children: [
                NewContactTile(
                  btnName: "New Group",
                  icon: Icons.group_add,
                  ontap: () {
                    Get.to(const NewGroup());
                  },
                ),
                const SizedBox(height: 10),
                NewContactTile(
                  btnName: "Start Live Streaming",
                  icon: Icons.live_tv,
                  ontap: () {
                    Get.defaultDialog(
                      title: 'Live Streaming',
                      content: Column(
                        children: [
                          const Text(
                            'You are here for?',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Get.to(
                                      const LiveScreenView(liveID: 'liveId'));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                child: const Text(
                                  'Watch',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Get.to(const LiveScreenView(
                                    liveID: 'liveId',
                                    isHost: true,
                                  ));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                child: const Text(
                                  'Start',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      backgroundColor: Colors.grey,
                    );
                  },
                ),
                const SizedBox(height: 10),
                const Text("Contacts on Sampark"),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: contactController.userList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      var user = contactController.userList[index];
                      return InkWell(
                        onTap: () {
                          Get.to(ChatPage(userModel: user));
                        },
                        child: ChatTile(
                          imageUrl: user.profileImage?.isNotEmpty == true
                              ? user.profileImage!
                              : AssetsImage.defaultProfileUrl,
                          name:
                              user.id == profileController.currentUser.value.id
                                  ? 'You'
                                  : user.name ?? 'User',
                          lastChat: user.about?.isNotEmpty == true
                              ? user.about!
                              : 'Hey, I am using Sampark App!',
                          lastTime:
                              '', // Update this according to your requirements
                          roomId: '', // Handle this appropriately
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}
