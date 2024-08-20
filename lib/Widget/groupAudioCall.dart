import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

final String userId = math.Random().nextInt(10000).toString();

class GroupAudioCallScreen extends StatelessWidget {
  GroupAudioCallScreen({Key? key}) : super(key: key);

  final callingId = TextEditingController(text: '1234');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Start Audio Call ',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: callingId,
                decoration: const InputDecoration(focusColor: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return CallPage(callingId: callingId.text.toString());
                    }));
                  },
                  style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                  child: const Text(
                    'Join Call',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

class CallPage extends StatelessWidget {
  final String callingId;
  const CallPage({Key? key, required this.callingId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: ZegoUIKitPrebuiltCall(
      appID: 1272889273,
      appSign:
          "800b89ac943ed882ba7383ae494e503a03afb044cfb1b97f855efedd0a390140",
      userID: userId,
      userName: 'username_$userId',
      callID: callingId,
      config: ZegoUIKitPrebuiltCallConfig.groupVoiceCall(),
    ));
  }
}
