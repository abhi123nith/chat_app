import 'package:chat_app/Controller/ProfileController.dart';
import 'package:chat_app/Model/ChatMode.dart';
import 'package:chat_app/Model/GroupModel.dart';
import 'package:chat_app/Model/UserModel.dart';
import 'package:chat_app/Pages/Home/HomePage.dart';
import 'package:chat_app/config/CustomMessage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class GroupController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  RxList<UserModel> groupMembers = <UserModel>[].obs;
  var uuid = const Uuid();
  RxBool isLoading = false.obs;
  RxString selectedImagePath = "".obs;
  RxList<GroupModel> groupList = <GroupModel>[].obs;
  ProfileController profileController = Get.put(ProfileController());

  @override
  void onInit() {
    super.onInit();
    getGroups();
  }

  void selectMember(UserModel user) {
    if (groupMembers.contains(user)) {
      groupMembers.remove(user);
    } else {
      groupMembers.add(user);
    }
  }

  Future<void> createGroup(String groupName, String imagePath) async {
    isLoading.value = true;
    String groupId = uuid.v6();
    groupMembers.add(
      UserModel(
        id: auth.currentUser!.uid,
        name: profileController.currentUser.value.name,
        profileImage: profileController.currentUser.value.profileImage,
        email: profileController.currentUser.value.email,
        role: "admin",
      ),
    );
    try {
      String imageUrl = await profileController.uploadFileToFirebase(imagePath);

      await db.collection("groups").doc(groupId).set(
        {
          "id": groupId,
          "name": groupName,
          "profileUrl": imageUrl,
          "members": groupMembers.map((e) => e.toJson()).toList(),
          "createdAt": DateTime.now().toString(),
          "createdBy": auth.currentUser!.uid,
          "timeStamp": DateTime.now().toString(),
        },
      );
      getGroups();
      successMessage("Group Created");
      Get.offAll(const HomePage());
      isLoading.value = false;
    } catch (e) {
      print(e);
    }
  }

  Future<void> getGroups() async {
    isLoading.value = true;
    List<GroupModel> tempGroup = [];
    await db.collection('groups').get().then(
      (value) {
        tempGroup = value.docs
            .map(
              (e) => GroupModel.fromJson(e.data()),
            )
            .toList();
      },
    );
    groupList.clear();
    groupList.value = tempGroup
        .where(
          (e) => e.members!.any(
            (element) => element.id == auth.currentUser!.uid,
          ),
        )
        .toList();
    isLoading.value = false;
  }

  Stream<List<GroupModel>> getGroupss() {
    isLoading.value = true;
    return db.collection('groups').snapshots().map((snapshot) {
      List<GroupModel> tempGroup =
          snapshot.docs.map((doc) => GroupModel.fromJson(doc.data())).toList();
      groupList.clear();
      groupList.value = tempGroup
          .where((group) => group.members!
              .any((member) => member.id == auth.currentUser!.uid))
          .toList();
      isLoading.value = false;
      return groupList;
    });
  }

  Future<void> sendGroupMessage(
      String message, String groupId, String imagePath) async {
    isLoading.value = true;
    var chatId = uuid.v6();
    String imageUrl =
        await profileController.uploadFileToFirebase(selectedImagePath.value);
    var newChat = ChatModel(
      id: chatId,
      message: message,
      imageUrl: imageUrl,
      senderId: auth.currentUser!.uid,
      senderName: profileController.currentUser.value.name,
      timestamp: DateTime.now().toString(),
    );
    await db
        .collection("groups")
        .doc(groupId)
        .collection("messages")
        .doc(chatId)
        .set(
          newChat.toJson(),
        );
    selectedImagePath.value = "";
    isLoading.value = false;
  }

  Stream<List<ChatModel>> getGroupMessages(String groupId) {
    return db
        .collection("groups")
        .doc(groupId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ChatModel.fromJson(doc.data()),
              )
              .toList(),
        );
  }

  Future<bool> isUserAdmin(String groupId, String userId) async {
    try {
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      final groupData = groupDoc.data();

      if (groupData != null) {
        final members =
            List<Map<String, dynamic>>.from(groupData['members'] ?? []);
        final user = members.firstWhere(
          (member) => member['id'] == userId,
          //orElse: () => null
        );

        return user['role'] == 'admin';
      }

      return false;
    } catch (e) {
      print("Error checking admin status: $e");
      return false;
    }
  }

  Future<void> addMemberToGroup(String groupId, UserModel user) async {
    try {
      // Add the user to the group
      await _firestore.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayUnion([user.toJson()]),
      });

      // Optionally, you might want to add the group to the user's list of groups
      await _firestore.collection('users').doc(user.id).update({
        'groups': FieldValue.arrayUnion([groupId]),
      });

      Get.snackbar("Success", "Member added to the group successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to add member to the group: $e");
    }
  }

  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> showEditGroupDialog(BuildContext context, String groupId,
      String currentName, String currentDescription) async {
    final TextEditingController nameController =
        TextEditingController(text: currentName);
    final TextEditingController descriptionController =
        TextEditingController(text: currentDescription);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Group Information"),
          content: SizedBox(
            width: 300, // Adjust width as needed
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Group Name',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Group Description',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // Save updated information
                await _updateGroupInfo(
                    groupId, nameController.text, descriptionController.text);
                Get.back(); // Close the dialog
                Get.snackbar("Group info updated", "",
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(8),
                    backgroundColor: Colors.green,
                    icon: const Icon(Icons.download_done_rounded));
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateGroupInfo(
      String groupId, String newName, String newDescription) async {
    try {
      await _firestore.collection('groups').doc(groupId).update({
        'name': newName,
        'description': newDescription,
      });
    } catch (e) {
      // Handle error
      print("Failed to update group info: $e");
    }
  }
}
