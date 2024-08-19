// ignore_for_file: deprecated_member_use

import 'package:chat_app/Controller/ContactController.dart';
import 'package:chat_app/Controller/GroupController.dart';
import 'package:chat_app/Model/UserModel.dart';
import 'package:chat_app/Pages/Groups/NewGroup/GroupTitle.dart';
import 'package:chat_app/Pages/Groups/NewGroup/SelectMemberList.dart';
import 'package:chat_app/Pages/Home/Widget/ChatTile.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import for Firebase Auth
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Config/Images.dart';

class NewGroup extends StatelessWidget {
  const NewGroup({super.key});

  @override
  Widget build(BuildContext context) {
    ContactController contactController = Get.put(ContactController());
    GroupController groupController = Get.put(GroupController());
    String currentUserId =
        FirebaseAuth.instance.currentUser!.uid; // Get current user ID

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
      ),
      floatingActionButton: Obx(
        () => FloatingActionButton(
          backgroundColor: groupController.groupMembers.isEmpty
              ? Colors.grey
              : Theme.of(context).colorScheme.primary,
          onPressed: () {
            if (groupController.groupMembers.isEmpty) {
              Get.snackbar("Error", "Please select at least one member");
            } else {
              Get.to(const GroupTitle());
            }
          },
          child: Icon(
            Icons.arrow_forward,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SelectedMembers(),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "Contacts on Sampark",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<UserModel>>(
                stream: contactController.getContacts(),
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
                  if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No Contacts"),
                    );
                  } else {
                    // Filter out the current user
                    var filteredContacts = snapshot.data!
                        .where((user) => user.id != currentUserId)
                        .toList();

                    return ListView.builder(
                      itemCount: filteredContacts.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            groupController
                                .selectMember(filteredContacts[index]);
                          },
                          child: ChatTile(
                            imageUrl: filteredContacts[index].profileImage ??
                                AssetsImage.defaultProfileUrl,
                            name: filteredContacts[index].name!,
                            lastChat: filteredContacts[index].about == ""
                                ? "Hey, I am using Sampark App!"
                                : filteredContacts[index].about!,
                            lastTime: "",
                            roomId: '',
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
