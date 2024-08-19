import 'package:chat_app/Controller/ProfileController.dart';
import 'package:chat_app/Model/ChatMode.dart';
import 'package:chat_app/Model/ChatRoomModel.dart';
import 'package:chat_app/Model/GroupModel.dart';
import 'package:chat_app/Model/UserModel.dart';
import 'package:chat_app/Pages/Home/HomePage.dart';
import 'package:chat_app/config/CustomMessage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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

 Future<void> sendGMessage(String groupId, String message, String s) async {
    // Existing implementation
    String chatId = uuid.v6();
    DateTime timestamp = DateTime.now();
    String nowTime = DateFormat('hh:mm a').format(timestamp);

    List<Object> groupMembers = await getGroupMembers(groupId);

    var newChat = ChatModel(
      id: chatId,
      message: message,
      senderId: profileController.currentUser.value.id,
      timestamp: DateTime.now().toString(),
      readBy: [profileController.currentUser.value.id!], // Initialize with the current user's ID
    );

    var roomDetails = ChatRoomModel(
      id: groupId,
      lastMessage: message,
      lastMessageTimestamp: nowTime,
      timestamp: DateTime.now().toString(),
      unReadMessNo: groupMembers.length, // Initialize unread message count
    );

    try {
      await db
          .collection("chats")
          .doc(groupId)
          .collection("messages")
          .doc(chatId)
          .set(newChat.toJson());

      await db.collection("chats").doc(groupId).set(roomDetails.toJson());
    } catch (e) {
      print(e);
    }
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

  void addMemberToGroup(String groupId, UserModel user) async {
    final groupRef = _firestore.collection('groups').doc(groupId);
    final groupSnapshot = await groupRef.get();

    if (groupSnapshot.exists) {
      final groupData = groupSnapshot.data()!;
      final groupModel = GroupModel.fromJson(groupData);

      if (!groupModel.members!.any((member) => member.id == user.id)) {
        groupModel.members!.add(user);
        await groupRef.update(groupModel.toJson());
        groupList.firstWhere((group) => group.id == groupId).members!.add(user);
        Get.snackbar("Success", "${user.name} added to the group");
      }
    }
  }

  void removeMemberFromGroup(String groupId, UserModel user) async {
    final groupRef = _firestore.collection('groups').doc(groupId);
    final groupSnapshot = await groupRef.get();

    if (groupSnapshot.exists) {
      final groupData = groupSnapshot.data()!;
      final groupModel = GroupModel.fromJson(groupData);

      if (groupModel.members!.any((member) => member.id == user.id)) {
        groupModel.members!.removeWhere((member) => member.id == user.id);
        await groupRef.update(groupModel.toJson());
        groupList
            .firstWhere((group) => group.id == groupId)
            .members!
            .removeWhere((member) => member.id == user.id);
        Get.snackbar("Success", "${user.name} removed from the group");
      } else {
        Get.snackbar("Info", "${user.name} is not a member of this group");
      }
    }
  }

Future<void> markGMessagesAsRead(String groupId) async {
    QuerySnapshot<Map<String, dynamic>> messagesSnapshot = await db
        .collection("chats")
        .doc(groupId)
        .collection("messages")
        .where("readBy", arrayContains: profileController.currentUser.value.id)
        .get();

    List<Object> groupMembers = await getGroupMembers(groupId);

    for (QueryDocumentSnapshot<Map<String, dynamic>> messageDoc
        in messagesSnapshot.docs) {
      ChatModel message = ChatModel.fromJson(messageDoc.data());

      if (message.readBy!.length >= groupMembers.length) {
        await db
            .collection("chats")
            .doc(groupId)
            .collection("messages")
            .doc(messageDoc.id)
            .update({"readBy": FieldValue.arrayUnion([profileController.currentUser.value.id])});
      }
    }

    // Update unread message count
    await updateUnreadMessageCount(groupId);
  }

  Future<void> updateUnreadMessageCount(String groupId) async {
    List<Object> groupMembers = await getGroupMembers(groupId);
    
    int unreadCount = await db
        .collection("chats")
        .doc(groupId)
        .collection("messages")
        .where("readBy", arrayContains: profileController.currentUser.value.id)
        .where("readBy", isLessThan: groupMembers.length)
        .get()
        .then((snapshot) => snapshot.docs.length);

    await db.collection("chats").doc(groupId).update({
      'unReadMessNo': unreadCount,
    });
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

  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromJson(doc.data());
      }).toList();
    });
  }

  Future<List<Object>> getGroupMembers(String groupId) async {
    var groupDoc = await db.collection('groups').doc(groupId).get();
    GroupModel group = GroupModel.fromJson(groupDoc.data()!);
    return group.members ?? [];
  }


}
