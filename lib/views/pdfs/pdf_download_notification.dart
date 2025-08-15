import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../main.dart';

Future<void> showDownloadNotification(String fileName) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'download_channel',
    'Downloads',
    channelDescription: 'Notifies when a file is downloaded',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
  );

  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Download Complete',
    '$fileName has been saved to Downloads folder.',
    platformChannelSpecifics,
  );
}
