import 'package:chat_app/Model/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class GroupService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addMemberToGroup(
      {required String groupId, required UserModel newMember}) async {
    try {
      // Reference to the group document
      final groupRef = _firestore.collection('groups').doc(groupId);

      // Add the new member to the group's member list
      await groupRef.update({
        'members': FieldValue.arrayUnion([newMember.toJson()]),
      });

      print("Member added successfully");
    } catch (e) {
      print("Failed to add member: $e");
      // Handle the error
    }
  }
}
