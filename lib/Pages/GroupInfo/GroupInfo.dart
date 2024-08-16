import 'package:chat_app/Model/GroupModel.dart';
import 'package:chat_app/Model/UserModel.dart';
import 'package:chat_app/Pages/Chat/ChatPage.dart';
import 'package:chat_app/Pages/GroupInfo/GroupInfoMember.dart';
import 'package:chat_app/Pages/Home/Widget/ChatTile.dart';
import 'package:chat_app/config/Images.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting

class GroupInfo extends StatelessWidget {
  final GroupModel groupModel;

  const GroupInfo({super.key, required this.groupModel});

  @override
  Widget build(BuildContext context) {
    // Format the creation date
    final date = DateTime.now();
    String formattedDate = DateFormat('dd MMM yyyy').format(date);

    // Sort members: Admins first, then regular users
    List<UserModel> sortedMembers = groupModel.members!
        .where((member) => member.role == 'admin')
        .toList()
      ..addAll(
        groupModel.members!.where((member) => member.role != 'admin').toList(),
      );

    return Scaffold(
      appBar: AppBar(
        title: Text(groupModel.name!),
        actions: [
          IconButton(
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: FutureBuilder<UserModel>(
          future: _fetchCreator(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData) {
              return const Center(child: Text("No creator found"));
            }

            final creator = snapshot.data!;

            return ListView(
              children: [
                GroupMemberInfo(
                  //user: user,
                  groupId: groupModel.id!,
                  profileImage: groupModel.profileUrl == ""
                      ? AssetsImage.defaultProfileUrl
                      : groupModel.profileUrl!,
                  userName: groupModel.name!,
                  userEmail:
                      groupModel.description ?? "No Description Available",
                ),
                const SizedBox(height: 20),
                Text(
                  "Members",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 10),
                Column(
                  children: sortedMembers
                      .map(
                        (member) => InkWell(
                          onTap: () {
                            // Handle member tap
                            _navigateToChatPage(context, member);
                          },
                          child: ChatTile(
                            imageUrl: member.profileImage ??
                                AssetsImage.defaultProfileUrl,
                            name: member.name!,
                            lastChat: member.email!,
                            lastTime: member.role == "admin" ? "Admin" : "User",
                            roomId: groupModel.id!,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                // Display the creator's username
                Center(
                  child: Text(
                    "Created By: ${creator.name}",
                  ),
                ),
                const SizedBox(height: 10),
                // Display the creation date at the bottom
                Center(
                  child: Text(
                    "Created On: $formattedDate",
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Group"),
          content: const Text("Are you sure you want to delete this group?"),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                _deleteGroup();
                Get.back(); // Close the dialog
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _deleteGroup() async {
    // Implement your logic to delete the group from the database.
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupModel.id)
        .delete();

    // Navigate back to the previous screen or home page
    Get.back();
  }

  void _navigateToChatPage(BuildContext context, UserModel member) {
    // Example function to navigate to the chat page
    // Replace `ChatPage` with the actual page you want to navigate to
    Get.to(() => ChatPage(
          userModel: member,
        ));
  }

  Future<UserModel> _fetchCreator() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(groupModel.createdBy)
        .get();
    final userData = userDoc.data();
    if (userData != null) {
      return UserModel.fromJson(userData);
    } else {
      throw Exception("Creator not found");
    }
  }
}
