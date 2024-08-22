import 'package:chat_app/Controller/notificationController.dart';
import 'package:chat_app/Pages/Auth/Widgets/AuthPageBody.dart';
import 'package:chat_app/Pages/Welcome/Widgets/WelcomeHeading.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    PushNotification notification = PushNotification(
        title: initialMessage.notification?.title ?? '',
        body: initialMessage.notification?.body ?? '',
        dataTitle: initialMessage.data['title'] ?? '',
        dataBody: initialMessage.data['body'] ?? '');
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late FirebaseMessaging _messaging;
  int _totalNotifications = 0;
  late PushNotification _notificationInfo;

  void registerNotifications() async {
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    NotificationSettings settings = await _messaging.requestPermission(
        alert: true, badge: true, provisional: false, sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        PushNotification notification = PushNotification(
            title: message.notification?.title ?? '',
            body: message.notification?.body ?? '',
            dataTitle: message.data['title'] ?? '',
            dataBody: message.data['body'] ?? '');
        setState(() {
          _notificationInfo = notification;
          _totalNotifications++;
        });
        showSimpleNotification(Text(_notificationInfo.title),
            subtitle: Text(_notificationInfo.body ?? ''),
            background: Colors.cyan.shade700,
            duration: const Duration(seconds: 2));
      });
    }
  }

  void checkForInitialMessage() async {
    await Firebase.initializeApp();

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotification notification = PushNotification(
          title: initialMessage.notification?.title ?? '',
          body: initialMessage.notification?.body ?? '',
          dataTitle: initialMessage.data['title'] ?? '',
          dataBody: initialMessage.data['body'] ?? '');
      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    }
  }

  @override
  void initState() {
    _totalNotifications = 0;
    registerNotifications();
    checkForInitialMessage();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
          title: message.notification?.title ?? '',
          body: message.notification?.body ?? '',
          dataTitle: message.data['title'] ?? '',
          dataBody: message.data['body'] ?? '');
      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                WelcomeHeading(),
                SizedBox(height: 60),
                AuthPageBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
