import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_screen.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print("Permission granted");
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('Permission granted.');
      }
    } else {
      if (kDebugMode) {
        print("Permission denied");
      }
    }
  }

  void initLocalNotifications() async {
    var androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print("Received FCM message:");
        print("Title: ${message.notification!.title}");
        print("Body: ${message.notification!.body}");
      }

      // Check if the message contains data payload
      if (message.data.isNotEmpty) {
        if (kDebugMode) {
          print("Data payload: ${message.data}");
        }

        // Process the data payload
        handleMessage(context, message.data);
      }
    });
  }

  void showNotification(String title, String body) async {
    AndroidNotificationChannel androidNotificationChannel =
        AndroidNotificationChannel(
      Random.secure().nextInt(100000).toString(),
      'High importance notification',
      importance: Importance.max,
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      androidNotificationChannel.id.toString(),
      androidNotificationChannel.name.toString(),
      channelDescription: 'Channel Description!',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@mipmap/ic_launcher',
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
    if (kDebugMode) {
      print("Notification shown: Title: $title, Body: $body");
    }
  }

  void handleMessage(BuildContext context, Map<String, dynamic> data) {
    // Check if the data contains the necessary fields for your notification
    if (data.containsKey('type') &&
        data['type'] == 'intraday' &&
        data.containsKey('id')) {
      // Show notification
      showNotification(data['title'], data['body']);

      // Navigate to relevant screen if needed
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Notifications(id: data['id'])),
      );
      if (kDebugMode) {
        print("Notification triggered for intraday data. ID: ${data['id']}");
      }
    }
  }
}

//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// import '../IPO/IPOScreen.dart';
// import '../IntraDay/IntraDayScreen.dart';
// import '../ShortTerm/ShortTermScreen.dart';
//
// class FirebaseMessagingService {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final GlobalKey<NavigatorState> navigatorKey;
//
//   FirebaseMessagingService({required this.navigatorKey});
//
//   Future<void> initialize() async {
//     await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       provisional: false,
//       sound: true,
//     );
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       if (message.notification != null) {
//         // Handle notification when the app is in the foreground
//         print('Foreground notification: ${message.notification!.title}');
//         showNotification(message);
//       }
//     });
//
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       // Handle notification when the app is opened from a terminated state
//       print('Opened from terminated: ${message.notification!.title}');
//       _navigateToScreen(message.data);
//     });
//
//     // Get the FCM token
//     String? token = await _firebaseMessaging.getToken();
//     if (kDebugMode) {
//       print('FirebaseMessaging token: $token');
//     }
//   }
//
//   void showNotification(RemoteMessage message) async {
//     RemoteNotification? notification = message.notification;
//     if (notification != null) {
//       AndroidNotificationDetails androidNotificationDetails =
//       const AndroidNotificationDetails(
//         'channel_id', // Channel ID
//         'Channel Name', // Channel Name
//         importance: Importance.max,
//         priority: Priority.high,
//         ticker: 'ticker',
//         icon: '@mipmap/ic_launcher',
//       );
//
//       NotificationDetails notificationDetails =
//       NotificationDetails(android: androidNotificationDetails);
//
//       await FlutterLocalNotificationsPlugin().show(
//         0,
//         notification.title!,
//         notification.body!,
//         notificationDetails,
//       );
//     }
//   }
//
//   void _navigateToScreen(Map<String, dynamic> data) {
//     // Extract data from the notification payload
//     String? screen = data['screen'];
//
//     if (screen != null) {
//       switch (screen) {
//         case 'intraday':
//         // Navigate to the Intraday screen
//           navigatorKey.currentState!.push(MaterialPageRoute(
//             builder: (_) => const IntraDayScreen(),
//           ));
//           break;
//         case 'shortterm':
//         // Navigate to the Short Term screen
//           navigatorKey.currentState!.push(MaterialPageRoute(
//             builder: (_) => const ShortTermScreen(),
//           ));
//           break;
//         case 'ipo':
//         // Navigate to the IPO screen
//           navigatorKey.currentState!.push(MaterialPageRoute(
//             builder: (_) => const IPOScreen(),
//           ));
//           break;
//         default:
//           print('Unknown screen: $screen');
//           break;
//       }
//     } else {
//       print('Screen not found in notification data');
//     }
//   }
// }
