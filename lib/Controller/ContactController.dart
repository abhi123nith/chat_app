// ignore_for_file: annotate_overrides

import 'package:chat_app/Model/ChatRoomModel.dart';
import 'package:chat_app/Model/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ContactController extends GetxController {
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  RxBool isLoading = false.obs;
  RxList<UserModel> userList = <UserModel>[].obs;
  RxList<ChatRoomModel> chatRoomList = <ChatRoomModel>[].obs;
  void onInit() async {
    super.onInit();
    await getUserList();
  }

  Future<void> getUserList() async {
    isLoading.value = true;
    try {
      userList.clear();
      await db.collection("users").get().then(
            (value) => {
              userList.value = value.docs
                  .map(
                    (e) => UserModel.fromJson(e.data()),
                  )
                  .toList(),
            },
          );
    } catch (ex) {
      print(ex);
    }
    isLoading.value = false;
  }

  Future<void> addNewContact({
    required String name,
    required String email,
    required String mobile,
  }) async {
    try {
      // Assuming that email is unique
      await db.collection('users').add({
        'name': name,
        'email': email,
        'mobile': mobile,
        'profileImage': '', // Optional field
        'status': 'offline',
        'createdAt': DateTime.now().toString(),
      });
      Get.snackbar('Success', 'Contact added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add contact');
    }
  }

  Stream<List<ChatRoomModel>> getChatRoom() {
    return db
        .collection('chats')
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoomModel.fromJson(doc.data()))
            .where((chatRoom) => chatRoom.id!.contains(auth.currentUser!.uid))
            .toList());
  }

  Future<void> saveContact(UserModel user) async {
    try {
      await db
          .collection("users")
          .doc(auth.currentUser!.uid)
          .collection("contacts")
          .doc(user.id)
          .set(user.toJson());
    } catch (ex) {
      if (kDebugMode) {
        print("Error while saving Contact$ex");
      }
    }
  }

  Stream<List<UserModel>> getContacts() {
    return db
        .collection("users")
        .doc(auth.currentUser!.uid)
        .collection("contacts")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => UserModel.fromJson(doc.data()),
              )
              .toList(),
        );
  }
}
