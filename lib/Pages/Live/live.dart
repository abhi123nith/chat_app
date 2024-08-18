import 'dart:math';

import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class LivePage extends StatefulWidget {
  final bool isHost;
  //final String liveId;

  const LivePage({
    Key? key,
    required this.isHost,
    // required this.liveId,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => LivePageState();
}

final userId = Random().nextInt(100000).toString();

class LivePageState extends State<LivePage> {
  @override
  void initState() {
    super.initState();

    //  print("Generated userId: $userId"); // Debug print
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltLiveStreaming(
        appID: 799249533,
        appSign:
            "39f83fa5a703b4d617cac4b50820d6542752306229d67f040d7204ef0f562123",
        userID: userId,
        userName: 'user_$userId',
        liveID: 'liveidtest',
        config: widget.isHost
            ? ZegoUIKitPrebuiltLiveStreamingConfig.host()
            : ZegoUIKitPrebuiltLiveStreamingConfig.audience(),
      ),
    );
  }
}
