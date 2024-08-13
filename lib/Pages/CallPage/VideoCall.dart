// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';


// class VideoCallPage extends StatelessWidget {
//   final UserModel target;
//   const VideoCallPage({super.key, required this.target});

//   @override
//   Widget build(BuildContext context) {
//     ProfileController profileController = Get.put(ProfileController());
//     ChatController chatController = Get.put(ChatController());
//     var callId = chatController.getRoomId(target.id!);
//     return ZegoUIKitPrebuiltCall(
//       appID: ZegoCloudConfig.appId,
//       appSign: ZegoCloudConfig.appSign,
//       userID: profileController.currentUser.value.id ?? "root",
//       userName: profileController.currentUser.value.name ?? "root",
//       callID: callId,
//       config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
//     );
//   }
// }


// // 123