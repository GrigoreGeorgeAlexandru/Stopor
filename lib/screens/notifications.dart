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

          },
          child: Icon(Icons.circle_notifications),
        ),
      ),
    );
  }
}
int id=0;
void Notify(DateTime time,String name,String eventImage) async {
  print("Notification Start");
  id++;
  print(id);
  String localTimeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
  await AwesomeNotifications().createNotification(
      content: NotificationContent(

          id: id,
          channelKey: 'scheduled',
          title:name,
          body: 'There are 24 hours left until this event starts!',
          notificationLayout: NotificationLayout.BigPicture,
          bigPicture:eventImage

      ),
      schedule: NotificationCalendar(
          year:time.year,
          month:time.month,
          day: time.subtract(new Duration(days: 1)).day,
          hour:time.hour,
          minute:time.minute,
          second:time.second,
          millisecond:time.microsecond,
          timeZone: localTimeZone,
          repeats: false
      ));
  print("Notification End");
}
