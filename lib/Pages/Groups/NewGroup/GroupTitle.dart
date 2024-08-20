// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:chat_app/Controller/GroupController.dart';
import 'package:chat_app/Pages/Home/Widget/ChatTile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../Config/Images.dart';
import '../../../Controller/ImagePicker.dart';

class GroupTitle extends StatelessWidget {
  const GroupTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final GroupController groupController = Get.put(GroupController());
    final ImagePickerController imagePickerController =
        Get.put(ImagePickerController());
    final RxString imagePath = ''.obs;
    final RxString groupName = ''.obs;
    final RxBool isLoading = false.obs; // Add an RxBool for loading state

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
      ),
      floatingActionButton: Obx(
        () => FloatingActionButton(
          backgroundColor: groupName.isEmpty
              ? Colors.grey
              : Theme.of(context).colorScheme.primary,
          onPressed: () async {
            if (groupName.value.isEmpty) {
              Get.snackbar("Error", "Please enter group name");
            } else {
              isLoading.value = true; // Show progress indicator
              await groupController.createGroup(
                  groupName.value, imagePath.value);
              isLoading.value = false; // Hide progress indicator
              Get.back(); // Navigate back after creating the group
            }
          },
          child: isLoading.value
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : Icon(
                  Icons.done,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Obx(
                        () => InkWell(
                          onTap: () async {
                            final pickedImagePath = await imagePickerController
                                .pickImage(ImageSource.gallery);
                            imagePath.value = pickedImagePath;
                                                    },
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: imagePath.value.isEmpty
                                ? const Icon(
                                    Icons.group,
                                    size: 40,
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.file(
                                      File(imagePath.value),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        onChanged: (value) {
                          groupName.value = value;
                        },
                        decoration: const InputDecoration(
                          hintText: "Group Name",
                          prefixIcon: Icon(Icons.group),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: groupController.groupMembers
                    .map(
                      (e) => ChatTile(
                        imageUrl:
                            e.profileImage ?? AssetsImage.defaultProfileUrl,
                        name: e.name ?? 'User',
                        lastChat: e.about?.isNotEmpty == true
                            ? e.about!
                            : "Hey, I am using Sampark App!",
                        lastTime:
                            '', // Update this according to your requirements
                        roomId: '', // Handle this appropriately
                        role: e.role ?? "User", // Add role here
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
