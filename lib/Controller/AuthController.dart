import 'package:chat_app/Model/UserModel.dart';
import 'package:chat_app/Pages/Auth/AuthPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AuthController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;

  // For Login

  // Future<void> login(String email, String password) async {
  //   isLoading.value = true;
  //   bool isVerified = false;
  //   User? user;
  //   try {
  //     await auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );

  //     @override
  //     void initState() async {
  //       user = auth.currentUser;
  //       if (user != null) {
  //         await user!.reload();
  //         isVerified = user!.emailVerified;
  //         if (!isVerified) {
  //           auth.currentUser!.sendEmailVerification();
  //           Get.snackbar('Link sent',
  //               'Email verification link has been sent to your email');
  //         }
  //       }
  //     }

  //     if (isVerified) {
  //       Get.offAllNamed("/homePage");
  //       Fluttertoast.showToast(msg: "Logged in Successfully ");
  //     } else {
  //       Get.snackbar('Verify Email', 'Please Verify your email before login');
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'user-not-found') {
  //       print('No user found for that email.');
  //       Get.snackbar('Oops!', 'User not found',
  //           backgroundColor: Colors.redAccent);
  //     } else if (e.code == 'wrong-password') {
  //       print('Wrong password provided for that user.');
  //       Get.snackbar('Oops!', e.code.toString(),
  //           backgroundColor: Colors.redAccent);
  //     }
  //   } catch (e) {
  //     print(e);
  //     Get.snackbar('Error!', 'Please check details',
  //         backgroundColor: Colors.redAccent);
  //   }
  //   isLoading.value = false;
  // }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      // Sign in the user
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await user
            .reload(); // Reload to get the latest email verification status

        // Check if the user's email is verified
        if (user.emailVerified) {
          // If verified, navigate to the home page
          Get.offAllNamed("/homePage");
          Fluttertoast.showToast(msg: "Logged in Successfully");
        } else {
          // If not verified, send an email verification link and show a message
          await user.sendEmailVerification();
          Get.snackbar('Email Not Verified',
              'A verification link has been sent to your email. Please verify before logging in.',
              backgroundColor: Colors.orangeAccent);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Get.snackbar('Oops!', 'User not found',
            backgroundColor: Colors.redAccent);
      } else if (e.code.toString() == 'wrong-password') {
        Get.snackbar('Oops!', 'Wrong password. Please try again.',
            backgroundColor: Colors.redAccent);
      } else {
        Get.snackbar(
            'Error!', e.message ?? 'An error occurred. Please try again.',
            backgroundColor: Colors.redAccent);
      }
    } catch (e) {
      Get.snackbar('Error!', 'An error occurred, please try again.',
          backgroundColor: Colors.redAccent);
    }
    isLoading.value = false;
  }

  Future<void> createUser(String email, String password, String name) async {
    isLoading.value = true;
    try {
      await auth
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          )
          .then(
            (value) => auth.currentUser!.sendEmailVerification(),
          );
      await initUser(email, name);

      Get.snackbar(
          'Link sent', 'Email verification link has been sent to your email');

      print("Account Created 🔥🔥");

      Fluttertoast.showToast(msg: "Account Created Successfully ");
      Get.to(const AuthPage());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Get.snackbar('Oops!', 'Your passward is too weak',
            backgroundColor: Colors.redAccent);
      } else if (e.code == 'email-already-in-use') {
        Get.snackbar('Oops!', 'The account already exists for that email.',
            backgroundColor: Colors.redAccent);
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
    isLoading.value = false;
  }

  Future<void> logoutUser() async {
    await auth.signOut();
    Fluttertoast.showToast(msg: "Loggouted Successfully :)");
    Get.offAllNamed("/authPage");
  }

  Future<void> initUser(String email, String name) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
    var newUser = UserModel(
      email: email,
      name: name,
      id: auth.currentUser!.uid,
      createdAt: formattedDate,
    );

    try {
      await db.collection("users").doc(auth.currentUser!.uid).set(
            newUser.toJson(),
          );
    } catch (ex) {
      print(ex);
      Get.snackbar("Error", ex.toString());
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      Get.snackbar("Email sent", "Check your email now");
    } catch (ex) {
      print(ex);
      Get.snackbar("Error", ex.toString());
    }
  }
}
