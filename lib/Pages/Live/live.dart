import 'dart:math';

import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

// Live Page Prebuilt UI from ZEGOCLOUD UIKits
class LiveScreenView extends StatelessWidget {
  final String liveID;
  final bool isHost;

  const LiveScreenView({
    super.key,
    required this.liveID,
    this.isHost = false,
  });

  // Add your app id here and app sign in
  // Make sure you replace with your own

  @override
  Widget build(BuildContext context) {
    final String userId = Random().nextInt(1000).toString();
    return SafeArea(
      child: ZegoUIKitPrebuiltLiveStreaming(
          appID: 799249533,
          appSign:
              "39f83fa5a703b4d617cac4b50820d6542752306229d67f040d7204ef0f562123",
          userID: userId,
          userName: 'user_$userId',
          liveID: 'liveId',
          config: isHost
              ? ZegoUIKitPrebuiltLiveStreamingConfig.host()
              : ZegoUIKitPrebuiltLiveStreamingConfig.audience()),
    );
  }
}
