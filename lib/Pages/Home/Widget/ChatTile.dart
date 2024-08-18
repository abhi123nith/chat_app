// ignore_for_file: sized_box_for_whitespace, unused_local_variable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Controller/ChatController.dart';
import 'package:chat_app/Pages/ProfilePage/fullpicfromUrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatTile extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String lastChat;
  final String lastTime;
  final String roomId;
  final int unreadCount;

  const ChatTile({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.lastChat,
    required this.lastTime,
    required this.roomId,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    ChatController chatController = Get.put(ChatController());

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  height: 70,
                  width: 70,
                  child: InkWell(
                    onTap: () {
                      Get.to(FullProfilePicUrl(
                        imageUrl: imageUrl,
                      ));
                    },
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: 70,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        lastChat,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              // StreamBuilder(
              //   stream: chatController.getUnreadMessageCount(
              //       "Mp6yiJWt2RWzK5DFPZmroN843xX29SjvS2o0BJfBa80D2CWh2SgazMi1"),
              //   builder: (context, snapshot) {
              //     if (snapshot.hasData && snapshot.data == 0) {
              //       return Container();
              //     }
              //     return Container(
              //       width: 20,
              //       height: 20,
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(100),
              //         color: Theme.of(context).colorScheme.primary,
              //       ),
              //       child: Center(
              //         child: Text(
              //           snapshot.data.toString(),
              //           style: Theme.of(context)
              //               .textTheme
              //               .labelMedium
              //               ?.copyWith(
              //                 color: Theme.of(context).colorScheme.onBackground,
              //               ),
              //         ),
              //       ),
              //     );
              //   },
              // ),
              if (unreadCount > 0)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green, // Green dot
                  ),
                ),
              // Container(
              //   width: 20,
              //   height: 20,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(100),
              //     color: Theme.of(context).colorScheme.primary,
              //   ),
              //   child: Center(
              //     child: Text(
              //       unreadCount.toString(),
              //       style: Theme.of(context).textTheme.labelMedium?.copyWith(
              //             color: Theme.of(context).colorScheme.onBackground,
              //           ),
              //     ),
              //   ),
              // ),
              const SizedBox(
                height: 5,
              ),
              Text(
                lastTime,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
