import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {

  @override
  _NotificationsState createState() => _NotificationsState();


}

class _NotificationsState extends State<Notifications> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Notify();
          },
          child: Icon(Icons.circle_notifications),
        ),
      ),
    );
  }
}

void Notify() async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 1, channelKey: 'key1', title: 'test title', body: 'test body'));
}
