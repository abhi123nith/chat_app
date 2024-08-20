import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Controller/chattcontroller.dart';
import 'package:chat_app/Pages/ProfilePage/fullpicfromUrl.dart';
import 'package:chat_app/config/CustomMessage.dart';
import 'package:chat_app/config/Images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ChatBubble extends StatelessWidget {
  final String messageId;
  final String roomId;
  final String message;
  final bool isComming;
  final String time;
  final String status;
  final String imageUrl;

  const ChatBubble({
    super.key,
    required this.messageId,
    required this.roomId,
    required this.message,
    required this.isComming,
    required this.time,
    required this.status,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final ChattController chatController = Get.find();

    // Debug statements to verify parameter values
    print('ChatBubble build - messageId: $messageId, roomId: $roomId');

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment:
            isComming ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          InkWell(
            onLongPress: () {
              _showMessageOptions(context, chatController);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width / 1.3,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: isComming
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(10),
                      )
                    : const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(0),
                      ),
              ),
              child: imageUrl.isEmpty
                  ? Text(message)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            if (imageUrl.isNotEmpty) {
                              Get.to(FullProfilePicUrl(imageUrl: imageUrl));
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                        if (message.isNotEmpty) const SizedBox(height: 10),
                        if (message.isNotEmpty) Text(message),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment:
                isComming ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (isComming)
                Text(
                  time,
                  style: Theme.of(context).textTheme.labelMedium,
                )
              else
                Row(
                  children: [
                    Text(
                      time,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(width: 10),
                    SvgPicture.asset(
                      AssetsImage.chatStatusSvg,
                      // ignore: deprecated_member_use
                      color: status == "read" ? Colors.green : Colors.grey,
                      width: 20,
                    ),
                  ],
                ),
            ],
          )
        ],
      ),
    );
  }

  void _showMessageOptions(
      BuildContext context, ChattController chatController) {
    print('Showing message options');
    print('Message: $message');
    print('Message ID: $messageId');
    print('Room ID: $roomId');

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            if (imageUrl.isEmpty)
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy Message'),
                onTap: () {
                  print('Copy Message tapped');
                  Navigator.pop(context);
                },
              ),
            if (imageUrl.isNotEmpty && isComming)
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Download'),
                onTap: () {
                  print('Download tapped');
                  Navigator.pop(context);
                },
              ),
            if (imageUrl.isEmpty && !isComming)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Message'),
                onTap: () {
                  print('Edit Message tapped');
                  String editedmsg = message;
                  Get.defaultDialog(
                    title: 'Edit message',
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          print('Cancel pressed');
                          Get.back();
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (editedmsg.isNotEmpty) {
                            print('Update pressed');
                            Get.back();
                            chatController
                                .editMessage(
                              roomId,
                              messageId,
                              editedmsg,
                            )
                                .then((_) {
                              successMessage('Message updated successfully');
                              Get.back();
                            }).catchError((error) {
                              Get.snackbar('Error', 'Failed to update message');
                            });
                          } else {
                            Get.snackbar('Error', 'Message cannot be empty');
                          }
                        },
                        child: const Text('Update'),
                      ),
                    ],
                    content: TextFormField(
                      initialValue: editedmsg,
                      maxLines: null,
                      onChanged: (val) {
                        print('Editing in form field');
                        editedmsg = val;
                      },
                    ),
                  );
                },
              ),
            if (!isComming)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Message'),
                onTap: () async {
                  print('Delete Message tapped');
                  await chatController.deleteMessage(roomId, messageId);
                  Get.back();
                  successMessage('Deleted');
                },
              ),
          ],
        );
      },
    );
  }
}
