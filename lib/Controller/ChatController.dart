// ignore_for_file: avoid_print

import 'package:chat_app/Controller/ContactController.dart';
import 'package:chat_app/Controller/ProfileController.dart';
import 'package:chat_app/Model/AudioCall.dart';
import 'package:chat_app/Model/ChatMode.dart';
import 'package:chat_app/Model/ChatRoomModel.dart';
import 'package:chat_app/Model/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ChatController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;

  var uuid = const Uuid();
  RxString selectedImagePath = "".obs;
  @override
  // ignore: override_on_non_overriding_member
  ProfileController profileController = Get.put(ProfileController());
  ContactController contactController = Get.put(ContactController());
  String getRoomId(String targetUserId) {
    String currentUserId = auth.currentUser!.uid;
    if (currentUserId[0].codeUnitAt(0) > targetUserId[0].codeUnitAt(0)) {
      return currentUserId + targetUserId;
    } else {
      return targetUserId + currentUserId;
    }
  }

  UserModel getSender(UserModel currentUser, UserModel targetUser) {
    String currentUserId = currentUser.id!;
    String targetUserId = targetUser.id!;
    if (currentUserId[0].codeUnitAt(0) > targetUserId[0].codeUnitAt(0)) {
      return currentUser;
    } else {
      return targetUser;
    }
  }

  UserModel getReciver(UserModel currentUser, UserModel targetUser) {
    String currentUserId = currentUser.id!;
    String targetUserId = targetUser.id!;
    if (currentUserId[0].codeUnitAt(0) > targetUserId[0].codeUnitAt(0)) {
      return targetUser;
    } else {
      return currentUser;
    }
  }

  Future<void> sendMessage(
      String targetUserId, String message, UserModel targetUser) async {
    isLoading.value = true;
    String chatId = uuid.v6();
    String roomId = getRoomId(targetUserId);
    DateTime timestamp = DateTime.now();
    String nowTime = DateFormat('hh:mm a').format(timestamp);

    UserModel sender =
        getSender(profileController.currentUser.value, targetUser);
    UserModel receiver =
        getReciver(profileController.currentUser.value, targetUser);

    RxString imageUrl = "".obs;
    if (selectedImagePath.value.isNotEmpty) {
      imageUrl.value =
          await profileController.uploadFileToFirebase(selectedImagePath.value);
    }
    var newChat = ChatModel(
      id: chatId,
      message: message,
      imageUrl: imageUrl.value,
      senderId: auth.currentUser!.uid,
      receiverId: targetUserId,
      senderName: profileController.currentUser.value.name,
      timestamp: DateTime.now().toString(),
      readStatus: (auth.currentUser!.uid == targetUserId) ? "read" : "unread",
    );

    var roomDetails = ChatRoomModel(
      id: roomId,
      lastMessage: message,
      lastMessageTimestamp: nowTime,
      sender: sender,
      receiver: receiver,
      timestamp: DateTime.now().toString(),
      unReadMessNo: 0,
    );
    try {
      await db
          .collection("chats")
          .doc(roomId)
          .collection("messages")
          .doc(chatId)
          .set(
            newChat.toJson(),
          );
      selectedImagePath.value = "";
      await db.collection("chats").doc(roomId).set(
            roomDetails.toJson(),
          );
      await contactController.saveContact(targetUser);
    } catch (e) {
      print(e);
    }
    isLoading.value = false;
  }

