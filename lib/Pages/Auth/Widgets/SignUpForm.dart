import 'package:chat_app/Controller/AuthController.dart';
import 'package:chat_app/Widget/PrimaryButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupForm extends StatelessWidget {
  SignupForm({super.key});

  final AuthController authController = Get.put(AuthController());
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Added FormKey

  @override
  Widget build(BuildContext context) {
    return Form(
      // Wrap your form fields with a Form widget
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 40),
          TextFormField(
            controller: name,
            keyboardType: TextInputType.name,
            validator: (value) {
              value = value?.trim();
              if (value == null || value.isEmpty) {
                return " Name is required!";
              } else if (value.length < 3) {
                return "Name must be at least 3 characters long";
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: "Full Name",
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              value = value?.trim();
              if (value == null || value.isEmpty) {
                return "Please Enter your email id.";
              } else if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                  .hasMatch(value)) {
                return "Please Enter a valid Email";
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: "Email",
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: password,
            obscureText: true, // Hide the password input
            validator: (value) {
              value = value?.trim();
              if (value == null || value.isEmpty) {
                return "Create a password to signup.";
              } else if (value.length < 6) {
                return "Password must be at least 6 characters long.";
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: "Password",
              prefixIcon: Icon(Icons.password_outlined),
            ),
          ),
          const SizedBox(height: 60),
          Obx(
            () => authController.isLoading.value
                ? const CircularProgressIndicator()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PrimaryButton(
                        ontap: () async {
                          if (_formKey.currentState!.validate()) {
                            authController.createUser(
                              email.text,
                              password.text,
                              name.text,
                            );
                          }
                        },
                        btnName: "SIGNUP",
                        icon: Icons.lock_open_outlined,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
