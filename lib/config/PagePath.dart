// ignore_for_file: prefer_const_constructors

import 'package:chat_app/Pages/Auth/AuthPage.dart';
import 'package:chat_app/Pages/Home/HomePage.dart';
import 'package:get/get.dart';
import '../Pages/ContactPage/ContactPage.dart';
import '../Pages/ProfilePage/ProfilePage.dart';

var pagePath = [
  GetPage(
    name: "/authPage",
    page: () => AuthPage(),
    transition: Transition.rightToLeft,
  ),
  GetPage(
    name: "/homePage",
    page: () => HomePage(),
    transition: Transition.rightToLeft,
  ),
 
  GetPage(
    name: "/profilePage",
    page: () => ProfilePage(),
    transition: Transition.rightToLeft,
  ),
  GetPage(
    name: "/contactPage",
    page: () => ContactPage(),
    transition: Transition.rightToLeft,
  ),
  // GetPage(
  //   name: "/updateProfilePage",
  //   page: () => UserUpdateProfile(),
  //   transition: Transition.rightToLeft,
  // ),
];