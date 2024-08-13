import 'package:chat_app/Controller/ChatController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class DemoPage2 extends StatelessWidget {
  const DemoPage2({super.key});

  @override
  Widget build(BuildContext context) {
    ChatController chatController = Get.put(ChatController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Page'),
      ),
      body: StreamBuilder(
        stream: chatController.getUnreadMessageCount(
            "Mp6yiJWt2RWzK5DFPZmroN843xX29SjvS2o0BJfBa80D2CWh2SgazMi1"),
        builder: (context, snapshot) {
          return Center(
            child: Text('Unread Message Count: ${snapshot.data}'),
          );
        },
      ),
    );
  }
}