Future<void> sendGroupMessage(
  String groupId, 
  String message,
  {String? imageUrl}
) async {
  isLoading.value = true;
  String chatId = uuid.v6();
  DateTime timestamp = DateTime.now();
  String nowTime = DateFormat('hh:mm a').format(timestamp);

  // Fetch group members
  List<String> groupMembers = await _fetchGroupMembers(groupId);

  // Initialize readBy list with group members
  List<String> readBy = List<String>.from(groupMembers);

  var newChat = ChatModel(
    id: chatId,
    message: message,
    senderId: auth.currentUser!.uid,
    receiverId: groupId, // Use group ID for group messages
    senderName: profileController.currentUser.value.name,
    timestamp: DateTime.now().toString(),
    readStatus: "unread",
    readBy: readBy, // Initialize readBy with group members
    imageUrl: imageUrl, // Optional
  );

  var roomDetails = ChatRoomModel(
    id: groupId,
    lastMessage: message,
    lastMessageTimestamp: nowTime,
    sender: profileController.currentUser.value,
    receiver: null, // Not applicable for group messages
    timestamp: DateTime.now().toString(),
    unReadMessNo: 0,
  );

  try {
    await db.collection("chats").doc(groupId).collection("messages").doc(chatId).set(newChat.toJson());
    await db.collection("chats").doc(groupId).set(roomDetails.toJson());
  } catch (e) {
    print(e);
  }
  isLoading.value = false;
}

Future<List<String>> _fetchGroupMembers(String groupId) async {
  DocumentSnapshot<Map<String, dynamic>> groupSnapshot = await db.collection("groups").doc(groupId).get();
  if (groupSnapshot.exists) {
    List<dynamic> members = groupSnapshot.data()?["members"] ?? [];
    return List<String>.from(members);
  }
  return [];
}

Future<void> markGroupMessagesAsRead(String groupId) async {
  QuerySnapshot<Map<String, dynamic>> messagesSnapshot = await db
      .collection("chats")
      .doc(groupId)
      .collection("messages")
      .where("readStatus", isEqualTo: "unread")
      .get();

  String currentUserId = profileController.currentUser.value.id!;

  for (QueryDocumentSnapshot<Map<String, dynamic>> messageDoc in messagesSnapshot.docs) {
    Map<String, dynamic> data = messageDoc.data();
    List<String> existingReadBy = List<String>.from(data["readBy"] ?? []);

    if (!existingReadBy.contains(currentUserId)) {
      // Update readBy list for group messages
      existingReadBy.add(currentUserId);

      await db
          .collection("chats")
          .doc(groupId)
          .collection("messages")
          .doc(messageDoc.id)
          .update({"readBy": existingReadBy});
    }
  }
}


  Stream<List<ChatModel>> getMessages(String targetUserId) {
    String roomId = getRoomId(targetUserId);
    return db
        .collection("chats")
        .doc(roomId)
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

  Stream<UserModel> getStatus(String uid) {
    if (auth.currentUser!.uid == uid) {
      return Stream.value(
        UserModel(
          id: uid,
          name: profileController.currentUser.value.name,
          profileImage: profileController.currentUser.value.profileImage,
          status: "online", // Set status to online
        ),
      );
    }
    return db.collection('users').doc(uid).snapshots().map(
      (event) {
        return UserModel.fromJson(event.data()!);
      },
    );
  }

  Stream<List<CallModel>> getCalls() {
    return db
        .collection("users")
        .doc(auth.currentUser!.uid)
        .collection("calls")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CallModel.fromJson(doc.data()),
              )
              .toList(),
        );
  }

  Stream<int> getUnreadMessageCount(String roomId) {
    return db
        .collection("chats")
        .doc(roomId)
        .collection("messages")
        .where("readStatus", isEqualTo: "unread")
        .where("senderId", isNotEqualTo: profileController.currentUser.value.id)
        .snapshots()
        .map((snapshot) {
      int count = snapshot.docs.length;
      print('Unread count for room $roomId: $count'); // Debugging line
      return count;
    });
  }

  Future<void> markMessagesAsRead(String roomId) async {
    QuerySnapshot<Map<String, dynamic>> messagesSnapshot = await db
        .collection("chats")
        .doc(roomId)
        .collection("messages")
        .where("readStatus", isEqualTo: "unread")
        .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> messageDoc
        in messagesSnapshot.docs) {
      String senderId = messageDoc.data()["senderId"];
      if (senderId != profileController.currentUser.value.id) {
        await db
            .collection("chats")
            .doc(roomId)
            .collection("messages")
            .doc(messageDoc.id)
            .update({"readStatus": "read"});
      }
    }
  }
}
