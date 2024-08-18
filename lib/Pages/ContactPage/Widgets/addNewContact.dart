import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_app/Controller/ContactController.dart';

class AddNewContactPage extends StatelessWidget {
  const AddNewContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ContactController contactController = Get.put(ContactController());
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController mobileController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Contact"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: mobileController,
              decoration: const InputDecoration(labelText: 'Mobile Number'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    (emailController.text.isNotEmpty ||
                        mobileController.text.isNotEmpty)) {
                  await contactController.addNewContact(
                    name: nameController.text,
                    email: emailController.text,
                    mobile: mobileController.text,
                  );
                  Get.back(); // Go back to the previous screen
                } else {
                  Get.snackbar('Error', 'Please fill all fields');
                }
              },
              child: const Text('Add Contact'),
            ),
          ],
        ),
      ),
    );
  }
}
