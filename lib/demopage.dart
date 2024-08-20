import 'package:chat_app/Controller/chattcontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DemoPage2 extends StatelessWidget {
  const DemoPage2({super.key});

  @override
  Widget build(BuildContext context) {
    ChattController chatController = Get.put(ChattController());
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
