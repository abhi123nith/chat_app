import 'package:chat_app/Controller/ContactController.dart';
import 'package:chat_app/Pages/Chat/ChatPage.dart';
import 'package:chat_app/Pages/ContactPage/Widgets/NewContactTile.dart';
import 'package:chat_app/Pages/Groups/NewGroup/NewGroup.dart';
import 'package:chat_app/Pages/Home/Widget/userSearchBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Config/Images.dart';
import '../Home/Widget/ChatTile.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    RxBool isSearchEnable = false.obs;
    final TextEditingController searchController = TextEditingController();

    ContactController contactController = Get.put(ContactController());

    return Scaffold(
      appBar: AppBar(
        title:
         Obx(() => isSearchEnable.value
            ? UserSearchBar(
                searchController: searchController,
                onChanged: contactController.searchUsers,
              )
            : const Text("Select contact")),
        actions: [
          Obx(
            () => IconButton(
              onPressed: () {
                isSearchEnable.value = !isSearchEnable.value;
                if (!isSearchEnable.value) {
                  searchController.clear();
                  contactController.searchUsers('');
                }
              },
              icon: Icon(isSearchEnable.value ? Icons.close : Icons.search),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child:
         Obx(
          () => 
          isSearchEnable.value
              ? Expanded(
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
                          name: user.name ?? 'User',
                          lastChat: user.about ?? 'Hey there!',
                          lastTime:
                              '', // Update this according to your requirements
                          roomId: '', // Handle this appropriately
                        ),
                      );
                    },
                  ),
                )
              : Column(
                  children: [
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
                              name: user.name ?? 'User',
                              lastChat: user.about == ""
                                  ? 'Hey, I am using Sampark App!'
                                  : user.about!,
                              lastTime:
                                  '', // Update this according to your requirements
                              roomId: '', // Handle this appropriately
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
