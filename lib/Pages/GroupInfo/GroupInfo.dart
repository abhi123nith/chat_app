// ignore_for_file: library_private_types_in_public_api

import 'package:chat_app/Controller/GroupController.dart';
import 'package:chat_app/Model/GroupModel.dart';
import 'package:chat_app/Model/UserModel.dart';
import 'package:chat_app/Pages/Chat/ChatPAge.dart';
import 'package:chat_app/Pages/GroupInfo/GroupInfoMember.dart';
import 'package:chat_app/Pages/Home/Widget/ChatTile.dart';
import 'package:chat_app/config/Images.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class GroupInfo extends StatefulWidget {
  final GroupModel groupModel;

  const GroupInfo({super.key, required this.groupModel});

  @override
  _GroupInfoState createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  final GroupController groupController = Get.put(GroupController());

  @override
  Widget build(BuildContext context) {
    // Format the creation date
    final date = DateTime.now();
    String formattedDate = DateFormat('dd MMM yyyy').format(date);

    // Sort members: Admins first, then regular users
    List<UserModel> sortedMembers = widget.groupModel.members!
        .where((member) => member.role == 'admin')
        .toList()
      ..addAll(
        widget.groupModel.members!
            .where((member) => member.role != 'admin')
            .toList(),
      );
    widget.groupModel.members!
        .where((member) => member.role != 'admin')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupModel.name!),
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
                  groupId: widget.groupModel.id!,
                  profileImage: widget.groupModel.profileUrl == ""
                      ? AssetsImage.defaultProfileUrl
                      : widget.groupModel.profileUrl!,
                  userName: widget.groupModel.name!,
                  userEmail: widget.groupModel.description ??
                      "No Description Available",
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      "Members",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _showAddMemberDialog(context);
                          },
                          icon: const Icon(Icons.group_add),
                        ),
                        IconButton(
                          onPressed: () {
                            _showRemoveMemberDialog(context);
                          },
                          icon: const Icon(Icons.group_remove),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 20,
                    )
                  ],
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
                            roomId: widget.groupModel.id!,
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
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupModel.id)
        .delete();

    Get.back();
  }

  void _navigateToChatPage(BuildContext context, UserModel member) {
    Get.to(() => ChatPage(
          userModel: member,
        ));
  }

  Future<UserModel> _fetchCreator() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.groupModel.createdBy)
        .get();
    final userData = userDoc.data();
    if (userData != null) {
      return UserModel.fromJson(userData);
    } else {
      throw Exception("Creator not found");
    }
  }

  void _showAddMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Members to the Group"),
          content: SizedBox(
            width: 300,
            child: StreamBuilder<List<UserModel>>(
              stream: groupController.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                final allUsers = snapshot.data!;
                final groupMemberIds =
                    widget.groupModel.members!.map((e) => e.id).toList();

                // Filter out users who are already in the group
                final usersToAdd = allUsers
                    .where((user) => !groupMemberIds.contains(user.id))
                    .toList();

                if (usersToAdd.isEmpty) {
                  return const Center(
                      child: Text("All users are already in the group"));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: usersToAdd.length,
                  itemBuilder: (context, index) {
                    final user = usersToAdd[index];
                    return InkWell(
                      onTap: () async {
                        groupController.addMemberToGroup(
                            widget.groupModel.id!, user);
                        setState(() {
                          widget.groupModel.members!.add(user);
                        });
                        Get.back(); // Close the dialog
                        Get.snackbar(
                            backgroundColor: Colors.green,
                            "Success",
                            "${user.name} added to the group");
                      },
                      child: ChatTile(
                        imageUrl:
                            user.profileImage ?? AssetsImage.defaultProfileUrl,
                        name: user.name!,
                        lastChat: user.email!,
                        lastTime: "",
                        roomId: '',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showRemoveMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final nonAdminMembers = widget.groupModel.members!
            .where((member) => member.role != 'admin')
            .toList();
        return AlertDialog(
          title: const Text("Remove Member"),
          content: SizedBox(
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: nonAdminMembers.length,
              itemBuilder: (context, index) {
                final member = nonAdminMembers[index];
                return InkWell(
                  onTap: () async {
                    groupController.removeMemberFromGroup(
                        widget.groupModel.id!, member);
                    setState(() {
                      widget.groupModel.members!.remove(member);
                    });

                    Get.back(); // Close the dialog
                    Get.snackbar(
                        backgroundColor: Colors.green,
                        "Success",
                        "${member.name} removed from the group");
                  },
                  child: ChatTile(
                    imageUrl:
                        member.profileImage ?? AssetsImage.defaultProfileUrl,
                    name: member.name!,
                    lastChat: member.email!,
                    lastTime: member.role == "admin" ? "Admin" : "User",
                    roomId: '',
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
