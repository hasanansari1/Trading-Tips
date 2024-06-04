import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Notifications extends StatefulWidget {
  const Notifications({Key? key, required String id}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _messaging.requestPermission();
    _messaging.getToken().then((token) {
      if (kDebugMode) {
        print('Device Token: $token');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
      }

      if (message.notification != null) {
        String title = message.notification!.title ?? '';
        String body = message.notification!.body ?? '';
        Map<String, dynamic> notification = {
          'title': title,
          'body': body,
          'timestamp': DateTime.now().toIso8601String(),
        };
        setState(() {
          notifications.add(notification);
        });
        _saveNotification(notification);
      }
    });

    _loadNotifications();
  }

  Future<void> _saveNotification(Map<String, dynamic> notification) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationList = prefs.getStringList('notifications') ?? [];
    notificationList.add(jsonEncode(notification));
    await prefs.setStringList('notifications', notificationList);
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationList = prefs.getStringList('notifications') ?? [];
    setState(() {
      notifications = notificationList
          .map((notificationJson) => jsonDecode(notificationJson))
          .toList()
          .cast<Map<String, dynamic>>();
    });
  }

  Future<void> _deleteNotification(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationList = prefs.getStringList('notifications') ?? [];
    notificationList.removeAt(index);
    await prefs.setStringList('notifications', notificationList);
  }

  String _formatTimestamp(String timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final parsedTimestamp = DateTime.parse(timestamp);
    final startOfDay = DateTime(parsedTimestamp.year, parsedTimestamp.month, parsedTimestamp.day);
    final diff = startOfDay.difference(today);

    if (diff.inDays == 0) {
      return DateFormat('h:mm a').format(parsedTimestamp);
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays > 365) {
      return DateFormat('MMM d, yyyy').format(parsedTimestamp);
    } else {
      return DateFormat('MMM d').format(parsedTimestamp);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: notifications.isEmpty
          ? Container(color: Colors.blue,)
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Dismissible(

                  key: Key(notification['timestamp']),
                  onDismissed: (direction) {
                    setState(() {
                      notifications.removeAt(index);
                      _deleteNotification(index);
                    });
                  },
                  background: Container(color: Colors.red),
                  child: Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.deepOrangeAccent,
                        child: Icon(Icons.notifications),
                      ),
                      title: Text(notification['title']),
                      subtitle: Text(notification['body']),
                      trailing: Text(
                        _formatTimestamp(notification['timestamp']),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
