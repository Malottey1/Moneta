// settings_utils.dart
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> showNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    'Push Notification',
    'Push notifications are enabled',
    platformChannelSpecifics,
    payload: 'item x',
  );
}

Future<void> sendFeedback() async {
  final Uri params = Uri(
    scheme: 'mailto',
    path: 'support@monetaapp.com',
    query: 'subject=App Feedback&body=App Version: 1.0.0\nFeedback:',
  );

  var url = params.toString();
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}