// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Controller/AuthController.dart';
import 'package:chat_app/Controller/ImagePicker.dart';
import 'package:chat_app/Controller/ProfileController.dart';
import 'package:chat_app/Pages/ProfilePage/fullpicfromUrl.dart';
import 'package:chat_app/Widget/PrimaryButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    RxBool isEdit = false.obs;
    ProfileController profileController = Get.put(ProfileController());
    TextEditingController name =
        TextEditingController(text: profileController.currentUser.value.name);
    TextEditingController email =
        TextEditingController(text: profileController.currentUser.value.email);
    TextEditingController phone = TextEditingController(
        text: profileController.currentUser.value.phoneNumber);
    TextEditingController about =
        TextEditingController(text: profileController.currentUser.value.about);
    ImagePickerController imagePickerController = ImagePickerController();
    Get.put(ImagePickerController());
    RxString imagePath = "".obs;

    AuthController authController = Get.put(AuthController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            onPressed: () {
              _showLogoutConfirmationDialog(
                  context, authController, profileController);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Obx(
                              () => isEdit.value
                                  ? InkWell(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        imagePath.value =
                                            await imagePickerController
                                                .pickImage(ImageSource.gallery);
                                        print("Image Picked${imagePath.value}");
                                      },
                                      child: Container(
                                        height: 200,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background,
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        child: imagePath.value == ""
                                            ? const Icon(
                                                Icons.add,
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                child: Image.file(
                                                  File(imagePath.value),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                      ),
                                    )
                                  : Container(
                                      height: 200,
                                      width: 200,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: profileController.currentUser.value
                                                      .profileImage ==
                                                  null ||
                                              profileController.currentUser
                                                      .value.profileImage ==
                                                  ""
                                          ? const Icon(
                                              Icons.image,
                                            )
                                          : InkWell(
                                              onTap: () {
                                                String imageUrlToUse;

                                                if (imagePath
                                                    .value.isNotEmpty) {
                                                  // If the user has picked a new image, use the new image path
                                                  imageUrlToUse =
                                                      imagePath.value;
                                                } else if (profileController
                                                            .currentUser
                                                            .value
                                                            .profileImage !=
                                                        null &&
                                                    profileController
                                                        .currentUser
                                                        .value
                                                        .profileImage!
                                                        .isNotEmpty) {
                                                  // If there's an existing profile image, use it
                                                  imageUrlToUse =
                                                      profileController
                                                          .currentUser
                                                          .value
                                                          .profileImage!;
                                                } else {
                                                  // Handle the case when there's no image selected or available
                                                  imageUrlToUse =
                                                      ""; // or set a default image URL
                                                }
                                                Get.to(FullProfilePicUrl(
                                                    imageUrl: imageUrlToUse));
                                              },
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  child: CachedNetworkImage(
                                                    imageUrl: profileController
                                                        .currentUser
                                                        .value
                                                        .profileImage!,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context,
                                                            url) =>
                                                        const CircularProgressIndicator(),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        const Icon(Icons.error),
                                                  )),
                                            ),
                                    ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        Obx(
                          () => TextField(
                            controller: name,
                            enabled: isEdit.value,
                            decoration: InputDecoration(
                              filled: isEdit.value,
                              labelText: "Name",
                              prefixIcon: const Icon(
                                Icons.person,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Obx(
                          () => TextField(
                            controller: about,
                            enabled: isEdit.value,
                            decoration: InputDecoration(
                              filled: isEdit.value,
                              labelText: "About",
                              prefixIcon: const Icon(
                                Icons.info,
                              ),
                            ),
                          ),
                        ),
                        TextField(
                          controller: email,
                          enabled: false,
                          decoration: InputDecoration(
                            filled: isEdit.value,
                            labelText: "Email",
                            prefixIcon: const Icon(
                              Icons.alternate_email,
                            ),
                          ),
                        ),
                        Obx(
                          () => TextField(
                            controller: phone,
                            enabled: isEdit.value,
                            decoration: InputDecoration(
                              filled: isEdit.value,
                              labelText: "Number",
                              prefixIcon: const Icon(
                                Icons.phone,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Obx(
                              () => isEdit.value
                                  ? PrimaryButton(
                                      btnName: "Save",
                                      icon: Icons.save,
                                      ontap: () async {
                                        await profileController.updateProfile(
                                          imagePath.value,
                                          name.text,
                                          about.text,
                                          phone.text,
                                        );
                                        isEdit.value = false;
                                        Get.snackbar(" Profile Updated ", "",
                                            colorText: Colors.white,
                                            margin: const EdgeInsets.all(8),
                                            backgroundColor: Colors.green,
                                            icon: const Icon(
                                                Icons.download_done_rounded));
                                      },
                                    )
                                  : PrimaryButton(
                                      btnName: "Edit",
                                      icon: Icons.edit,
                                      ontap: () {
                                        isEdit.value = true;
                                      },
                                    ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context,
      AuthController authController, ProfileController profileController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(profileController.currentUser.value.id)
                    .update({'Status': 'Offline'});
                authController.logoutUser();
                // Get.showSnackbar(snackbar)
                Get.snackbar("Succesfully Logout ", "",
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(8),
                    backgroundColor: Colors.green,
                    icon: const Icon(Icons.download_done_rounded));
                Get.back(); // Close the dialog and log out
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }
}
