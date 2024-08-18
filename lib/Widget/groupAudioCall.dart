import 'package:chat_app/Controller/ChatController.dart';
import 'package:chat_app/Controller/ProfileController.dart';
import 'package:chat_app/Model/UserModel.dart';
import 'package:chat_app/config/String.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class GroupAudioCallPage extends StatelessWidget {
  final UserModel target;
  const GroupAudioCallPage({super.key, required this.target});

  @override
  Widget build(BuildContext context) {
    ProfileController profileController = Get.put(ProfileController());
    ChatController chatController = Get.put(ChatController());
    var callId = chatController.getRoomId(target.id!);
    return ZegoUIKitPrebuiltCall(
      appID: ZegoCloudConfig.appId,
      appSign: ZegoCloudConfig.appSign,
      userID: profileController.currentUser.value.id ?? "root",
      userName: profileController.currentUser.value.name ?? "root",
      callID: callId,
      config: ZegoUIKitPrebuiltCallConfig.groupVoiceCall(),
    );
  }
}


// 123