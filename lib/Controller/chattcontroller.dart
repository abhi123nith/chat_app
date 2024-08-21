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

class ChattController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;

  var uuid = const Uuid();
  RxString selectedImagePath = "".obs;
  RxString selectedVideoPath = "".obs;
  ProfileController profileController = Get.put(ProfileController());
  ContactController contactController = Get.put(ContactController());

  String getRoomId(String targetUserId) {
    String currentUserId = auth.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) {
      // Handle the case where currentUserId is null or empty
      return '';
    }
    if (currentUserId[0].codeUnitAt(0) > targetUserId[0].codeUnitAt(0)) {
      return currentUserId + targetUserId;
    } else {
      return targetUserId + currentUserId;
    }
  }

  UserModel getSender(UserModel? currentUser, UserModel targetUser) {
    if (currentUser == null) {
      // Handle null currentUser
      return targetUser;
    }
    String currentUserId = currentUser.id ?? '';
    String targetUserId = targetUser.id ?? '';
    if (currentUserId.isEmpty || targetUserId.isEmpty) {
      // Handle empty IDs
      return targetUser;
    }
    return currentUserId[0].codeUnitAt(0) > targetUserId[0].codeUnitAt(0)
        ? currentUser
        : targetUser;
  }

  UserModel getReciver(UserModel? currentUser, UserModel targetUser) {
    if (currentUser == null) {
      // Handle null currentUser
      return targetUser;
    }
    String currentUserId = currentUser.id ?? '';
    String targetUserId = targetUser.id ?? '';
    if (currentUserId.isEmpty || targetUserId.isEmpty) {
      // Handle empty IDs
      return targetUser;
    }
    return currentUserId[0].codeUnitAt(0) > targetUserId[0].codeUnitAt(0)
        ? targetUser
        : currentUser;
  }

  Future<void> sendMessage(
      String targetUserId, String message, UserModel targetUser, {required String videoPath}) async {
    isLoading.value = true;
    String chatId = uuid.v6();
    String roomId = getRoomId(targetUserId);
    DateTime timestamp = DateTime.now();
    String nowTime = DateFormat('hh:mm a').format(timestamp);

    UserModel? currentUser = profileController.currentUser.value;

    UserModel sender = getSender(currentUser, targetUser);
    UserModel receiver = getReciver(currentUser, targetUser);

    RxString imageUrl = "".obs;
    if (selectedImagePath.value.isNotEmpty) {
      imageUrl.value =
          await profileController.uploadFileToFirebase(selectedImagePath.value);
    }
    RxString videoUrl = "".obs;
    if (selectedVideoPath.value.isNotEmpty) {
      videoUrl.value =
          await profileController.uploadFileToFirebase(selectedVideoPath.value);
    }
    var newChat = ChatModel(
      id: chatId,
      message: message,
      imageUrl: imageUrl.value,
      videoUrl: videoUrl.value,
      senderId: auth.currentUser?.uid ?? '',
      receiverId: targetUserId,
      senderName: currentUser.name ?? 'Unknown',
      timestamp: DateTime.now().toString(),
      readStatus: (auth.currentUser?.uid == targetUserId) ? "read" : "unread",
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
          .set(newChat.toJson());
      selectedImagePath.value = "";
      await db.collection("chats").doc(roomId).set(roomDetails.toJson());
      await contactController.saveContact(targetUser);
    } catch (e) {
      print(e);
    }
    isLoading.value = false;
  }

  Stream<List<ChatModel>> getMessages(String targetUserId) {
    String roomId = getRoomId(targetUserId);
    return db
        .collection("chats")
        .doc(roomId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromJson(doc.data()))
            .toList());
  }

  Stream<UserModel> getStatus(String uid) {
    if (auth.currentUser?.uid == uid) {
      UserModel? currentUser = profileController.currentUser.value;
      return Stream.value(UserModel(
        id: uid,
        name: currentUser.name ?? 'Unknown',
        profileImage: currentUser.profileImage,
        status: "online",
      ));
    }
    return db.collection('users').doc(uid).snapshots().map((event) {
      return UserModel.fromJson(event.data() ?? {});
    });
  }

  Stream<List<CallModel>> getCalls() {
    return db
        .collection("users")
        .doc(auth.currentUser?.uid ?? '')
        .collection("calls")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CallModel.fromJson(doc.data()))
            .toList());
  }

  Stream<int> getUnreadMessageCount(String roomId) {
    return db
        .collection("chats")
        .doc(roomId)
        .collection("messages")
        .where("readStatus", isEqualTo: "unread")
        .where("senderId",
            isNotEqualTo: profileController.currentUser.value.id ?? '')
        .snapshots()
        .map((snapshot) {
      int count = snapshot.docs.length;
      print('Unread count for room $roomId: $count');
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
      String senderId = messageDoc.data()["senderId"] ?? '';
      if (senderId.isNotEmpty &&
          senderId != profileController.currentUser.value.id) {
        await db
            .collection("chats")
            .doc(roomId)
            .collection("messages")
            .doc(messageDoc.id)
            .update({"readStatus": "read"});
      }
    }
  }

  Future<void> deleteMessage(String roomId, String messageId) async {
    try {
      await db
          .collection("chats")
          .doc(roomId)
          .collection("messages")
          .doc(messageId)
          .delete();
      print("Message deleted successfully");
    } catch (e) {
      print("Failed to delete the message: $e");
    }
  }

  Future<void> editMessage(
      String roomId, String messageId, String editedMsg) async {
    try {
      await db
          .collection("chats")
          .doc(roomId)
          .collection("messages")
          .doc(messageId)
          .update({
        "message": editedMsg,
        "timestamp": DateTime.now().toString(),
      });
      print("Message updated successfully");
    } catch (e) {
      print("Failed to edit the message: $e");
    }
  }
}
