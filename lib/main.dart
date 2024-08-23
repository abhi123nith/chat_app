import 'package:chat_app/Controller/notificationController.dart';
import 'package:chat_app/Pages/SplacePage/SplacePage.dart';
import 'package:chat_app/config/PagePath.dart';
import 'package:chat_app/config/Themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    // ignore: unused_local_variable
    PushNotification notification = PushNotification(
        title: initialMessage.notification?.title ?? '',
        body: initialMessage.notification?.body ?? '',
        dataTitle: initialMessage.data['title'] ?? '',
        dataBody: initialMessage.data['body'] ?? '');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? user;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _firebaseMessaging.getToken().then((token) {
      print('token: $token');
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        builder: FToastBuilder(),
        title: 'Sampark',
        theme: lightTheme,
        getPages: pagePath,
        darkTheme: darkTheme,
        themeMode: ThemeMode.dark,
        home: const SplacePage(),
        // home: DemoPage2(),
      ),
    );
  }
}
