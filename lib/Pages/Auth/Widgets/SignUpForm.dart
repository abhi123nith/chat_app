import 'package:chat_app/Controller/AuthController.dart';
import 'package:chat_app/Widget/PrimaryButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.put(AuthController());
    TextEditingController name = TextEditingController();
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();
    return Column(
      children: [
        const SizedBox(height: 40),
        TextFormField(
          controller: name,
          keyboardType: TextInputType.name,
          validator: (value) {
            RegExp regex = RegExp(r'^.{3,}$');
            if (value!.isEmpty) {
              return ("First Name is required!");
            }
            if (!regex.hasMatch(value)) {
              return ("Name must be min. 3 characters long");
            }
            return null;
          },
          onSaved: (value) {
            name.text = value!;
          },
          decoration: const InputDecoration(
            hintText: "Full Name",
            prefixIcon: Icon(
              Icons.person,
            ),
          ),
        ),
        const SizedBox(height: 30),
        TextFormField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value!.isEmpty) {
              return ("Please Enter your email id.");
            }
            // reg expression for email validation
            if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                .hasMatch(value)) {
              return ("Please Enter a valid Email");
            }
            return null;
          },
          decoration: const InputDecoration(
            hintText: "Email",
            prefixIcon: Icon(
              Icons.alternate_email_rounded,
            ),
          ),
        ),
        const SizedBox(height: 30),
        TextFormField(
          controller: password,
          validator: (value) {
            RegExp regex = RegExp(r'^.{6,}$');
            if (value!.isEmpty) {
              return ("Create a password to signup.");
            }
            if (!regex.hasMatch(value)) {
              return ("Password is Invalid!!!");
            }
            return null;
          },
          decoration: const InputDecoration(
            hintText: "Passowrd",
            prefixIcon: Icon(
              Icons.password_outlined,
            ),
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
                        authController.createUser(
                          email.text,
                          password.text,
                          name.text,
                        );
                      },
                      btnName: "SIGNUP",
                      icon: Icons.lock_open_outlined,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
