import 'package:chat_app/Pages/Live/live.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeLivePage extends StatelessWidget {
  final String liveID;
  const HomeLivePage({super.key, required this.liveID});

  @override
  Widget build(BuildContext context) {
    // final liveId = liveID.currentUser.value.liveid;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.to(LivePage(
                  isHost: true,
                  // liveId: liveID,
                ));
              },
              child: const Text('Go Live'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                // Get.to(LivePage(
                //   isHost: false,
                // ));
              },
              child: const Text('Watch a Live'),
            ),
          ],
        ),
      ),
    );
  }
}
